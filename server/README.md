# ELING — AI Proxy Server (Keamanan API Key)

Server proxy ini bertugas mengamankan API Key LLM (Google Gemini) agar **TIDAK PERNAH terekspos di dalam aplikasi Android / file APK**.

## Cara Menjalankan di Komputer Lokal:
1. Masuk ke folder server:
   ```bash
   cd server
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Buat file `.env` dari contoh `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Lalu masukkan `GEMINI_API_KEY` milikmu (gratis dari https://aistudio.google.com/app/apikey).
   *(Catatan: Jika API key belum diisi, server tetap berfungsi menggunakan Intelligent Fallback otomatis).*

4. Jalankan server:
   ```bash
   npm start
   ```
   Server akan aktif di `http://localhost:3000`.

## Catatan IP untuk Android Emulator / HP Fisik:
- **Android Emulator**: Akses server di `http://10.0.2.2:3000` (alamat loopback host Android Emulator).
- **HP Fisik (USB Debugging / WiFi sama)**: Gunakan IP lokal laptop (misal: `http://192.168.1.15:3000`).
