# DOKUMEN PENGUJIAN PERANGKAT LUNAK (IMPAL)
## Aplikasi: ELING — Smart Daily Reminder
**Target Platform**: Android (Flutter & Dart)  
**Database**: SQLite (`sqflite`)  
**Mata Kuliah**: Implementasi dan Pengujian Perangkat Lunak (IMPAL)  

---

## 1. Pembagian Tugas Kelompok (5 Anggota)

| No | Peran Anggota | Tanggung Jawab Utama | Modul / Berkas |
|:---:|:---|:---|:---|
| **1** | **Database & Alarm Lead** | Manajemen database SQLite, skema tabel, migrasi, dan konfigurasi Alarm Manager Android. | `lib/core/database/`, `lib/core/notifications/` |
| **2** | **UI / UX & Screens Lead** | Desain visual Material 3, tema aplikasi, layout dashboard utama (tabs), dan komponen card pengingat. | `lib/features/reminders/presentation/screens/home_screen.dart`, `reminder_card.dart` |
| **3** | **Form & State Management Lead** | Logika state Riverpod, validasi form manual offline, kontrol filter tab (Hari Ini, Mendatang, Selesai). | `reminder_form_screen.dart`, `reminder_providers.dart` |
| **4** | **Voice STT & AI Proxy Lead** | Speech-to-Text bahasa Indonesia, arsitektur backend proxy aman (keamanan API Key), dan prompt engineering. | `server/index.js`, `speech_to_text_service.dart`, `ai_proxy_service.dart` |
| **5** | **QA & Test Lead** | Penyusunan test case, eksekusi unit test & widget test, dokumentasi IMPAL, dan pengujian keandalan baterai OEM. | `test/`, `battery_guide_screen.dart`, Dokumen IMPAL |

---

## 2. Rencana Pengujian (Test Plan)

### 2.1 Lingkup Pengujian
Pengujian mencakup:
1. **Whitebox / Unit Testing**: Pengujian kode logika serialisasi SQLite, kalkulasi waktu relatif bahasa Indonesia, dan ekstraksi kata kunci.
2. **Widget Testing**: Pengujian antarmuka pengguna untuk memverifikasi komponen interaktif dan render visual.
3. **Blackbox / Integration Testing**: Pengujian fungsionalitas keseluruhan aplikasi langsung pada perangkat fisik Android dan emulator.

### 2.2 Cara Menjalankan Pengujian Otomatis
Buka terminal pada direktori proyek dan jalankan:
```bash
# Menjalankan seluruh berkas pengujian unit dan widget
flutter test

# Menjalankan pengujian spesifik
flutter test test/reminder_model_test.dart
flutter test test/date_formatter_test.dart
flutter test test/ai_proxy_service_test.dart
flutter test test/widget_test.dart
```

---

## 3. Matriks Skenario Uji (Test Cases)

| ID | Skenario Pengujian | Langkah Pengujian | Hasil yang Diharapkan | Status |
|:---:|:---|:---|:---|:---:|
| **TC-01** | **Input Pengingat Manual (Mode Offline)** | Aktifkan Mode Pesawat (Airplane Mode) > Buka Form Tambah > Isi judul, jam, tanggal, kategori > Tekan "Simpan Pengingat". | Data berhasil tersimpan ke SQLite, muncul di tab "Hari Ini", tanpa error koneksi internet. | **PASS** |
| **TC-02** | **Keandalan Alarm Notifikasi Presisi** | Buka menu Panduan Baterai > Tekan "Jadwalkan Notifikasi 10 Detik" > Kunci layar HP. | Tepat pada detik ke-10, HP bergetar, berdering, dan menampilkan pop-up notifikasi ELING. | **PASS** |
| **TC-03** | **Speech-to-Text Bahasa Indonesia** | Tekan tombol mikrofon ungu > Ucapkan: *"Ingatkan kumpul tugas IMPAL besok jam 2 siang"*. | Teks ucapan tertranskripsi secara real-time dalam bahasa Indonesia di layar modal. | **PASS** |
| **TC-04** | **Keamanan API Key AI (Zero Exposure)** | Periksa file APK / kode Flutter `lib/` untuk memastikan tidak ada string API Key Gemini/OpenAI. | Tidak ada API key di mobile client. Komunikasi AI dilakukan melalui server proxy `server/index.js`. | **PASS** |
| **TC-05** | **Wajib Konfirmasi Data AI Sebelum Simpan** | Selesaikan input suara > Tunggu AI menganalisis. | Aplikasi **TIDAK langsung menyimpan** ke database, melainkan membuka "Modal Konfirmasi Pengingat AI" agar pengguna bisa mereview atau mengedit data terlebih dahulu. | **PASS** |
| **TC-06** | **Toggle Aktif / Nonaktif Pengingat** | Geser toggle switch pada card pengingat menjadi nonaktif. | Alarm notifikasi yang sudah terjadwal di Android otomatis dibatalkan (*cancelled*). Saat diaktifkan kembali, alarm dijadwalkan ulang. | **PASS** |
| **TC-07** | **Tandai Pengingat Selesai** | Centang checkbox bulat pada item pengingat. | Item berpindah dari tab "Hari Ini" ke tab "Selesai", teks diberi coretan (*strikethrough*), dan notifikasinya dibatalkan. | **PASS** |
| **TC-08** | **Reboot Persistence (Setelah HP Nyala Ulang)** | Jadwalkan pengingat > Restart perangkat HP > Periksa status alarm setelah boot selesai. | `ScheduledNotificationBootReceiver` otomatis memulihkan jadwal alarm dari SQLite. | **PASS** |
| **TC-09** | **Bypass Penghemat Baterai OEM** | Buka menu Panduan Baterai > Tekan "Buka Pengaturan Baterai". | Sistem Android langsung membuka halaman pengaturan baterai aplikasi untuk memilih "Unrestricted". | **PASS** |

---

## 4. Kriteria Penerimaan (Acceptance Criteria)

- [x] **AC-1 (Offline Functionality)**: Pembuatan dan pembacaan pengingat manual berfungsi 100% tanpa internet.
- [x] **AC-2 (Exact Scheduling)**: Alarm menggunakan `AndroidScheduleMode.exactAllowWhileIdle` sehingga berbunyi tepat waktu saat Doze Mode.
- [x] **AC-3 (Speech-to-Text)**: Mendukung pengenalan ucapan Bahasa Indonesia (`id_ID`) dengan transkripsi interaktif.
- [x] **AC-4 (AI Extraction)**: AI dapat mengenali judul aktivitas, jam spesifik (pagi/siang/sore/malam), dan kategori.
- [x] **AC-5 (Confirmation Step)**: Tidak ada data AI yang disimpan ke SQLite tanpa tombol "Konfirmasi & Simpan" ditekan pengguna.
- [x] **AC-6 (Security)**: Kunci API AI aman di sisi server proxy, tidak tertanam dalam biner aplikasi Android.
- [x] **AC-7 (Clean Architecture)**: Arsitektur Feature-First dengan pemisahan Core, Reminders, Voice AI, dan Settings.
