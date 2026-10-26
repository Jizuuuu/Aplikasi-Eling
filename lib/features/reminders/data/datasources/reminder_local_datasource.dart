import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/reminder_model.dart';
import '../../domain/entities/category.dart';

abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getAllReminders({String? userCode});
  Future<List<ReminderModel>> getTodayReminders({String? userCode});
  Future<List<ReminderModel>> getUpcomingReminders({String? userCode});
  Future<List<ReminderModel>> getCompletedReminders({String? userCode});
  Future<ReminderModel?> getReminderById(int id);
  Future<int> insertReminder(ReminderModel reminder, {String? userCode});
  Future<int> updateReminder(ReminderModel reminder);
  Future<int> deleteReminder(int id);
  Future<int> toggleComplete(int id, bool isCompleted);
  Future<int> toggleActive(int id, bool isActive);
  Future<List<Category>> getAllCategories();
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final DatabaseHelper dbHelper;

  ReminderLocalDataSourceImpl({required this.dbHelper});

  String get _selectWithCategoryQuery => '''
    SELECT 
      CAST(SUBSTR(p.KodePengingat, 2) AS INTEGER) AS id,
      p.KodePengingat AS kode_pengingat,
      a.KodeAktivitas AS kode_aktivitas,
      a.NamaAktivitas AS title,
      k.Deskripsi AS description,
      p.WaktuPengingat AS remind_at,
      CAST(SUBSTR(a.KodeKategori, 2) AS INTEGER) AS category_id,
      CASE WHEN a.StatusAktivitas = 'Selesai' THEN 1 ELSE 0 END AS is_completed,
      CASE WHEN p.StatusPengingat = 'Aktif' THEN 1 ELSE 0 END AS is_active,
      COALESCE(p.notification_id, CAST(SUBSTR(p.KodePengingat, 2) AS INTEGER)) AS notification_id,
      'MANUAL' AS source,
      k.NamaKategori AS category_name,
      k.color_hex AS category_color_hex,
      a.TanggalAktivitas AS created_at,
      p.WaktuPengingat AS updated_at
    FROM pengingat p
    JOIN aktivitas a ON p.KodeAktivitas = a.KodeAktivitas
    JOIN kategori k ON a.KodeKategori = k.KodeKategori
  ''';

  @override
  Future<List<ReminderModel>> getAllReminders({String? userCode}) async {
    final db = await dbHelper.database;
    final whereClause = userCode != null ? 'WHERE a.KodePengguna = ?' : '';
    final args = userCode != null ? [userCode] : null;
    final result = await db.rawQuery('$_selectWithCategoryQuery $whereClause ORDER BY p.WaktuPengingat ASC', args);
    return result.map((e) => ReminderModel.fromMap(e)).toList();
  }

  @override
  Future<List<ReminderModel>> getTodayReminders({String? userCode}) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final todayStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    String where = "WHERE (p.WaktuPengingat LIKE '$todayStr%' OR a.TanggalAktivitas = '$todayStr') AND a.StatusAktivitas != 'Selesai'";
    List<dynamic>? args;
    if (userCode != null) {
      where += " AND a.KodePengguna = ?";
      args = [userCode];
    }

    final result = await db.rawQuery('$_selectWithCategoryQuery $where ORDER BY p.WaktuPengingat ASC', args);
    return result.map((e) => ReminderModel.fromMap(e)).toList();
  }

  @override
  Future<List<ReminderModel>> getUpcomingReminders({String? userCode}) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final todayStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    String where = "WHERE p.WaktuPengingat > '$todayStr 23:59:59' AND a.StatusAktivitas != 'Selesai'";
    List<dynamic>? args;
    if (userCode != null) {
      where += " AND a.KodePengguna = ?";
      args = [userCode];
    }

    final result = await db.rawQuery('$_selectWithCategoryQuery $where ORDER BY p.WaktuPengingat ASC', args);
    return result.map((e) => ReminderModel.fromMap(e)).toList();
  }

  @override
  Future<List<ReminderModel>> getCompletedReminders({String? userCode}) async {
    final db = await dbHelper.database;
    String where = "WHERE a.StatusAktivitas = 'Selesai'";
    List<dynamic>? args;
    if (userCode != null) {
      where += " AND a.KodePengguna = ?";
      args = [userCode];
    }

    final result = await db.rawQuery('$_selectWithCategoryQuery $where ORDER BY p.WaktuPengingat DESC', args);
    return result.map((e) => ReminderModel.fromMap(e)).toList();
  }

  @override
  Future<ReminderModel?> getReminderById(int id) async {
    final db = await dbHelper.database;
    final code = "P${id.toString().padLeft(4, '0')}";
    final result = await db.rawQuery(
      '$_selectWithCategoryQuery WHERE p.KodePengingat = ? LIMIT 1',
      [code],
    );
    if (result.isNotEmpty) {
      return ReminderModel.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<int> insertReminder(ReminderModel reminder, {String? userCode}) async {
    final db = await dbHelper.database;
    final effectiveUser = userCode ?? 'U0001';

    // 1. Generate KodeAktivitas
    final maxAkt = await db.rawQuery('SELECT KodeAktivitas FROM aktivitas ORDER BY KodeAktivitas DESC LIMIT 1');
    int nextAktNum = 6;
    if (maxAkt.isNotEmpty) {
      final lastCode = maxAkt.first['KodeAktivitas'] as String;
      nextAktNum = (int.tryParse(lastCode.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5) + 1;
    }
    final kodeAktivitas = "A${nextAktNum.toString().padLeft(4, '0')}";

    // 2. Generate KodePengingat
    final maxPeng = await db.rawQuery('SELECT KodePengingat FROM pengingat ORDER BY KodePengingat DESC LIMIT 1');
    int nextPengNum = 6;
    if (maxPeng.isNotEmpty) {
      final lastCode = maxPeng.first['KodePengingat'] as String;
      nextPengNum = (int.tryParse(lastCode.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5) + 1;
    }
    final kodePengingat = "P${nextPengNum.toString().padLeft(4, '0')}";

    // Format Tanggal & Waktu
    final dt = reminder.remindAt;
    final tanggalStr = "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    final waktuStr = "$tanggalStr ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
    final categoryCode = "K${(reminder.categoryId ?? 1).toString().padLeft(4, '0')}";

    // Insert ke tabel aktivitas
    await db.insert('aktivitas', {
      'KodeAktivitas': kodeAktivitas,
      'KodePengguna': effectiveUser,
      'KodeKategori': categoryCode,
      'NamaAktivitas': reminder.title,
      'TanggalAktivitas': tanggalStr,
      'StatusAktivitas': reminder.isCompleted ? 'Selesai' : 'Belum',
    });

    // Insert ke tabel pengingat
    await db.insert('pengingat', {
      'KodePengingat': kodePengingat,
      'KodeAktivitas': kodeAktivitas,
      'WaktuPengingat': waktuStr,
      'MetodePengingat': 'Notifikasi',
      'StatusPengingat': reminder.isActive ? 'Aktif' : 'Nonaktif',
      'notification_id': reminder.notificationId,
    });

    // Insert ke tabel riwayat_pengingat
    final kodeRiwayat = "R${nextPengNum.toString().padLeft(4, '0')}";
    await db.insert('riwayat_pengingat', {
      'KodeRiwayat': kodeRiwayat,
      'KodePengingat': kodePengingat,
      'WaktuProses': waktuStr,
      'StatusPengiriman': 'Terkirim',
      'Keterangan': 'Pengingat dibuat: ${reminder.title}',
    });

    return nextPengNum;
  }

  @override
  Future<int> updateReminder(ReminderModel reminder) async {
    final db = await dbHelper.database;
    final id = reminder.id ?? 1;
    final code = "P${id.toString().padLeft(4, '0')}";

    final dt = reminder.remindAt;
    final waktuStr = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";

    return await db.update(
      'pengingat',
      {
        'WaktuPengingat': waktuStr,
        'StatusPengingat': reminder.isActive ? 'Aktif' : 'Nonaktif',
      },
      where: 'KodePengingat = ?',
      whereArgs: [code],
    );
  }

  @override
  Future<int> deleteReminder(int id) async {
    final db = await dbHelper.database;
    final code = "P${id.toString().padLeft(4, '0')}";
    return await db.delete('pengingat', where: 'KodePengingat = ?', whereArgs: [code]);
  }

  @override
  Future<int> toggleComplete(int id, bool isCompleted) async {
    final db = await dbHelper.database;
    final pCode = "P${id.toString().padLeft(4, '0')}";

    // Ambil KodeAktivitas
    final res = await db.query('pengingat', columns: ['KodeAktivitas'], where: 'KodePengingat = ?', whereArgs: [pCode]);
    if (res.isNotEmpty) {
      final aCode = res.first['KodeAktivitas'] as String;
      return await db.update(
        'aktivitas',
        {'StatusAktivitas': isCompleted ? 'Selesai' : 'Belum'},
        where: 'KodeAktivitas = ?',
        whereArgs: [aCode],
      );
    }
    return 0;
  }

  @override
  Future<int> toggleActive(int id, bool isActive) async {
    final db = await dbHelper.database;
    final pCode = "P${id.toString().padLeft(4, '0')}";
    return await db.update(
      'pengingat',
      {'StatusPengingat': isActive ? 'Aktif' : 'Nonaktif'},
      where: 'KodePengingat = ?',
      whereArgs: [pCode],
    );
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    final result = await db.query('kategori', orderBy: 'KodeKategori ASC');
    return result.map((e) {
      final rawCode = e['KodeKategori'] as String;
      final intId = int.tryParse(rawCode.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      return Category(
        id: intId,
        name: e['NamaKategori'] as String,
        colorHex: (e['color_hex'] as String?) ?? '#3B82F6',
        iconName: (e['icon_name'] as String?) ?? 'school',
      );
    }).toList();
  }
}
