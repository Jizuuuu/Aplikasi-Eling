import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Upgrade ke versi 2 untuk skema db_eling lengkap
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabel Pengguna
    await db.execute('''
      CREATE TABLE pengguna (
        KodePengguna TEXT PRIMARY KEY,
        NamaPengguna TEXT NOT NULL,
        Email TEXT NOT NULL UNIQUE,
        PasswordHash TEXT NOT NULL
      )
    ''');

    // 2. Tabel Kategori
    await db.execute('''
      CREATE TABLE kategori (
        KodeKategori TEXT PRIMARY KEY,
        NamaKategori TEXT NOT NULL,
        Deskripsi TEXT,
        color_hex TEXT DEFAULT '#3B82F6',
        icon_name TEXT DEFAULT 'folder'
      )
    ''');

    // 3. Tabel Aktivitas
    await db.execute('''
      CREATE TABLE aktivitas (
        KodeAktivitas TEXT PRIMARY KEY,
        KodePengguna TEXT NOT NULL,
        KodeKategori TEXT NOT NULL,
        NamaAktivitas TEXT NOT NULL,
        TanggalAktivitas TEXT NOT NULL,
        StatusAktivitas TEXT NOT NULL DEFAULT 'Belum',
        FOREIGN KEY (KodePengguna) REFERENCES pengguna (KodePengguna) ON DELETE CASCADE,
        FOREIGN KEY (KodeKategori) REFERENCES kategori (KodeKategori) ON DELETE CASCADE
      )
    ''');

    // 4. Tabel Pengingat
    await db.execute('''
      CREATE TABLE pengingat (
        KodePengingat TEXT PRIMARY KEY,
        KodeAktivitas TEXT NOT NULL,
        WaktuPengingat TEXT NOT NULL,
        MetodePengingat TEXT NOT NULL DEFAULT 'Notifikasi',
        StatusPengingat TEXT NOT NULL DEFAULT 'Aktif',
        notification_id INTEGER,
        FOREIGN KEY (KodeAktivitas) REFERENCES aktivitas (KodeAktivitas) ON DELETE CASCADE
      )
    ''');

    // 5. Tabel Riwayat Pengingat
    await db.execute('''
      CREATE TABLE riwayat_pengingat (
        KodeRiwayat TEXT PRIMARY KEY,
        KodePengingat TEXT NOT NULL,
        WaktuProses TEXT NOT NULL,
        StatusPengiriman TEXT NOT NULL DEFAULT 'Terkirim',
        Keterangan TEXT,
        FOREIGN KEY (KodePengingat) REFERENCES pengingat (KodePengingat) ON DELETE CASCADE
      )
    ''');

    // Indexes untuk kecepatan query dashboard
    await db.execute('CREATE INDEX idx_aktivitas_user ON aktivitas (KodePengguna)');
    await db.execute('CREATE INDEX idx_pengingat_waktu ON pengingat (WaktuPengingat)');

    // Seed Data Awal Sesuai Query Kelompok
    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS riwayat_pengingat');
      await db.execute('DROP TABLE IF EXISTS pengingat');
      await db.execute('DROP TABLE IF EXISTS aktivitas');
      await db.execute('DROP TABLE IF EXISTS kategori');
      await db.execute('DROP TABLE IF EXISTS pengguna');
      await db.execute('DROP TABLE IF EXISTS reminders');
      await db.execute('DROP TABLE IF EXISTS categories');
      await _createDB(db, newVersion);
    }
  }

  Future<void> _seedInitialData(Database db) async {
    final batch = db.batch();

    // 2.1 Seed Pengguna (5 Anggota Kelompok)
    final penggunaList = [
      {'KodePengguna': 'U0001', 'NamaPengguna': 'Aziz Faadihilah', 'Email': 'aziz@example.com', 'PasswordHash': 'aziz123'},
      {'KodePengguna': 'U0002', 'NamaPengguna': 'Gobes Jefri', 'Email': 'gobes@example.com', 'PasswordHash': 'jafri123'},
      {'KodePengguna': 'U0003', 'NamaPengguna': 'Riandhika Bagug', 'Email': 'bagug@example.com', 'PasswordHash': 'bagus123'},
      {'KodePengguna': 'U0004', 'NamaPengguna': 'Abied hyper', 'Email': 'abied@example.com', 'PasswordHash': 'abid123'},
      {'KodePengguna': 'U0005', 'NamaPengguna': 'Sniper Atalah', 'Email': 'sniper@example.com', 'PasswordHash': 'sniper123'},
    ];
    for (final u in penggunaList) {
      batch.insert('pengguna', u, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2.2 Seed Kategori
    final kategoriList = [
      {'KodeKategori': 'K0001', 'NamaKategori': 'Pendidikan', 'Deskripsi': 'Aktivitas belajar dan kuliah', 'color_hex': '#3B82F6', 'icon_name': 'school'},
      {'KodeKategori': 'K0002', 'NamaKategori': 'Pekerjaan', 'Deskripsi': 'Aktivitas pekerjaan dan tugas', 'color_hex': '#EF4444', 'icon_name': 'assignment'},
      {'KodeKategori': 'K0003', 'NamaKategori': 'Kesehatan', 'Deskripsi': 'Aktivitas olahraga dan kesehatan', 'color_hex': '#10B981', 'icon_name': 'fitness_center'},
      {'KodeKategori': 'K0004', 'NamaKategori': 'Pribadi', 'Deskripsi': 'Aktivitas dan kebutuhan pribadi', 'color_hex': '#F59E0B', 'icon_name': 'person'},
      {'KodeKategori': 'K0005', 'NamaKategori': 'Lainnya', 'Deskripsi': 'Aktivitas lainnya', 'color_hex': '#8B5CF6', 'icon_name': 'more_horiz'},
    ];
    for (final k in kategoriList) {
      batch.insert('kategori', k, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2.3 Seed Aktivitas
    final aktivitasList = [
      {'KodeAktivitas': 'A0001', 'KodePengguna': 'U0001', 'KodeKategori': 'K0001', 'NamaAktivitas': 'Mengerjakan tugas kuliah', 'TanggalAktivitas': '2026-10-20', 'StatusAktivitas': 'Belum'},
      {'KodeAktivitas': 'A0002', 'KodePengguna': 'U0002', 'KodeKategori': 'K0002', 'NamaAktivitas': 'Menyelesaikan laporan', 'TanggalAktivitas': '2026-10-20', 'StatusAktivitas': 'Belum'},
      {'KodeAktivitas': 'A0003', 'KodePengguna': 'U0003', 'KodeKategori': 'K0003', 'NamaAktivitas': 'Olahraga pagi', 'TanggalAktivitas': '2026-10-21', 'StatusAktivitas': 'Belum'},
      {'KodeAktivitas': 'A0004', 'KodePengguna': 'U0004', 'KodeKategori': 'K0004', 'NamaAktivitas': 'Membayar tagihan', 'TanggalAktivitas': '2026-10-21', 'StatusAktivitas': 'Belum'},
      {'KodeAktivitas': 'A0005', 'KodePengguna': 'U0005', 'KodeKategori': 'K0001', 'NamaAktivitas': 'Belajar untuk ujian', 'TanggalAktivitas': '2026-10-22', 'StatusAktivitas': 'Belum'},
    ];
    for (final a in aktivitasList) {
      batch.insert('aktivitas', a, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2.4 Seed Pengingat
    final pengingatList = [
      {'KodePengingat': 'P0001', 'KodeAktivitas': 'A0001', 'WaktuPengingat': '2026-10-20 08:00:00', 'MetodePengingat': 'Notifikasi', 'StatusPengingat': 'Aktif', 'notification_id': 1001},
      {'KodePengingat': 'P0002', 'KodeAktivitas': 'A0002', 'WaktuPengingat': '2026-10-20 10:00:00', 'MetodePengingat': 'Notifikasi', 'StatusPengingat': 'Aktif', 'notification_id': 1002},
      {'KodePengingat': 'P0003', 'KodeAktivitas': 'A0003', 'WaktuPengingat': '2026-10-21 06:00:00', 'MetodePengingat': 'Alarm', 'StatusPengingat': 'Aktif', 'notification_id': 1003},
      {'KodePengingat': 'P0004', 'KodeAktivitas': 'A0004', 'WaktuPengingat': '2026-10-21 12:00:00', 'MetodePengingat': 'Notifikasi', 'StatusPengingat': 'Aktif', 'notification_id': 1004},
      {'KodePengingat': 'P0005', 'KodeAktivitas': 'A0005', 'WaktuPengingat': '2026-10-22 19:00:00', 'MetodePengingat': 'Alarm', 'StatusPengingat': 'Aktif', 'notification_id': 1005},
    ];
    for (final p in pengingatList) {
      batch.insert('pengingat', p, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2.5 Seed Riwayat Pengingat
    final riwayatList = [
      {'KodeRiwayat': 'R0001', 'KodePengingat': 'P0001', 'WaktuProses': '2026-10-20 08:00:00', 'StatusPengiriman': 'Terkirim', 'Keterangan': 'Pengingat tugas kuliah'},
      {'KodeRiwayat': 'R0002', 'KodePengingat': 'P0002', 'WaktuProses': '2026-10-20 10:00:00', 'StatusPengiriman': 'Terkirim', 'Keterangan': 'Pengingat laporan'},
      {'KodeRiwayat': 'R0003', 'KodePengingat': 'P0003', 'WaktuProses': '2026-10-21 06:00:00', 'StatusPengiriman': 'Terkirim', 'Keterangan': 'Pengingat olahraga'},
      {'KodeRiwayat': 'R0004', 'KodePengingat': 'P0004', 'WaktuProses': '2026-10-21 12:00:00', 'StatusPengiriman': 'Terkirim', 'Keterangan': 'Pengingat pembayaran'},
      {'KodeRiwayat': 'R0005', 'KodePengingat': 'P0005', 'WaktuProses': '2026-10-22 19:00:00', 'StatusPengiriman': 'Terkirim', 'Keterangan': 'Pengingat belajar'},
    ];
    for (final r in riwayatList) {
      batch.insert('riwayat_pengingat', r, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // --- QUERY HELPER KHUSUS AUTENTIKASI ---
  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    final results = await db.query(
      'pengguna',
      where: 'Email = ? AND PasswordHash = ?',
      whereArgs: [email.trim(), password.trim()],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> registerUser(String kode, String nama, String email, String password) async {
    final db = await database;
    return await db.insert('pengguna', {
      'KodePengguna': kode,
      'NamaPengguna': nama,
      'Email': email,
      'PasswordHash': password,
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
