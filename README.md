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

Sebelum menjalankan proyek ini, pastikan perangkat komputer Anda sudah menginstal aplikasi dan peralatan pendukung berikut:

### 1. Git for Windows
- **Fungsi**: Untuk mengunduh (*clone*) kode sumber dari GitHub dan mengelola versi kode.
- **Download**: [git-scm.com](https://git-scm.com/download/win)

### 2. Flutter SDK (Versi 3.24+ atau 3.27+)
- **Fungsi**: Framework utama pembuat aplikasi mobile.
- **Download**: [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
- **Cara Install**:
  1. Ekstrak file zip Flutter ke folder bebas spasi (disarankan: `C:\src\flutter`).
  2. **Daftarkan ke Windows PATH secara permanen**:
     - Buka menu Windows > cari **"Edit the system environment variables"** (atau "Edit environment variables for your account").
     - Klik tombol **Environment Variables**.
     - Di bagian *User variables* atau *System variables*, cari variabel **Path** > klik **Edit**.
     - Klik **New** > masukkan path: `C:\src\flutter\bin`.
     - Klik **OK** hingga semua jendela tertutup.
     > 💡 **PENTING**: Setelah menambahkan PATH, **restart aplikasi editor Anda (tutup lalu buka kembali VS Code / Antigravity IDE)** agar terminal langsung mengenali perintah `flutter` secara permanen tanpa perlu mengatur path berulang kali!

### 3. Android Studio & Android SDK
- **Fungsi**: Menyediakan SDK Android, compiler Gradle, dan Emulator ponsel virtual.
- **Download**: [developer.android.com/studio](https://developer.android.com/studio)
- **Komponen yang wajib dipasang via SDK Manager (di Android Studio):**
  - **SDK Platforms**: Centang `Android 14.0 ("UpsideDownCake") - API 34` dan `Android API 36`.
  - **SDK Tools**: 
    - `Android SDK Build-Tools`
    - `Android SDK Command-line Tools (latest)`
    - `Android SDK Platform-Tools`
    - `Android Emulator`
- **Membuat Emulator Android**:
  - Buka *Device Manager* di Android Studio > Buat Virtual Device baru (misal: **Pixel 3a API 34** atau **Pixel 7**).

### 4. Java Development Kit (JDK 17 atau 21)
- Android Studio sudah menyertakan Java (JetBrains Runtime `jbr`). 
- Jika diperlukan secara terpisah: [Adoptium Eclipse Temurin JDK 17](https://adoptium.net/temurin/releases/?version=17).

### 5. Node.js (Opsional — Hanya untuk Proxy Server AI Cloud)
- **Fungsi**: Hanya diperlukan jika Anda ingin menjalankan server backend AI Gemini di komputer lokal.
- **Download**: [nodejs.org](https://nodejs.org/) (Pilih versi LTS).

---

## 🚀 Panduan Menjalankan Hasil Clone dari GitHub

Jika Anda atau anggota tim baru saja meng-clone repositori ini dari GitHub, ikuti langkah-langkah berikut:

### Langkah 1: Clone Repositori & Buka Direktori
Buka terminal (PowerShell / Command Prompt / Git Bash):
```bash
git clone <URL_REPOSITORI_GITHUB_ANDA>
cd "Aplikasi Eling"
```

### Langkah 2: Periksa Kesiapan Lingkungan (*Flutter Doctor*)
Jalankan perintah berikut untuk memastikan Flutter dan Android SDK terdeteksi:
```bash
flutter doctor
```
*(Pastikan Flutter dan Android toolchain bertanda centang hijau).*

### Langkah 3: Unduh Dependensi Paket Aplikasi
Jalankan perintah berikut untuk mengunduh semua library Flutter yang terdaftar di `pubspec.yaml`:
```bash
flutter pub get
```

### Langkah 4: Jalankan Pengujian Otomatis (*Unit & Widget Testing*)
Pastikan semua logika bisnis dan model data lulus uji sebelum dijalankan ke perangkat:
```bash
flutter test
```
*(Hasil yang diharapkan: **All tests passed!** — 12/12 test case lulus).*

### Langkah 5: Nyalakan Emulator atau Sambungkan HP Android
- **Menyalakan Emulator dari Terminal**:
  ```bash
  flutter emulators --launch Pixel_3a_API_34
  ```
  *(Atau jalankan emulator langsung dari tombol play di Android Studio Device Manager)*.
- **Periksa Perangkat yang Terhubung**:
  ```bash
  flutter devices
  ```

### Langkah 6: Jalankan Aplikasi
Jalankan aplikasi ke emulator atau HP fisik Anda:
```bash
flutter run --android-skip-build-dependency-validation
```

Aplikasi akan otomatis mengompilasi APK, menginstal ke emulator/HP, dan membuka layar **Login**.

---

## 🌐 Menjalankan Server Proxy AI (Opsional)

Aplikasi sudah memiliki fitur kecerdasan lokal (*offline parser*) tanpa butuh internet. Namun jika Anda ingin menghubungkannya ke model Google Gemini secara live di cloud:

1. Buka terminal baru dan masuk ke folder `server`:
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
