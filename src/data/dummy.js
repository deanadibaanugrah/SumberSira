// Data contoh untuk tahap UTS (frontend). Semua angka/teks diambil dari desain Figma.
// Tahap backend: ganti setiap konstanta di sini dengan data dari API.

// Keramaian per jam (persen kapasitas, skala 0–100) — dipakai Home dan Live Crowd (aplikasi mobile).
// Nilai dibaca dari posisi titik grafik di desain Live Crowd Tracker.
export const CROWD_TODAY = [
  { hour: "08", value: 15 },
  { hour: "10", value: 50 },
  { hour: "12", value: 90 },
  { hour: "14", value: 85 },
  { hour: "16", value: 40 },
  { hour: "18", value: 15 },
];

// Jumlah pengunjung per jam untuk grafik "Live Crowd Monitor" di dashboard admin.
// Ditulis per jam agar label waktu lebih jelas di dashboard.
export const VISITORS_TODAY = [
  { label: "08:00", value: 40 },
  { label: "09:00", value: 52 },
  { label: "10:00", value: 60 },
  { label: "11:00", value: 78 },
  { label: "12:00", value: 94 },
  { label: "13:00", value: 108 },
  { label: "14:00", value: 120 },
  { label: "15:00", value: 112 },
  { label: "16:00", value: 101 },
];

export const CROWD_NOW = { percent: 62, label: "Sedang", updated: "2 menit lalu" };

// Prediksi admin (AI Insight): per jam 08–16, jam sibuk 10.00–14.00 disorot.
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

export const STATS = [
  { label: "Booking Sewa Hari Ini", value: "24", note: "+12% dari kemarin", dot: "leaf" },
  { label: "Wahana Terlaris", value: "ATV", note: "25 booking minggu ini", dot: "forest" },
  { label: "Tingkat Keramaian", value: "Sedang", note: "62% kapasitas", dot: "forest" },
  { label: "Rating Ulasan AI", value: "4.8/5", note: "dari 132 ulasan", dot: "leaf" },
];

export const BOOKINGS = [
  { id: 1, name: "Bu Rani S.", items: "2x Ban Besar, 1x Loker", qty: "3 item", time: "10:00", status: "Baru" },
  { id: 2, name: "Dimas P.", items: "ATV 15 menit", qty: "1 orang", time: "10:15", status: "Diproses" },
  { id: 3, name: "Bpk. Yono W.", items: "Flying Fox", qty: "1 orang", time: "09:50", status: "Selesai" },
  { id: 4, name: "Kel. Ahmad", items: "Bebek Gayung x2", qty: "2 perahu", time: "11:00", status: "Baru" },
  { id: 5, name: "Rombongan SMA X", items: "Kereta Sawah x6", qty: "6 orang", time: "09:40", status: "Selesai" },
  { id: 6, name: "Ibu Sari K.", items: "Ban Kecil x3", qty: "3 item", time: "11:20", status: "Diproses" },
];

export const INCOMING = [
  { label: "ATV — 10:30", status: "Baru" },
  { label: "Ban Besar x2 — 10:15", status: "Diproses" },
  { label: "Flying Fox — 09:50", status: "Selesai" },
  { label: "Kereta Sawah x4 — 09:40", status: "Selesai" },
];

export const AI_NOTIFICATIONS = [
  "Prediksi lonjakan pengunjung jam 11.00–13.00",
  "5 ulasan baru perlu ditinjau",
  "Stok ban besar tersisa 3 unit",
];

export const FEEDBACK = [
  { label: "Positif", value: 75, color: "bg-leaf", text: "text-ink" },
  { label: "Netral", value: 18, color: "bg-forest", text: "text-leaf" },
  { label: "Negatif", value: 7, color: "bg-coral", text: "text-coral" },
];

export const COMPLAINT_TAGS = [
  { label: "Jalan terjal", count: 128 },
  { label: "Kurang toilet", count: 94 },
  { label: "Kurang tempat duduk", count: 76 },
];

export const GALLERY = [
  { id: 1, owner: "Bu Rani S.", src: "/images/galeri-1.webp", status: "Baru" },
  { id: 2, owner: "Joko Didi", src: "/images/galeri-2.webp", status: "Ditampilkan" },
  { id: 3, owner: "Kel. Ahmad", src: "/images/galeri-3.webp", status: "Ditampilkan" },
  { id: 4, owner: "Rombongan SMA X", src: "/images/galeri-4.webp", status: "Baru" },
  { id: 5, owner: "Ibu Sari K.", src: "/images/galeri-5.webp", status: "Ditolak" },
  { id: 6, owner: "Dimas P.", src: "/images/galeri-6.webp", status: "Ditampilkan" },
  { id: 7, owner: "Bu Rani S.", src: "/images/galeri-7.webp", status: "Baru" },
  { id: 8, owner: "Kel. Ahmad", src: "/images/galeri-8.webp", status: "Ditampilkan" },
];

// Angka total galeri di desain (312 masuk, 18 menunggu, 248 tampil) mencakup foto lama di luar 8 contoh ini.
export const GALLERY_TOTALS = { masuk: 312, menunggu: 18, tampil: 248 };

export const FAQ = [
  { id: 1, q: "Jam buka Sumber Sira weekday & weekend?", a: "Weekday 08.00–16.00, weekend 08.00–17.00." },
  { id: 2, q: "Berapa harga tiket masuk?", a: "Rp5.000 per orang, untuk usia 3 tahun ke atas." },
  { id: 3, q: "Apakah bisa bayar pakai QRIS?", a: "Bisa. Pembayaran tersedia tunai dan QRIS." },
  { id: 4, q: "Fasilitas apa saja yang termasuk HTM?", a: "Kolam mata air, kolam anak, gazebo, dan area foto." },
  { id: 5, q: "Bagaimana cara sewa ATV?", a: "Buka menu Sewa & Booking, pilih jam, tambah ATV (15 menit), lalu konfirmasi." },
  { id: 6, q: "Apakah ada tempat parkir bus?", a: "Ada. Parkir motor 3rb, mobil 10rb, bus 20rb." },
];

export const UNANSWERED = [
  { id: 101, q: "Apakah boleh bawa makanan dari luar?" },
  { id: 102, q: "Ada spot foto yang teduh gak?" },
  { id: 103, q: "Kalau hujan tetap buka?" },
  { id: 104, q: "Ada penyewaan payung/tikar?" },
  { id: 105, q: "Anak di bawah 3 tahun bayar gak?" },
];

export const REVIEWS = [
  { id: 1, name: "Bu Rani S.", stars: 5, text: "Airnya jernih banget, anak-anak senang main di kolam!" },
  { id: 2, name: "Dimas P.", stars: 4, text: "Spot foto oke, tapi pas siang rame banget." },
  { id: 3, name: "Kel. Ahmad", stars: 5, text: "Sewa ATV gampang lewat app, ga perlu antre." },
];
