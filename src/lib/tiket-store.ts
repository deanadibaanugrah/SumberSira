"use client";

import { useMemo } from "react";

import { ApiError, api } from "@/lib/live/http";
import { createPollStore } from "@/lib/live/poll-store";

// Tiket masuk online, sekarang dari backend (bukan lagi localStorage).
// Tiket dibeli pengunjung di aplikasi lalu muncul di sini; petugas menekan Check-in atau Keluar, dan angka Live Crowd
// ikut naik atau turun untuk hari itu saja. Data diambil berkala dan dibagi ke semua komponen (dashboard, tiket, login).
// Live Crowd = jumlah orang dari tiket yang sudah discan masuk dan belum keluar, dibagi kapasitas.

export const KAPASITAS = 300;
export const HARGA_TIKET = 5000;
export const PARKIR = [
  { id: "none", label: "Tidak", price: 0 },
  { id: "motor", label: "Motor", price: 3000 },
  { id: "mobil", label: "Mobil", price: 10000 },
  { id: "bus", label: "Bus", price: 20000 },
];

// Bentuk satu tiket seperti yang dikirim backend.
type ApiTicket = {
  id: string; code: string; name: string; whatsapp: string; adults: number; kids: number; people: number;
  parking: string; payment: string; total: number; source: string; visitDate: string;
  status: "waiting" | "inside" | "out"; boughtAt: string; checkInAt: string | null; checkOutAt: string | null;
};
type ApiList = { date: string; tickets: ApiTicket[] };

// Bentuk satu tiket untuk tampilan: status berbahasa Indonesia dan jam berformat 10.42 (WIB).
export type Ticket = {
  id: string; code: string; name: string; whatsapp: string; adults: number; kids: number; parking: string; payment: string; total: number;
  status: "Belum masuk" | "Di dalam" | "Keluar"; boughtAt: string; checkInAt: string | null; checkOutAt: string | null;
  boughtAtMs: number; checkInMs: number | null; checkOutMs: number | null; fromApp: boolean; visitDate: string;
};

const STATUS = { waiting: "Belum masuk", inside: "Di dalam", out: "Keluar" } as const;

// Menentukan label keramaian dari persen isi: di bawah 40% Sepi, sampai 75% Sedang, di atasnya Ramai.
export function statusKeramaian(percent: number) {
  if (percent < 40) return "Sepi";
  if (percent <= 75) return "Sedang";
  return "Ramai";
}

// Jumlah orang dalam satu tiket (dewasa + balita).
export const jumlahOrang = (t: { adults: number; kids: number }) => t.adults + t.kids;

const jamFormat = new Intl.DateTimeFormat("id-ID", { hour: "2-digit", minute: "2-digit", hour12: false, timeZone: "Asia/Jakarta" });
// Jam dengan format 10.42 (WIB) dari waktu ISO atau milidetik.
export const jam = (v: string | number | Date) => jamFormat.format(new Date(v)).replace(":", ".");
export const jamSekarang = () => jam(Date.now());

function fromApi(t: ApiTicket): Ticket {
  return {
    id: t.id, code: t.code, name: t.name, whatsapp: t.whatsapp, adults: t.adults, kids: t.kids, parking: t.parking, payment: t.payment,
    total: t.total, status: STATUS[t.status], boughtAt: jam(t.boughtAt), boughtAtMs: Date.parse(t.boughtAt),
    checkInAt: t.checkInAt ? jam(t.checkInAt) : null, checkInMs: t.checkInAt ? Date.parse(t.checkInAt) : null,
    checkOutAt: t.checkOutAt ? jam(t.checkOutAt) : null, checkOutMs: t.checkOutAt ? Date.parse(t.checkOutAt) : null,
    fromApp: t.source === "app", visitDate: t.visitDate,
  };
}

// Ringkasan untuk Live Crowd, dashboard admin, dan halaman tiket.
// Menghitung orang di dalam, persen kapasitas, yang belum datang, yang sudah keluar, dan daftar check-in terbaru.
export function ringkasan(tickets: Ticket[]) {
  const sum = (status: Ticket["status"]) => tickets.filter((t) => t.status === status).reduce((n, t) => n + jumlahOrang(t), 0);
  const inside = sum("Di dalam");
  const percent = Math.min(100, Math.round((inside / KAPASITAS) * 100));
  const recent = tickets
    .filter((t) => t.checkInMs)
    .sort((a, b) => Math.max(b.checkInMs ?? 0, b.checkOutMs ?? 0) - Math.max(a.checkInMs ?? 0, a.checkOutMs ?? 0));
  // Perubahan terakhir (masuk atau keluar) untuk keterangan "terakhir berubah pukul ...".
  const lastMs = recent.length ? Math.max(recent[0].checkInMs ?? 0, recent[0].checkOutMs ?? 0) : 0;
  return { inside, percent, label: statusKeramaian(percent), waiting: sum("Belum masuk"), out: sum("Keluar"), sold: tickets.length, recent, updatedAt: lastMs ? jam(lastMs) : null };
}

const store = createPollStore<Ticket[]>(async () => (await api<ApiList>("GET", "/api/admin/tiket")).tickets.map(fromApi), 5000);

// Hook utama: dipakai halaman admin mana pun untuk membaca data tiket dan ringkasan Live Crowd yang selalu terbaru.
export function useTiket() {
  const { data, ready, error } = store.use();
  const tickets = useMemo(() => data ?? [], [data]);
  const summary = useMemo(() => ringkasan(tickets), [tickets]);
  return { tickets, ...summary, ready, error, refresh: store.refresh };
}

// Merapikan kode yang diketik petugas: 1038, tk1038, atau TK 1038 semuanya jadi TK-1038.
export function normalisasiKode(raw: unknown) {
  const text = String(raw || "").toUpperCase().replace(/\s/g, "");
  if (/^\d+$/.test(text)) return `TK-${text}`;
  return text.startsWith("TK") && !text.startsWith("TK-") ? `TK-${text.slice(2)}` : text;
}

type Hasil = { ok: boolean; message: string };

// Pesan untuk petugas dari kode kesalahan backend.
function pesanError(e: unknown, t: Ticket, aksi: "masuk" | "keluar"): string {
  const code = e instanceof ApiError ? e.code : "ERROR";
  if (code === "NETWORK" || code === "BACKEND_UNREACHABLE") return "Tidak bisa terhubung ke server. Coba lagi sebentar lagi.";
  if (code === "CAPACITY_FULL") return "Kapasitas penuh. Minta pengunjung menunggu sebentar.";
  if (code === "NOT_VALID_TODAY") return `${t.code} berlaku ${tanggalPanjang(t.visitDate)}, belum bisa dipakai hari ini.`;
  if (code === "NOT_FOUND") return `Kode ${t.code} tidak ditemukan.`;
  if (code === "WRONG_STATE") return aksi === "masuk" ? `${t.code} sudah dipakai masuk.` : `${t.code} belum tercatat di dalam.`;
  return "Gagal menyimpan. Coba lagi.";
}

const hariIni = () => new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Jakarta" }).format(new Date());
// "2026-11-12" -> "12 November 2026"
const tanggalPanjang = (d: string) => new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "long", year: "numeric", timeZone: "Asia/Jakarta" }).format(new Date(`${d}T00:00:00+07:00`));

const cari = (code: string) => (store.get().data ?? []).find((x) => x.code === code);

// Scan petugas di pintu masuk. Mengembalikan { ok, message }.
// Ditolak bila kode salah, tiket sudah dipakai, berlaku hari lain, atau kapasitas penuh. Kalau berhasil, status jadi Di dalam dan Live Crowd naik.
export async function checkIn(raw: unknown): Promise<Hasil> {
  const code = normalisasiKode(raw);
  let t = cari(code);
  if (!t) {
    // Mungkin dibeli setelah pengambilan data terakhir, atau berlaku di hari lain: tanya langsung ke server.
    try {
      const found = fromApi(await api<ApiTicket>("GET", `/api/admin/tiket/code/${encodeURIComponent(code)}`));
      if (found.visitDate !== hariIni()) return { ok: false, message: `${code} berlaku ${tanggalPanjang(found.visitDate)}, belum bisa dipakai hari ini.` };
      await store.refresh();
      t = cari(code) ?? found;
    } catch (e) {
      const offline = e instanceof ApiError && (e.code === "NETWORK" || e.code === "BACKEND_UNREACHABLE");
      return { ok: false, message: offline ? pesanError(e, { code } as Ticket, "masuk") : `Kode ${code || "tiket"} tidak ditemukan.` };
    }
  }
  if (t.status === "Di dalam") return { ok: false, message: `${code} sudah dipakai masuk pukul ${t.checkInAt}.` };
  if (t.status === "Keluar") return { ok: false, message: `${code} sudah dipakai, pengunjung keluar pukul ${t.checkOutAt}.` };

  // Tampilan langsung berubah (tanpa menunggu server) lalu dicocokkan ulang dengan jawaban server.
  const now = Date.now();
  store.patch((all) => all.map((x) => (x.id === t.id ? { ...x, status: "Di dalam", checkInAt: jam(now), checkInMs: now } : x)));
  try {
    await api("POST", `/api/admin/tiket/${t.id}/check-in`);
    void store.refresh();
    return { ok: true, message: `${t.name} (${jumlahOrang(t)} orang) masuk pukul ${jam(now)}.` };
  } catch (e) {
    await store.refresh(); // kembalikan tampilan ke keadaan sebenarnya
    return { ok: false, message: pesanError(e, t, "masuk") };
  }
}

// Mencatat pengunjung keluar: status jadi Keluar sehingga angka Live Crowd turun.
export async function checkOut(raw: unknown): Promise<Hasil> {
  const code = normalisasiKode(raw);
  const t = cari(code);
  if (!t || t.status !== "Di dalam") return { ok: false, message: `${code} belum tercatat di dalam.` };
  const now = Date.now();
  store.patch((all) => all.map((x) => (x.id === t.id ? { ...x, status: "Keluar", checkOutAt: jam(now), checkOutMs: now } : x)));
  try {
    await api("POST", `/api/admin/tiket/${t.id}/check-out`);
    void store.refresh();
    return { ok: true, message: `${t.name} (${jumlahOrang(t)} orang) keluar pukul ${jam(now)}.` };
  } catch (e) {
    await store.refresh();
    return { ok: false, message: pesanError(e, t, "keluar") };
  }
}
