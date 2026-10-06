// Daftar sewa alat & wahana (sumber: desain "Sewa & Booking Wahana" dan "Wahana & Harga").
// Tahap backend: ganti dengan data dari API, bentuk objeknya dipertahankan.
export const WAHANA = [
  { id: "ban-kecil", name: "Ban Kecil/Sedang", category: "Sewa Alat", price: 5000, unit: "", icon: "ring", status: "Aktif" },
  { id: "ban-besar", name: "Ban Besar", category: "Sewa Alat", price: 10000, unit: "", icon: "ring-big", status: "Aktif" },
  { id: "loker", name: "Loker", category: "Sewa Alat", price: 5000, unit: "", icon: "locker", status: "Aktif" },
  { id: "kereta-sawah", name: "Kereta Sawah", category: "Wahana", price: 10000, unit: "kepala", icon: "train", status: "Aktif" },
  { id: "bebek-gayung", name: "Bebek Gayung", category: "Wahana", price: 20000, unit: "perahu", icon: "duck", status: "Aktif" },
  { id: "atv", name: "ATV", category: "Wahana", price: 25000, unit: "15 menit", icon: "atv", status: "Aktif" },
  { id: "flying-fox", name: "Flying Fox", category: "Wahana", price: 15000, unit: "", icon: "flyingfox", status: "Aktif" },
  { id: "komedi-putar", name: "Komedi Putar Anak", category: "Wahana", price: 10000, unit: "", icon: "carousel", status: "Aktif" },
];

// Nama seperti di layar booking mobile: "Kereta Sawah (per kepala)", "ATV (15 menit)".
export function bookingLabel(item) {
  if (!item.unit) return item.name;
  return item.unit.includes("menit") ? `${item.name} (${item.unit})` : `${item.name} (per ${item.unit})`;
}

export const SLOTS = [
  { id: "08-10", label: "08–10", range: "08.00 – 10.00", busy: false },
  { id: "10-12", label: "10–12", range: "10.00 – 12.00", busy: true },
  { id: "12-14", label: "12–14", range: "12.00 – 14.00", busy: true },
  { id: "14-16", label: "14–16", range: "14.00 – 16.00", busy: true },
];
