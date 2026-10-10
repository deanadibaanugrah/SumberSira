// Data contoh untuk tahap UTS (frontend). Semua angka/teks diambil dari desain Figma.
// Tahap backend: ganti setiap konstanta di sini dengan data dari API.

// Keramaian per jam (persen kapasitas, skala 0-100), dipakai Home dan Live Crowd (aplikasi mobile).
// Nilai dibaca dari posisi titik grafik di desain Live Crowd Tracker.
export const CROWD_TODAY = [
  { hour: "08", value: 15 },
  { hour: "10", value: 50 },
  { hour: "12", value: 90 },
  { hour: "14", value: 85 },
  { hour: "16", value: 40 },
  { hour: "18", value: 15 },
];

// Jumlah pengunjung per jam untuk grafik "Live Crowd Monitor" di dashboard admin (dibaca dari desain).
export const VISITORS_TODAY = [
  { label: "08.00", value: 40 },
  { label: "10.00", value: 60 },
  { label: "12.00", value: 94 },
  { label: "14.00", value: 120 },
  { label: "16.00", value: 101 },
  { label: "18.00", value: 52 },
];
// Jam yang dihitung ramai (batang Hijau Tua).
export const BUSY_HOURS = ["12.00", "14.00", "16.00"];

export const CROWD_NOW = { percent: 62, label: "Sedang", updated: "2 menit lalu" };

// Prediksi admin (AI Insight): per jam 08-16 untuk besok, jam ramai 10.00 - 14.00 disorot.
export const CROWD_FORECAST = [
  { hour: "08", value: 10 },
  { hour: "09", value: 20 },
  { hour: "10", value: 45 },
  { hour: "11", value: 75 },
  { hour: "12", value: 95 },
  { hour: "13", value: 90 },
  { hour: "14", value: 80 },
  { hour: "15", value: 40 },
  { hour: "16", value: 15 },
];

export const FORECAST_SUMMARY = {
  day: "Minggu 11 Okt",
  busyRange: "10.00 - 14.00",
  peakHour: "12.00",
  peakPercent: 95,
  tip: "Buka loket sewa tambahan mulai 09.45",
};

// Kartu ringkasan dashboard (ikonnya dipilih di halaman).
export const STATS = [
  { label: "Booking Sewa Hari Ini", value: "24", note: "+12% dari kemarin", trend: "+12%" },
  { label: "Wahana Terlaris", value: "ATV", note: "25 booking minggu ini" },
  { label: "Tingkat Keramaian", value: "Sedang", note: "62% kapasitas" },
  { label: "Rating Ulasan AI", value: "4.8/5", note: "dari 132 ulasan" },
];

// Detail tiap booking. lines merujuk id di src/data/wahana.js; harga dihitung dari katalog.
export const BOOKINGS = [
  { id: 1, name: "Bu Rani S.", items: "2x Ban Besar, 1x Loker", qty: "3 item", time: "10:00", status: "Baru",
    code: "SS-20261010-024", orderedAt: "08.12", visit: "10.00 - 12.00, Sabtu 10 Okt", phone: "0812-xxxx-1234",
    lines: [{ id: "ban-besar", qty: 2 }, { id: "loker", qty: 1 }], payment: "QRIS · Lunas" },
  { id: 2, name: "Dimas P.", items: "ATV 15 menit", qty: "1 orang", time: "10:15", status: "Diproses",
    code: "SS-20261010-025", orderedAt: "08.40", visit: "10.00 - 12.00, Sabtu 10 Okt", phone: "0857-xxxx-2210",
    lines: [{ id: "atv", qty: 1 }], payment: "Tunai · Bayar di lokasi" },
  { id: 3, name: "Bpk. Yono W.", items: "Flying Fox", qty: "1 orang", time: "09:50", status: "Selesai",
    code: "SS-20261010-019", orderedAt: "07.55", visit: "08.00 - 10.00, Sabtu 10 Okt", phone: "0813-xxxx-7781",
    lines: [{ id: "flying-fox", qty: 1 }], payment: "QRIS · Lunas" },
  { id: 4, name: "Kel. Ahmad", items: "Bebek Gayung x2", qty: "2 perahu", time: "11:00", status: "Baru",
    code: "SS-20261010-026", orderedAt: "09.05", visit: "10.00 - 12.00, Sabtu 10 Okt", phone: "0821-xxxx-4410",
    lines: [{ id: "bebek-gayung", qty: 2 }], payment: "QRIS · Lunas" },
  { id: 5, name: "Rombongan SMA X", items: "Kereta Sawah x6", qty: "6 orang", time: "09:40", status: "Selesai",
    code: "SS-20261010-017", orderedAt: "07.30", visit: "08.00 - 10.00, Sabtu 10 Okt", phone: "0812-xxxx-9902",
    lines: [{ id: "kereta-sawah", qty: 6 }], payment: "Tunai · Lunas" },
  { id: 6, name: "Ibu Sari K.", items: "Ban Kecil x3", qty: "3 item", time: "11:20", status: "Diproses",
    code: "SS-20261010-027", orderedAt: "09.21", visit: "10.00 - 12.00, Sabtu 10 Okt", phone: "0838-xxxx-5126",
    lines: [{ id: "ban-kecil", qty: 3 }], payment: "QRIS · Lunas" },
];

// Angka total di desain Booking (24 hari ini) mencakup booking di luar 6 contoh ini.
export const BOOKING_TOTALS = { hariIni: 24, menunggu: 7, diproses: 5, selesai: 12 };

// Kartu "Insight AI" di dashboard. icon: trend | chat | box.
export const AI_NOTIFICATIONS = [
  { title: "Prediksi lonjakan pengunjung", sub: "Jam 11.00-13.00, siapkan petugas", icon: "trend" },
  { title: "5 ulasan baru perlu ditinjau", sub: "Ringkasan sentimen ada di AI Insight", icon: "chat" },
  { title: "Stok ban besar tersisa 3 unit", sub: "Tambah stok sebelum akhir pekan", icon: "box" },
];

export const SENTIMENT = [
  { label: "Positif", value: 75, color: "#1b4332" },
  { label: "Netral", value: 18, color: "rgba(64, 145, 108, 0.4)" },
  { label: "Negatif", value: 7, color: "#e07a5f" },
];
export const REVIEW_COUNT = { total: 132, period: "7 hari terakhir" };

export const COMPLAINT_TAGS = [
  { label: "Jalan terjal", count: 128 },
  { label: "Kurang toilet", count: 94 },
  { label: "Kurang tempat duduk", count: 76 },
];
export const COMPLAINT_TIP = "Saran AI: perbaiki jalur masuk dan tambah toilet sebelum musim liburan";

// Foto galeri memakai foto asli Sumber Sira dengan potongan berbeda (pos = object-position).
export const GALLERY = [
  { id: 1, owner: "Bu Rani S.", src: "/images/hero-sawah.webp", pos: "50% 50%", status: "Baru", date: "2026-10-10" },
  { id: 2, owner: "Joko Didi", src: "/images/onboarding-air-jernih.webp", pos: "50% 45%", status: "Ditampilkan", date: "2026-10-10" },
  { id: 3, owner: "Kel. Ahmad", src: "/images/sawah-sumber-sira.webp", pos: "50% 60%", status: "Ditampilkan", date: "2026-10-09" },
  { id: 4, owner: "Rombongan SMA X", src: "/images/onboarding-kereta-sawah.webp", pos: "50% 40%", status: "Baru", date: "2026-10-09" },
  { id: 5, owner: "Ibu Sari K.", src: "/images/onboarding-kereta-sawah.webp", pos: "50% 70%", status: "Ditolak", date: "2026-10-08" },
  { id: 6, owner: "Dimas P.", src: "/images/onboarding-air-jernih.webp", pos: "50% 80%", status: "Ditampilkan", date: "2026-10-08" },
  { id: 7, owner: "Bu Rani S.", src: "/images/sawah-sumber-sira.webp", pos: "20% 80%", status: "Baru", date: "2026-10-07" },
  { id: 8, owner: "Kel. Ahmad", src: "/images/splash-sumber-sira.webp", pos: "50% 74%", status: "Ditampilkan", date: "2026-10-07" },
];

// Angka total galeri di desain (312 masuk, 18 menunggu, 248 tampil) mencakup foto lama di luar 8 contoh ini.
export const GALLERY_TOTALS = { masuk: 312, menunggu: 18, tampil: 248 };

export const FAQ = [
  { id: 1, q: "Jam buka Sumber Sira weekday & weekend?", a: "Weekday 08.00-16.00, weekend 08.00-17.00." },
  { id: 2, q: "Berapa harga tiket masuk?", a: "Rp5.000 per orang, untuk usia 3 tahun ke atas." },
  { id: 3, q: "Apakah bisa bayar pakai QRIS?", a: "Bisa. Pembayaran tersedia tunai dan QRIS." },
  { id: 4, q: "Fasilitas apa saja yang termasuk HTM?", a: "Kolam mata air, kolam anak, gazebo, dan musholla." },
  { id: 5, q: "Bagaimana cara sewa ATV?", a: "Buka menu Sewa & Booking, pilih jam, tambah ATV, lalu konfirmasi." },
  { id: 6, q: "Apakah ada tempat parkir bus?", a: "Ada. Parkir motor 3rb, mobil 10rb, bus 20rb." },
];

// asked = berapa kali ditanyakan minggu ini.
export const UNANSWERED = [
  { id: 101, q: "Apakah boleh bawa makanan dari luar?", asked: 4 },
  { id: 102, q: "Ada spot foto yang teduh gak?", asked: 3 },
  { id: 103, q: "Kalau hujan tetap buka?", asked: 3 },
  { id: 104, q: "Ada penyewaan payung atau tikar?", asked: 2 },
  { id: 105, q: "Anak di bawah 3 tahun bayar gak?", asked: 2 },
];

// Persentase pertanyaan pengunjung yang dijawab otomatis oleh Tanya Sira.
export const FAQ_AUTO_RATE = 92;

export const REVIEWS = [
  { id: 1, name: "Bu Rani S.", stars: 5, text: "Airnya jernih banget, anak-anak senang main di kolam!" },
  { id: 2, name: "Dimas P.", stars: 4, text: "Spot foto oke, tapi pas siang rame banget." },
  { id: 3, name: "Kel. Ahmad", stars: 5, text: "Sewa ATV gampang lewat app, ga perlu antre." },
];
