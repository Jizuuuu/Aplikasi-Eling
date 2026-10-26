require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// System Instruction untuk parsing input suara bahasa Indonesia menjadi pengingat terstruktur
const SYSTEM_INSTRUCTION = `
Kamu adalah asisten ekstraksi data pengingat (reminder) pintar untuk aplikasi Android "ELING".
Tugasmu adalah menganalisis teks ucapan bahasa Indonesia pengguna dan mengekstrak entitas berikut ke dalam format JSON murni:
1. "title": Judul aktivitas yang ringkas dan jelas (Bahasa Indonesia).
2. "description": Catatan tambahan jika ada (atau null jika tidak ada).
3. "remind_at": Tanggal dan waktu pengingat dalam format ISO-8601 lengkap dengan timezone offset (misal: "2026-10-25T14:00:00+07:00").
4. "category": Salah satu dari: ["Kuliah", "Tugas", "Pribadi", "Belanja", "Lainnya"].

Aturan interpretasi waktu Indonesia:
- Hitung waktu berdasarkan "user_local_time" yang diberikan pada request.
- "pagi": 05:00 - 11:00
- "siang": 11:30 - 14:30
- "sore": 15:00 - 18:00
- "malam": 18:30 - 22:00
- "besok": hari berikutnya (+1 hari dari user_local_time).
- "lusa": dua hari berikutnya (+2 hari dari user_local_time).
- "setengah [X]": Jika "setengah 8 pagi" = 07:30. "setengah 3 siang" = 14:30.
- Jika pengguna tidak menyebutkan jam secara spesifik, tentukan jam wajar (default 09:00 untuk pagi, 14:00 untuk siang, 19:00 untuk malam).
- Jika pengguna tidak menyebutkan hari, asumsikan hari ini (jika jam belum lewat) atau besok.

Format respon HARUS HANYA JSON MURNI tanpa markdown block (\`\`\`json). Contoh:
{
  "title": "Kumpul Tugas IMPAL",
  "description": null,
  "remind_at": "2026-10-25T14:00:00+07:00",
  "category": "Tugas"
}
`;

app.post('/api/parse-reminder', async (req, res) => {
  try {
    const { text, user_local_time } = req.body;

    if (!text || text.trim() === '') {
      return res.status(400).json({ error: 'Field "text" tidak boleh kosong.' });
    }

    const referenceTime = user_local_time || new Date().toISOString();

    // Jika GEMINI_API_KEY belum dikonfigurasi, sediakan Smart Heuristic Fallback
    // agar aplikasi tetap dapat diuji coba oleh mahasiswa tanpa kendala
    if (!GEMINI_API_KEY) {
      console.warn('GEMINI_API_KEY belum diisi di .env. Menggunakan Intelligent Local Fallback.');
      const fallbackResult = generateLocalFallback(text, referenceTime);
      return res.json(fallbackResult);
    }

    // Panggilan ke Google Gemini API v1beta
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: `${SYSTEM_INSTRUCTION}\n\nWaktu lokal pengguna saat ini: ${referenceTime}\nInput ucapan pengguna: "${text}"`,
                },
              ],
            },
          ],
          generationConfig: {
            temperature: 0.1,
            responseMimeType: 'application/json',
          },
        }),
      }
    );

    if (!response.ok) {
      const errText = await response.text();
      console.error('Gemini API Error:', errText);
      return res.status(502).json({ error: 'Gagal memproses data dari LLM API.' });
    }

    const data = await response.json();
    const rawContent = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!rawContent) {
      throw new Error('Respon kosong dari AI.');
    }

    const parsedJson = JSON.parse(rawContent.trim());
    return res.json(parsedJson);
  } catch (error) {
    console.error('Error saat parsing reminder:', error);
    return res.status(500).json({
      error: 'Terjadi kesalahan pada server proxy.',
      details: error.message,
    });
  }
});

// Fallback cerdas berbasis kata kunci bahasa Indonesia
function generateLocalFallback(text, referenceTimeStr) {
  const refDate = new Date(referenceTimeStr);
  const lower = text.toLowerCase();

  let targetDate = new Date(refDate.getTime());
  let category = 'Lainnya';

  // Deteksi hari
  if (lower.includes('besok')) {
    targetDate.setDate(targetDate.getDate() + 1);
  } else if (lower.includes('lusa')) {
    targetDate.setDate(targetDate.getDate() + 2);
  }

  // Deteksi kategori
  if (lower.includes('tugas') || lower.includes('pr') || lower.includes('proyek')) {
    category = 'Tugas';
  } else if (lower.includes('kuliah') || lower.includes('dosen') || lower.includes('kelas') || lower.includes('matkul')) {
    category = 'Kuliah';
  } else if (lower.includes('beli') || lower.includes('belanja') || lower.includes('pasar')) {
    category = 'Belanja';
  } else if (lower.includes('olahraga') || lower.includes('makan') || lower.includes('tidur')) {
    category = 'Pribadi';
  }

  // Deteksi jam dasar
  let hour = 9;
  if (lower.includes('siang')) hour = 13;
  if (lower.includes('sore')) hour = 16;
  if (lower.includes('malam')) hour = 19;

  // Cek angka jam (misal: "jam 2 siang")
  const hourMatch = lower.match(/jam\s+(\d{1,2})/);
  if (hourMatch) {
    let parsedHour = parseInt(hourMatch[1], 10);
    if ((lower.includes('siang') || lower.includes('sore') || lower.includes('malam')) && parsedHour < 12) {
      parsedHour += 12;
    }
    hour = parsedHour;
  }

  targetDate.setHours(hour, 0, 0, 0);

  // Bersihkan judul dari kata perintah
  let title = text
    .replace(/^(ingatkan|tolong ingatkan|ingatkan saya|jadwalkan)\s+/i, '')
    .trim();
  title = title.charAt(0).toUpperCase() + title.slice(1);

  return {
    title: title || 'Aktivitas Baru',
    description: `Dibuat via Input Suara: "${text}"`,
    remind_at: targetDate.toISOString(),
    category: category,
  };
}

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[ELING AI Proxy] Server berjalan di http://localhost:${PORT}`);
  console.log(`Endpoint: POST http://localhost:${PORT}/api/parse-reminder`);
});
