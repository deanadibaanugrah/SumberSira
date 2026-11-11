// Data contoh untuk tahap UTS (frontend). Semua angka/teks diambil dari desain Figma.
// Tahap backend: ganti setiap konstanta di sini dengan data dari API.
import { FOTO } from "@/lib/foto";

// Kartu ringkasan dashboard (ikonnya dipilih di halaman).
export const STATS = [
  { label: "Booking Sewa Hari Ini", value: "24", note: "+12% dari kemarin", trend: "+12%" },
  { label: "Wahana Terlaris", value: "ATV", note: "25 booking minggu ini" },
  { label: "Tingkat Keramaian", value: "Sedang", note: "62% kapasitas" },
  { label: "Tiket Terjual Hari Ini", value: "0", note: "" }, // kartu ini memakai angka live: TiketTerjualStat
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

// Foto galeri memakai foto asli Sumber Sira dengan potongan berbeda (pos = object-position).
export const GALLERY = [
  { id: 1, owner: "Bu Rani S.", src: FOTO.heroSawah, pos: "50% 50%", status: "Baru", date: "2026-10-10" },
  { id: 2, owner: "Joko Didi", src: FOTO.airJernih, pos: "50% 45%", status: "Ditampilkan", date: "2026-10-10" },
  { id: 3, owner: "Kel. Ahmad", src: FOTO.sawah, pos: "50% 60%", status: "Ditampilkan", date: "2026-10-09" },
  { id: 4, owner: "Rombongan SMA X", src: FOTO.keretaSawah, pos: "50% 40%", status: "Baru", date: "2026-10-09" },
  { id: 5, owner: "Ibu Sari K.", src: FOTO.keretaSawah, pos: "50% 70%", status: "Ditolak", date: "2026-10-08" },
  { id: 6, owner: "Dimas P.", src: FOTO.airJernih, pos: "50% 80%", status: "Ditampilkan", date: "2026-10-08" },
  { id: 7, owner: "Bu Rani S.", src: FOTO.sawah, pos: "20% 80%", status: "Baru", date: "2026-10-07" },
  { id: 8, owner: "Kel. Ahmad", src: FOTO.splash, pos: "50% 74%", status: "Ditampilkan", date: "2026-10-07" },
];

// Angka total galeri di desain (312 masuk, 18 menunggu, 248 tampil) mencakup foto lama di luar 8 contoh ini.
export const GALLERY_TOTALS = { masuk: 312, menunggu: 18, tampil: 248 };

// Wahana paling banyak dipesan minggu ini (id merujuk src/data/wahana.js).
export const WAHANA_POPULER = [
  { id: "atv", count: 25 },
  { id: "ban-besar", count: 22 },
  { id: "kereta-sawah", count: 18 },
  { id: "bebek-gayung", count: 14 },
  { id: "flying-fox", count: 11 },
];

// Pendapatan 7 hari terakhir (rupiah): tiket masuk + parkir, dan sewa alat + wahana.
export const PENDAPATAN_MINGGU = {
  change: "+8% dari minggu lalu",
  days: [
    { day: "Sen", tiket: 420000, sewa: 610000 },
    { day: "Sel", tiket: 380000, sewa: 540000 },
    { day: "Rab", tiket: 450000, sewa: 650000 },
    { day: "Kam", tiket: 470000, sewa: 700000 },
    { day: "Jum", tiket: 560000, sewa: 820000 },
    { day: "Sab", tiket: 1240000, sewa: 1850000 },
    { day: "Min", tiket: 1360000, sewa: 2010000 },
  ],
};
