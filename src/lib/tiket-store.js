"use client";

import { useSyncExternalStore } from "react";

// Tiket masuk online (tahap frontend, belum ada backend).
// Data disimpan di localStorage supaya aplikasi pengunjung dan panel admin di browser yang sama
// memakai data yang sama: tiket dibeli di /app/tiket, discan petugas di /admin/tiket,
// lalu angka Live Crowd langsung ikut berubah (juga di tab lain lewat event "storage").
// Live Crowd = jumlah orang dari tiket yang sudah discan masuk dan belum keluar, dibagi kapasitas.
// Tahap backend: simpan tiket di database dan ganti fungsi-fungsi di bawah dengan panggilan API.

const KEY = "sumber-sira:tiket";
export const KAPASITAS = 300;
export const HARGA_TIKET = 5000;
export const PARKIR = [
  { id: "none", label: "Tidak", price: 0 },
  { id: "motor", label: "Motor", price: 3000 },
  { id: "mobil", label: "Mobil", price: 10000 },
  { id: "bus", label: "Bus", price: 20000 },
];

// Tiket contoh hari ini dari pengunjung lain: [nama, jumlah orang, parkir, jam beli, jam masuk, jam keluar].
// Yang masih di dalam berjumlah 186 orang = 62% kapasitas (Sedang), sama dengan angka di desain.
const SEED_DI_DALAM = [
  ["Bu Rani S.", 4, "mobil", "06.41", "08.12"], ["Dimas P.", 2, "motor", "07.02", "08.15"],
  ["Kel. Ahmad", 6, "mobil", "06.55", "08.21"], ["Rombongan SMA X", 32, "bus", "05.30", "08.30"],
  ["Ibu Sari K.", 3, "motor", "07.20", "08.34"], ["Joko Didi", 2, "motor", "07.48", "08.40"],
  ["Bpk. Yono W.", 1, "motor", "08.01", "08.44"], ["Kel. Hartono", 5, "mobil", "07.12", "08.52"],
  ["Mbak Lia", 2, "motor", "08.10", "08.57"], ["Rombongan TK Pelangi", 24, "bus", "06.15", "09.03"],
  ["Kel. Wijaya", 4, "mobil", "08.05", "09.08"], ["Mas Bayu", 2, "motor", "08.31", "09.11"],
  ["Kel. Susanto", 5, "mobil", "08.12", "09.16"], ["Rina A.", 3, "motor", "08.40", "09.20"],
  ["Kel. Prasetyo", 6, "mobil", "08.22", "09.26"], ["Komunitas Gowes Malang", 12, "none", "07.30", "09.31"],
  ["Kel. Nugroho", 4, "mobil", "08.47", "09.35"], ["Sinta dan teman", 3, "motor", "09.00", "09.38"],
  ["Kel. Darmawan", 5, "mobil", "08.58", "09.42"], ["Pak Hadi", 2, "motor", "09.10", "09.47"],
  ["Kel. Sutrisno", 6, "mobil", "09.02", "09.51"], ["Dewi L.", 2, "motor", "09.21", "09.55"],
  ["Kel. Rahman", 4, "mobil", "09.18", "10.01"], ["Rombongan Karang Taruna", 18, "bus", "08.00", "10.06"],
  ["Kel. Santoso", 5, "mobil", "09.33", "10.12"], ["Fajar M.", 2, "motor", "09.45", "10.17"],
  ["Kel. Kurniawan", 4, "mobil", "09.40", "10.21"], ["Rombongan Arisan RT 03", 0, "bus", "09.20", "10.26"],
];
const SEED_BELUM_MASUK = [
  ["Kel. Hidayat", 4, "mobil", "09.50"], ["Andi S.", 2, "motor", "10.02"], ["Kel. Firmansyah", 6, "mobil", "10.08"],
  ["Rombongan PKK Putukrejo", 15, "bus", "10.11"], ["Nadia R.", 3, "motor", "10.19"],
];
const SEED_KELUAR = [
  ["Kel. Saputra", 5, "mobil", "06.30", "07.58", "09.40"], ["Bagas W.", 2, "motor", "07.05", "08.03", "09.52"],
  ["Kel. Lestari", 4, "mobil", "07.10", "08.07", "10.05"], ["Pak Darto", 3, "motor", "07.25", "08.10", "10.14"],
];

function seedTickets() {
  // Jumlah orang tiket terakhir di dalam diisi agar totalnya tepat 186.
  const rows = SEED_DI_DALAM.map((r) => [...r]);
  rows[rows.length - 1][1] = 186 - rows.slice(0, -1).reduce((sum, r) => sum + r[1], 0);
  const make = (status) => ([name, people, parking, boughtAt, checkInAt = null, checkOutAt = null]) => {
    const kids = people >= 4 && parking === "mobil" ? 1 : 0; // keluarga biasanya membawa balita (gratis)
    return { name, adults: people - kids, kids, parking, boughtAt, checkInAt, checkOutAt, status, mine: false };
  };
  const all = [...SEED_KELUAR.map(make("Keluar")), ...rows.map(make("Di dalam")), ...SEED_BELUM_MASUK.map(make("Belum masuk"))]
    .sort((a, b) => a.boughtAt.localeCompare(b.boughtAt));
  return all.map((t, i) => ({ ...t, code: `TK-${1001 + i}`, whatsapp: "", total: hargaTiket(t.adults, t.parking) }));
}

export function hargaTiket(adults, parking) {
  return adults * HARGA_TIKET + (PARKIR.find((p) => p.id === parking)?.price ?? 0);
}

export function statusKeramaian(percent) {
  if (percent < 40) return "Sepi";
  if (percent <= 75) return "Sedang";
  return "Ramai";
}

const orang = (t) => t.adults + t.kids;

// Ringkasan untuk Live Crowd, dashboard admin, dan halaman tiket.
export function ringkasan(tickets) {
  const inside = tickets.filter((t) => t.status === "Di dalam").reduce((sum, t) => sum + orang(t), 0);
  const percent = Math.round((inside / KAPASITAS) * 100);
  const waiting = tickets.filter((t) => t.status === "Belum masuk").reduce((sum, t) => sum + orang(t), 0);
  const out = tickets.filter((t) => t.status === "Keluar").reduce((sum, t) => sum + orang(t), 0);
  const recent = tickets.filter((t) => t.checkInAt).sort((a, b) => b.checkInAt.localeCompare(a.checkInAt));
  return { inside, percent, label: statusKeramaian(percent), waiting, out, sold: tickets.length, recent };
}

const tanggalHariIni = () => new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Jakarta" }).format(new Date());
export const jamSekarang = () =>
  new Intl.DateTimeFormat("id-ID", { hour: "2-digit", minute: "2-digit", hour12: false, timeZone: "Asia/Jakarta" }).format(new Date()).replace(":", ".");

const fresh = () => ({ date: tanggalHariIni(), updatedAt: null, tickets: seedTickets() });
// Dipakai saat render di server dan saat hydration, supaya angka awal sama dengan di browser.
const SERVER = { date: null, updatedAt: null, tickets: seedTickets() };

const listeners = new Set();
let cache = null;

function load() {
  if (cache) return cache;
  try {
    const parsed = JSON.parse(window.localStorage.getItem(KEY) || "null");
    // Data berganti setiap hari: tiket kemarin tidak dihitung di Live Crowd hari ini.
    cache = parsed && parsed.date === tanggalHariIni() && Array.isArray(parsed.tickets) ? parsed : fresh();
  } catch {
    cache = fresh();
  }
  return cache;
}

function save(next) {
  cache = next;
  try {
    window.localStorage.setItem(KEY, JSON.stringify(next));
  } catch {
    // penyimpanan diblokir (mode privat): data tetap jalan selama halaman terbuka
  }
  listeners.forEach((l) => l());
}

function subscribe(listener) {
  listeners.add(listener);
  const onStorage = (e) => {
    if (e.key !== KEY) return;
    cache = null; // tab lain mengubah data: baca ulang
    listener();
  };
  window.addEventListener("storage", onStorage);
  return () => {
    listeners.delete(listener);
    window.removeEventListener("storage", onStorage);
  };
}

export function useTiket() {
  const data = useSyncExternalStore(subscribe, load, () => SERVER);
  return { ...data, ...ringkasan(data.tickets), ready: data !== SERVER };
}

// Dibaca langsung (tanpa hook), mis. untuk jawaban chatbot.
export function ringkasanSekarang() {
  return ringkasan(load().tickets);
}

export function normalisasiKode(raw) {
  const text = String(raw || "").toUpperCase().replace(/\s/g, "");
  if (/^\d+$/.test(text)) return `TK-${text}`;
  return text.startsWith("TK") && !text.startsWith("TK-") ? `TK-${text.slice(2)}` : text;
}

export function beliTiket({ name, whatsapp, adults, kids, parking }) {
  const data = load();
  const next = Math.max(1000, ...data.tickets.map((t) => Number(t.code.slice(3)) || 0)) + 1;
  const ticket = {
    code: `TK-${next}`, name: name.trim(), whatsapp: whatsapp.trim(), adults, kids, parking,
    total: hargaTiket(adults, parking), status: "Belum masuk", boughtAt: jamSekarang(), checkInAt: null, checkOutAt: null, mine: true,
  };
  save({ ...data, updatedAt: jamSekarang(), tickets: [...data.tickets, ticket] });
  return ticket;
}

// Scan petugas di pintu masuk. Mengembalikan { ok, message }.
export function checkIn(raw) {
  const code = normalisasiKode(raw);
  const data = load();
  const t = data.tickets.find((x) => x.code === code);
  if (!t) return { ok: false, message: `Kode ${code || "tiket"} tidak ditemukan.` };
  if (t.status === "Di dalam") return { ok: false, message: `${code} sudah dipakai masuk pukul ${t.checkInAt}.` };
  if (t.status === "Keluar") return { ok: false, message: `${code} sudah dipakai, pengunjung keluar pukul ${t.checkOutAt}.` };
  const { inside } = ringkasan(data.tickets);
  if (inside + orang(t) > KAPASITAS) return { ok: false, message: "Kapasitas penuh. Minta pengunjung menunggu sebentar." };
  const now = jamSekarang();
  save({ ...data, updatedAt: now, tickets: data.tickets.map((x) => (x.code === code ? { ...x, status: "Di dalam", checkInAt: now } : x)) });
  return { ok: true, message: `${t.name} (${orang(t)} orang) masuk pukul ${now}.` };
}

export function checkOut(raw) {
  const code = normalisasiKode(raw);
  const data = load();
  const t = data.tickets.find((x) => x.code === code);
  if (!t || t.status !== "Di dalam") return { ok: false, message: `${code} belum tercatat di dalam.` };
  const now = jamSekarang();
  save({ ...data, updatedAt: now, tickets: data.tickets.map((x) => (x.code === code ? { ...x, status: "Keluar", checkOutAt: now } : x)) });
  return { ok: true, message: `${t.name} (${orang(t)} orang) keluar pukul ${now}.` };
}

export function resetDemo() {
  save(fresh());
}

export const jumlahOrang = orang;
