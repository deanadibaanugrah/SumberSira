"use client";

import { useMemo } from "react";

import { ApiError, api } from "@/lib/live/http";
import { createPollStore } from "@/lib/live/poll-store";
import { jam } from "@/lib/tiket-store";

// Booking sewa & wahana dari aplikasi pengunjung (GET /admin/bookings via BFF).
// Pembayaran QRIS dikonfirmasi otomatis oleh backend, jadi halaman admin hanya MEMANTAU status;
// aksi "Tandai Lunas" dan "Batalkan" (untuk tunai/kendala) hanya boleh dilakukan pengelola.

export type ApiBookingLine = { rideId: string; name: string; qty: number; unitPrice: number; subtotal: number };
export type ApiPayment = {
  id: string; method: string; status: string; amount: number;
  qrString?: string | null; qrUrl?: string | null; expiresAt?: string | null;
};
export type ApiBooking = {
  code: string; name: string; whatsapp: string; slot: string; slotLabel: string; visitDate: string;
  amount: number; paymentStatus: string; createdAt: string;
  lines: ApiBookingLine[]; payment: ApiPayment | null;
};

// Status pembayaran berbahasa Indonesia untuk pill dan filter.
export const labelStatus = (s: string) =>
  ({ pending: "Menunggu", paid: "Lunas", expired: "Kedaluwarsa", failed: "Batal", cancelled: "Batal" })[s] ?? s;

// Bentuk satu booking untuk tampilan.
export type Booking = {
  code: string; name: string; whatsapp: string; slot: string; slotLabel: string; visitDate: string;
  amount: number; paymentStatus: string; status: string; time: string; createdAtMs: number;
  lines: ApiBookingLine[]; payment: ApiPayment | null;
};

function fromApi(b: ApiBooking): Booking {
  return {
    code: b.code, name: b.name, whatsapp: b.whatsapp, slot: b.slot, slotLabel: b.slotLabel, visitDate: b.visitDate,
    amount: b.amount, paymentStatus: b.paymentStatus, status: labelStatus(b.paymentStatus),
    time: jam(b.createdAt), createdAtMs: Date.parse(b.createdAt) || 0,
    lines: b.lines ?? [], payment: b.payment ?? null,
  };
}

type ApiList = { total: number; page: number; limit: number; items: ApiBooking[] };

const LIMIT = 100;
// Satu penyimpan per halaman (pola sama dengan store lain), supaya nomor halaman benar-benar bisa dibuka.
const stores = new Map<number, ReturnType<typeof createPollStore<PageData>>>();

// Isi satu halaman: baris booking + jumlah total semua booking (untuk teks dan nomor halaman).
type PageData = { items: Booking[]; total: number };

function storeFor(page: number) {
  let s = stores.get(page);
  if (!s) {
    s = createPollStore<PageData>(async () => {
      const list = await api<ApiList>("GET", `/api/admin/booking?page=${page}&limit=${LIMIT}`);
      return { items: list.items.map(fromApi), total: list.total };
    }, 15_000);
    stores.set(page, s);
  }
  return s;
}

// Hook daftar booking. total = jumlah semua booking (untuk teks "Menampilkan ... dari ...").
export function useBooking(page = 1) {
  const { data, ready, error } = storeFor(page).use();
  const rows = useMemo(() => data?.items ?? [], [data]);
  return { rows, total: data?.total ?? 0, ready, error, refresh: storeFor(page).refresh };
}

// Muat ulang semua halaman yang pernah dibuka (dipakai setelah aksi pembayaran).
export async function refreshBooking() {
  await Promise.all([...stores.values()].map((s) => s.refresh()));
}

// Ringkasan angka untuk kartu statistik halaman Booking.
export function ringkasanBooking(rows: Booking[], hari: string) {
  return {
    hariIni: rows.filter((b) => b.visitDate === hari).length,
    menunggu: rows.filter((b) => b.status === "Menunggu").length,
    lunas: rows.filter((b) => b.status === "Lunas").length,
    batal: rows.filter((b) => b.status === "Batal" || b.status === "Kedaluwarsa").length,
  };
}

// Booking terbaru dulu (untuk tabel "Booking Sewa Masuk" di dashboard).
export const terbaru = (rows: Booking[]) => [...rows].sort((a, b) => b.createdAtMs - a.createdAtMs);

type Hasil = { ok: boolean; message: string };

// Pesan dari kode kesalahan backend untuk aksi pembayaran.
function pesanAksi(e: unknown): string {
  const code = e instanceof ApiError ? e.code : "ERROR";
  if (code === "NETWORK" || code === "BACKEND_UNREACHABLE") return "Tidak bisa terhubung ke server. Coba lagi sebentar lagi.";
  if (code === "FORBIDDEN") return "Hanya pengelola yang boleh mengubah pembayaran.";
  if (code === "NOT_FOUND") return "Pembayaran tidak ditemukan.";
  if (code === "INVALID_STATE") return "Pembayaran sudah selesai (lunas atau batal) dan tidak bisa diubah lagi.";
  return "Gagal menyimpan. Coba lagi.";
}

function cari(code: string): Booking | undefined {
  for (const s of stores.values()) {
    const b = (s.get().data?.items ?? []).find((x) => x.code === code);
    if (b) return b;
  }
  return undefined;
}

// Aksi pengelola lewat id pembayaran (POST /admin/payments/:id/mark-paid | /cancel).
async function aksiPembayaran(code: string, akhir: string, kata: string): Promise<Hasil> {
  const b = cari(code);
  if (!b?.payment?.id) return { ok: false, message: `Booking ${code} tidak ditemukan.` };
  try {
    await api("POST", `/api/admin/payment/${encodeURIComponent(b.payment.id)}/${akhir}`);
    await refreshBooking();
    return { ok: true, message: `Pembayaran ${code} ${kata}.` };
  } catch (e) {
    await refreshBooking();
    return { ok: false, message: pesanAksi(e) };
  }
}

// Tandai lunas pembayaran yang masih pending (mis. kendala verifikasi tunai).
export const tandaiLunas = (code: string) => aksiPembayaran(code, "mark-paid", "ditandai lunas");
// Batalkan pembayaran pending (pengunjung tidak jadi datang).
export const batalkanPembayaran = (code: string) => aksiPembayaran(code, "cancel", "dibatalkan");
