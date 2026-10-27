# ELING — Smart Daily Reminder

Aplikasi mobile pengingat aktivitas harian cerdas berbasis Android untuk tugas besar mata kuliah **Implementasi dan Pengujian Perangkat Lunak (IMPAL)**. 

Aplikasi ini mengusung konsep **Offline-First**, dilengkapi fitur pengenalan suara Bahasa Indonesia (*Speech-to-Text*) dan ekstraksi pengingat berbasis kecerdasan buatan (AI) dengan keamanan API Key terjamin.

---

## 📱 Cara Kerja & Alur Aplikasi

```text
[Buka Aplikasi]
       │
       ▼
[Halaman Login] ──► Autentikasi akun pengguna (Tersedia Quick-Fill 5 akun anggota)
       │
       ▼
[Beranda Utama] ──► Menampilkan pengingat milik pengguna yang sedang login
       │            (Dipilah berdasarkan tab: Hari Ini, Mendatang, dan Selesai)
       │
       ├──► [Input Manual (+)] ──► Mengisi form judul, jam, tanggal, kategori
       │                                       │
       │                                       ▼
       ├──► [Input Suara (🎤)] ──► Mengucapkan perintah suara bahasa Indonesia
       │                                       │
       │                                       ▼
       │                          [Ekstraksi AI / Local Fallback]
       │                                       │
       │                                       ▼
       │                          [Lembar Konfirmasi & Edit Jadwal]
       │                                       │
       └───────────────────────────────────────┴─► Simpan ke Database SQLite
                                                               │
                                                               ▼
                                                  [Alarm Notifikasi Presisi]
                                                  (Berdering tepat waktu di Android)
```

1. **Autentikasi Pengguna**: Setiap aktivitas dan pengingat yang dibuat terhubung dengan akun pengguna yang sedang login (`KodePengguna`).
2. **Penyimpanan Lokal Relasional**: Menggunakan SQLite lokal dengan 5 tabel relasional (`pengguna`, `kategori`, `aktivitas`, `pengingat`, `riwayat_pengingat`) sehingga aplikasi dapat berjalan 100% tanpa internet.
3. **Ekstraksi Cerdas Hibrida**: Mengubah bahasa percakapan sehari-hari menjadi format jadwal. Jika server AI aktif, aplikasi menggunakan model Gemini. Jika offline, mesin *Local Heuristic Fallback* di perangkat langsung mengekstrak entitas tanpa error.
4. **Konfirmasi Wajib Pengguna**: Data hasil ekstraksi suara selalu ditampilkan ke pengguna untuk ditinjau atau diedit sebelum benar-benar disimpan ke database.
5. **Alarm Notifikasi Tepat Waktu**: Menggunakan sistem alarm presisi Android (`exactAllowWhileIdle`) yang tetap berdering walaupun layar HP dalam keadaan mati/terkunci.

---

## 👥 Akun Demo Pengguna Bawaan

Saat pertama kali aplikasi dipasang, database SQLite secara otomatis menyediakan 5 akun anggota kelompok yang siap digunakan:

| Nama Anggota | Email | Password | Tombol Cepat di Login |
|---|---|:---:|:---:|
| **Aziz Faadihilah** | `aziz@example.com` | `aziz123` | Chip `Aziz (U0001)` |
| **Gobes** | `gobes@example.com` | `gobes123` | Chip `Gobes (U0002)` |
| **Riandhika** | `riandhika@example.com` | `riandhika123` | Chip `Riandhika (U0003)` |
| **Abied** | `abied@example.com` | `abied123` | Chip `Abied (U0004)` |
| **Sniper** | `sniper@example.com` | `sniper123` | Chip `Sniper (U0005)` |

---

## 🛠️ Software & Tools yang Perlu Diinstall Terlebih Dahulu

Untuk menjalankan dan mengembangkan proyek ini, Anda **hanya perlu menggunakan Visual Studio Code (VS Code)** sebagai editor utama.

### 1. Visual Studio Code (VS Code)
- **Fungsi**: Editor kode utama untuk mengedit, menjalankan, dan mendebug aplikasi.
- **Download**: [code.visualstudio.com](https://code.visualstudio.com/)
- **Ekstensi VS Code yang Wajib Dipasang**:
  Buka tab *Extensions* di VS Code (`Ctrl + Shift + X`), lalu cari dan pasang:
  1. **Flutter** (oleh *Dart Code*)
  2. **Dart** (otomatis terpasang bersama ekstensi Flutter)

### 2. Git for Windows
- **Fungsi**: Untuk mengunduh (*clone*) kode repositori dari GitHub.
- **Download**: [git-scm.com](https://git-scm.com/download/win)

### 3. Flutter SDK
- **Fungsi**: Framework inti untuk kompilasi dan eksekusi aplikasi.
- **Download**: [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
- **Cara Install & Pengaturan PATH Permanen**:
  1. Ekstrak file zip Flutter ke folder tanpa spasi (contoh: `C:\src\flutter`).
  2. Tambahkan `C:\src\flutter\bin` ke **Environment Variables (PATH)** Windows:
     - Cari **"Edit the system environment variables"** di menu Windows.
     - Klik **Environment Variables** > Pada *User Variables*, pilih **Path** > klik **Edit**.
     - Klik **New** > masukkan: `C:\src\flutter\bin` > klik **OK**.
  > 💡 **PENTING**: Setelah menambah PATH, **tutup lalu buka kembali VS Code** agar terminal langsung mengenali perintah `flutter` secara permanen.

### 4. Android SDK Platform Tools (Untuk Menjalankan Aplikasi)
- Menyediakan driver adb dan library Android untuk kompilasi aplikasi.
- *Catatan*: Cukup terpasang di komputer (bawaan Android SDK / Command Line Tools), Anda **tidak perlu membuka Android Studio** saat mengerjakan proyek ini.

---

## 🚀 Panduan Menjalankan Proyek 100% di VS Code

Ikuti langkah-langkah mudah berikut untuk membuka dan menjalankan proyek langsung dari VS Code:

### Langkah 1: Clone Repositori & Buka di VS Code
1. Buka terminal atau Command Prompt:
   ```bash
   git clone https://github.com/Jizuuuu/Aplikasi-Eling.git
   ```
2. Buka folder proyek tersebut di **VS Code**:
   ```bash
   code "Aplikasi-Eling"
   ```
   *(Atau buka VS Code > menu **File** > **Open Folder...** > pilih folder `Aplikasi-Eling`)*.

---

### Langkah 2: Unduh Dependensi Aplikasi
Buka terminal terintegrasi di VS Code dengan menekan tombol keyboard:
**`Ctrl + ` `** (Control + Backtick) atau menu **Terminal** > **New Terminal**, lalu ketik:
```bash
flutter pub get
```

---

### Langkah 3: Jalankan Pengujian Otomatis (*Unit & Widget Test*)
Ketik perintah berikut di terminal VS Code untuk memastikan seluruh fitur lulus uji:
```bash
flutter test
```
*(Hasil yang diharapkan: **All tests passed!** — 12/12 skenario pengujian IMPAL berhasil).*

---

### Langkah 4: Pilih Perangkat Target (Di Pojok Bawah VS Code)

Anda memiliki 2 opsi perangkat untuk menjalankan aplikasi:

#### Opsi A: Menggunakan HP Android Fisik (Paling Disarankan & Sangat Ringan ⭐)
Jika laptop Anda terasa berat saat menjalankan emulator Android, gunakan HP Android fisik:
1. Hubungkan HP Android ke laptop menggunakan kabel data USB.
2. Di HP Android, aktifkan **Opsi Pengembang (Developer Options)** dan centang **USB Debugging**.
3. Di pojok kanan bawah jendela VS Code, nama HP Anda akan langsung muncul otomatis.

#### Opsi B: Menggunakan Emulator Android dari VS Code
Jika ingin menggunakan emulator tanpa membuka Android Studio:
1. Tekan tombol **`Ctrl + Shift + P`** di keyboard untuk membuka Command Palette VS Code.
2. Ketik dan pilih: **`Flutter: Launch Emulator`**.
3. Pilih emulator yang tersedia (contoh: `Pixel_3a_API_34` atau `Pixel 4`).
4. Jendela emulator akan otomatis menyala di layar Anda.

---

### Langkah 5: Jalankan Aplikasi Langsung dari VS Code

Setelah perangkat terhubung atau emulator menyala, jalankan aplikasi dengan salah satu cara berikut:

- **Cara 1 (Tombol Pintas VS Code)**:  
  Cukup tekan tombol **`F5`** pada keyboard (atau menu **Run** > **Start Debugging**).
- **Cara 2 (Via Terminal VS Code)**:  
  Ketik perintah berikut di terminal VS Code:
  ```bash
  flutter run --android-skip-build-dependency-validation
  ```

Aplikasi akan otomatis mengompilasi APK, terpasang di HP/emulator, dan langsung membuka layar **Login**.

---

## 🌐 Menjalankan Server Proxy AI (Opsional)

Aplikasi ELING sudah dilengkapi kecerdasan lokal tanpa perlu internet (*Offline-First*). Jika ingin mencoba integrasi cloud Gemini API:

1. Buka terminal baru di VS Code, masuk ke folder `server`:
   ```bash
   cd server
   npm install
   ```
2. Buat file `.env` di dalam folder `server/`:
   ```env
   PORT=3000
   GEMINI_API_KEY=masukkan_api_key_gemini_anda_disini
   ```
3. Jalankan server:
   ```bash
   node index.js
   ```

---

## 📚 Berkas Dokumentasi Terkait
- Laporan Pengujian Formal IMPAL: [docs/PENGUJIAN_IMPAL.md](docs/PENGUJIAN_IMPAL.md)
- Dokumentasi Arsitektur, Skema DB 5 Tabel, & Analisis Pengembangan: [docs/DOKUMENTASI_APLIKASI.md](docs/DOKUMENTASI_APLIKASI.md)
- Berkas DDL/DML Basis Data: [database/db_eling.sql](database/db_eling.sql)
