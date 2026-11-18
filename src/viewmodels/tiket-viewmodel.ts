"use client";

import { useMemo } from "react";

import { useCrowd } from "@/lib/crowd-store";
import { ApiError, api } from "@/lib/live/http";
import { createPollStore } from "@/lib/live/poll-store";

// Tiket masuk online, sekarang dari backend (bukan lagi localStorage).
// Tiket dibeli pengunjung di aplikasi lalu muncul di sini; petugas menekan Check-in atau Keluar, dan angka Live Crowd
// ikut naik atau turun untuk hari itu saja. Data diambil berkala dan dibagi ke semua komponen (dashboard, tiket, login).
// Live Crowd = jumlah orang dari tiket yang sudah discan masuk dan belum keluar, dibagi kapasitas.

// Label tampilan parkir dari server (GET /pricing). Tidak ada daftar harga di sini supaya
// angka di layar selalu sesuai harga yang dipakai backend saat membuat tagihan.
export const PARKIR_LABEL: Record<string, string> = {
  none: "-",
  motor: "Motor",
  mobil: "Mobil",
  bus: "Bus",
};

// Bentuk satu tiket seperti yang dikirim backend (tanpa id: kode tiket adalah identitasnya).
type ApiTicket = {
  code: string; name: string; whatsapp: string; adults: number; kids: number; people: number;
  parking: string; arrival: string; visitDate: string; amount: number;
  status: "waiting" | "inside" | "out"; paymentStatus: string;
  checkInAt: string | null; checkOutAt: string | null; createdAt: string;
  payment?: { id: string; method: string; status: string; amount: number } | null;
};
type ApiList = { total: number; page: number; limit: number; items: ApiTicket[] };

// Bentuk satu tiket untuk tampilan: status berbahasa Indonesia dan jam berformat 10.42 (WIB).
export type Ticket = {
  id: string; code: string; name: string; whatsapp: string; adults: number; kids: number; parking: string;
  payment: string; paymentStatus: string; total: number;
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

// Tanggal hari ini di zona WIB dalam format "2026-11-15" (untuk query ?date= ke backend).
export const tanggalHariIni = () => new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Jakarta" }).format(new Date());
// "2026-11-12" -> "12 November 2026"
const tanggalPanjang = (d: string) => new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "long", year: "numeric", timeZone: "Asia/Jakarta" }).format(new Date(`${d}T00:00:00+07:00`));

function fromApi(t: ApiTicket): Ticket {
  const ms = (v: string | null) => (v ? Date.parse(v) : null);
  return {
    id: t.code, code: t.code, name: t.name, whatsapp: t.whatsapp, adults: t.adults, kids: t.kids, parking: t.parking,
    payment: t.payment?.method ?? "qris", paymentStatus: t.paymentStatus, total: t.amount,
    status: STATUS[t.status] ?? "Belum masuk", boughtAt: jam(t.createdAt), boughtAtMs: ms(t.createdAt) ?? 0,
    checkInAt: t.checkInAt ? jam(t.checkInAt) : null, checkInMs: ms(t.checkInAt),
    checkOutAt: t.checkOutAt ? jam(t.checkOutAt) : null, checkOutMs: ms(t.checkOutAt),
    fromApp: true, visitDate: t.visitDate,
  };
}

// Ringkasan untuk Live Crowd, dashboard admin, dan halaman tiket.
// Menghitung orang di dalam, persen kapasitas, yang belum datang, yang sudah keluar, dan daftar check-in terbaru.
// Kapasitas boleh null (belum ada data dari server) -> persen dan label juga null, bukan angka default.
export function ringkasan(tickets: Ticket[], capacity: number | null) {
  const sum = (status: Ticket["status"]) => tickets.filter((t) => t.status === status).reduce((n, t) => n + jumlahOrang(t), 0);
  const inside = sum("Di dalam");
  const percent = capacity ? Math.min(100, Math.round((inside / capacity) * 100)) : null;
  const recent = tickets
    .filter((t) => t.checkInMs)
    .sort((a, b) => Math.max(b.checkInMs ?? 0, b.checkOutMs ?? 0) - Math.max(a.checkInMs ?? 0, a.checkOutMs ?? 0));
  // Perubahan terakhir (masuk atau keluar) untuk keterangan "terakhir berubah pukul ...".
  const lastMs = recent.length ? Math.max(recent[0].checkInMs ?? 0, recent[0].checkOutMs ?? 0) : 0;
  return { inside, percent, capacity, label: percent == null ? null : statusKeramaian(percent), waiting: sum("Belum masuk"), out: sum("Keluar"), sold: tickets.length, recent, updatedAt: lastMs ? jam(lastMs) : null };
}

const store = createPollStore<Ticket[]>(async () => {
  const list = await api<ApiList>("GET", `/api/admin/tiket?date=${tanggalHariIni()}&limit=100`);
  return list.items.map(fromApi);
}, 5000);

// Hook utama: dipakai halaman admin mana pun untuk membaca data tiket dan ringkasan Live Crowd yang selalu terbaru.
export function useTiket() {
  const { data, ready, error } = store.use();
  const { data: crowd } = useCrowd();
  // Kapasitas resmi dari server (lewat /crowd); null sampai data tiket/kapasitas tersedia.
  const capacity = crowd?.capacity ?? null;
  const tickets = useMemo(() => data ?? [], [data]);
  const summary = useMemo(() => ringkasan(tickets, capacity), [tickets, capacity]);
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
function pesanError(e: unknown, t: Ticket | null, aksi: "masuk" | "keluar"): string {
  const code = e instanceof ApiError ? e.code : "ERROR";
  if (code === "NETWORK" || code === "BACKEND_UNREACHABLE") return "Tidak bisa terhubung ke server. Coba lagi sebentar lagi.";
  if (code === "CAPACITY_FULL") return "Kapasitas penuh. Minta pengunjung menunggu sebentar.";
  if (code === "NOT_VALID_TODAY") return `${t?.code ?? "Tiket"} berlaku ${t?.visitDate ? tanggalPanjang(t.visitDate) : "hari lain"}, belum bisa dipakai hari ini.`;
  if (code === "NOT_FOUND") return `Kode ${t?.code ?? "tiket"} tidak ditemukan.`;
  if (code === "NOT_PAID") return aksi === "masuk"
    ? `${t?.code ?? "Tiket"} belum lunas. Tekan Konfirmasi Tunai di daftar tiket bila pengunjung membayar tunai.`
    : `${t?.code ?? "Tiket"} belum lunas.`;
  if (code === "INVALID_STATE") return aksi === "masuk" ? `${t?.code ?? "Tiket"} sudah dipakai masuk.` : `${t?.code ?? "Tiket"} belum tercatat di dalam.`;
  return "Gagal menyimpan. Coba lagi.";
}

const cari = (code: string) => (store.get().data ?? []).find((x) => x.code === code);

// Cari tiket di data terakhir; kalau belum ada (baru dibeli / data lama), muat ulang dulu lalu cari lagi.
async function temukan(code: string): Promise<Ticket | null> {
  const ada = cari(code);
  if (ada) return ada;
  await store.refresh();
  return cari(code) ?? null;
}

// Scan petugas di pintu masuk. Mengembalikan { ok, message }.
// Ditolak bila kode salah, tiket sudah dipakai, belum lunas, berlaku hari lain, atau kapasitas penuh.
// Kalau berhasil, status jadi Di dalam dan Live Crowd naik. Backend-lah yang memutuskan (kode by :code).
export async function checkIn(raw: unknown): Promise<Hasil> {
  const code = normalisasiKode(raw);
  if (!code) return { ok: false, message: "Masukkan kode tiket." };
  const t = await temukan(code);
  const now = Date.now();
  if (t) {
    if (t.status === "Di dalam") return { ok: false, message: `${code} sudah dipakai masuk pukul ${t.checkInAt}.` };
    if (t.status === "Keluar") return { ok: false, message: `${code} sudah dipakai, pengunjung keluar pukul ${t.checkOutAt}.` };
    if (t.paymentStatus === "pending") return { ok: false, message: `${code} belum lunas. Tekan Konfirmasi Tunai di daftar tiket bila pengunjung membayar tunai.` };
    // Tampilan langsung berubah (tanpa menunggu server) lalu dicocokkan ulang dengan jawaban server.
    store.patch((all) => all.map((x) => (x.code === code ? { ...x, status: "Di dalam", checkInAt: jam(now), checkInMs: now } : x)));
  }
  try {
    await api("POST", `/api/admin/tiket/${encodeURIComponent(code)}/check-in`);
    void store.refresh();
    return { ok: true, message: t ? `${t.name} (${jumlahOrang(t)} orang) masuk pukul ${jam(now)}.` : `${code} masuk pukul ${jam(now)}.` };
  } catch (e) {
    await store.refresh(); // kembalikan tampilan ke keadaan sebenarnya
    return { ok: false, message: pesanError(e, t, "masuk") };
  }
}

// Mencatat pengunjung keluar: status jadi Keluar sehingga angka Live Crowd turun.
export async function checkOut(raw: unknown): Promise<Hasil> {
  const code = normalisasiKode(raw);
  if (!code) return { ok: false, message: "Masukkan kode tiket." };
  const t = await temukan(code);
  if (t && t.status !== "Di dalam") return { ok: false, message: `${code} belum tercatat di dalam.` };
  const now = Date.now();
  if (t) store.patch((all) => all.map((x) => (x.code === code ? { ...x, status: "Keluar", checkOutAt: jam(now), checkOutMs: now } : x)));
  try {
    await api("POST", `/api/admin/tiket/${encodeURIComponent(code)}/check-out`);
    void store.refresh();
    return { ok: true, message: t ? `${t.name} (${jumlahOrang(t)} orang) keluar pukul ${jam(now)}.` : `${code} keluar pukul ${jam(now)}.` };
  } catch (e) {
    await store.refresh();
    return { ok: false, message: pesanError(e, t, "keluar") };
  }
}

// Konfirmasi pembayaran tunai di loket (POST /admin/tickets/:code/confirm-cash): tiket & pembayaran jadi lunas.
export async function konfirmasiTunai(raw: unknown): Promise<Hasil> {
  const code = normalisasiKode(raw);
  if (!code) return { ok: false, message: "Masukkan kode tiket." };
  const t = await temukan(code);
  if (t && t.payment !== "cash") return { ok: false, message: `${code} bukan pembayaran tunai.` };
  if (t && t.paymentStatus === "paid") return { ok: false, message: `${code} sudah lunas.` };
  try {
    await api("POST", `/api/admin/tiket/${encodeURIComponent(code)}/confirm-cash`);
    void store.refresh();
    return { ok: true, message: `Pembayaran tunai ${t ? t.name : code} dikonfirmasi. Tiket lunas.` };
  } catch (e) {
    await store.refresh();
    const kode = e instanceof ApiError ? e.code : "ERROR";
    if (kode === "NETWORK" || kode === "BACKEND_UNREACHABLE") return { ok: false, message: "Tidak bisa terhubung ke server. Coba lagi sebentar lagi." };
    if (kode === "NOT_FOUND") return { ok: false, message: `Kode ${code} tidak ditemukan.` };
    if (kode === "INVALID_STATE") return { ok: false, message: `Pembayaran ${code} bukan tunai atau sudah lunas.` };
    return { ok: false, message: "Gagal menyimpan. Coba lagi." };
  }
}
