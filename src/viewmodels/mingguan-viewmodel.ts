"use client";

import { api } from "@/repositories/http-client";
import { createPollStore } from "@/viewmodels/poll-store";
import { tanggalHariIni } from "@/viewmodels/tiket-viewmodel";
import type { HariData, MingguanData } from "@/models/mingguan";

// Agregasi mingguan yang dihitung di sisi klien dari data kontrak backend:
// daftar tiket per tanggal (7 hari terakhir) + daftar booking. Backend belum punya endpoint mingguan,
// jadi pendapatan harian, heatmap keramaian, dan wahana terlaris dihitung dari data itu.




// Jam operasional yang ditampilkan di heatmap (08.00-17.00).
const JAM = ["08", "09", "10", "11", "12", "13", "14", "15", "16", "17"];

// "2026-11-15" -> "Sab" (nama hari singkat, WIB).
const labelHari = (date: string) =>
  new Intl.DateTimeFormat("id-ID", { weekday: "short", timeZone: "Asia/Jakarta" }).format(new Date(`${date}T00:00:00+07:00`));

// Jam (angka) sebuah waktu ISO di zona WIB, mis. "2026-11-15T11:47:34Z" -> 18.
const jamWIB = (iso: string) =>
  Number(new Intl.DateTimeFormat("en-GB", { hour: "2-digit", hour12: false, timeZone: "Asia/Jakarta" }).format(new Date(iso)));

// Tujuh tanggal terakhir (terlama -> terbaru), dihitung murni dari tanggal hari ini WIB.
function tujuhHari(): string[] {
  const kini = new Date(`${tanggalHariIni()}T00:00:00Z`);
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(kini);
    d.setUTCDate(d.getUTCDate() - (6 - i));
    return d.toISOString().slice(0, 10);
  });
}

type ApiTicket = { people: number; adults: number; kids: number; amount: number; paymentStatus: string; checkInAt: string | null; checkOutAt: string | null };
type ApiTicketList = { items: ApiTicket[] };
type ApiBooking = { visitDate: string; amount: number; paymentStatus: string; createdAt: string; lines: { rideId: string; name: string; qty: number }[] };
type ApiBookingList = { items: ApiBooking[] };
type ApiCrowd = { capacity: number };

async function ambil(): Promise<MingguanData> {
  const dates = tujuhHari();
  const [tiketLists, bookingList, crowd] = await Promise.all([
    Promise.all(dates.map((d) => api<ApiTicketList>("GET", `/api/admin/tiket?date=${d}&limit=100`))),
    api<ApiBookingList>("GET", "/api/admin/booking?limit=100"),
    // Kapasitas resmi dari server (bisa diubah pengelola di halaman Wahana & Harga).
    api<ApiCrowd>("GET", "/api/crowd"),
  ]);
  const kapasitas = crowd.capacity;

  // Pendapatan per hari (hanya yang lunas): tiket masuk + parkir, dan sewa alat/wahana.
  const days: HariData[] = dates.map((date, i) => ({
    date,
    day: labelHari(date),
    tiket: tiketLists[i].items.filter((t) => t.paymentStatus === "paid").reduce((s, t) => s + t.amount, 0),
    sewa: bookingList.items.filter((b) => b.visitDate === date && b.paymentStatus === "paid").reduce((s, b) => s + b.amount, 0),
  }));

  // Heatmap keramaian: persen kapasitas per jam, dihitung dari rentang check-in sampai check-out.
  const pola: MingguanData["pola"] = {
    hours: JAM,
    days: dates.map((date, i) => ({
      date,
      day: labelHari(date),
      values: JAM.map((h) => {
        const jam = Number(h);
        let inside = 0;
        for (const t of tiketLists[i].items) {
          if (!t.checkInAt) continue;
          const masuk = jamWIB(t.checkInAt);
          const keluar = t.checkOutAt ? jamWIB(t.checkOutAt) : 18; // masih di dalam: dihitung sampai jam tutup
          if (masuk <= jam && jam < keluar) inside += t.people || t.adults + t.kids;
        }
        return Math.min(100, Math.round((inside / kapasitas) * 100));
      }),
    })),
    note: "",
  };
  // Catatan dibuat dari angka: sel heatmap tertinggi minggu ini.
  let best = { day: "", hour: "", v: 0 };
  for (const d of pola.days) d.values.forEach((v, ci) => { if (v > best.v) best = { day: d.day, hour: JAM[ci], v }; });
  pola.note = best.v === 0
    ? "Belum ada kunjungan yang tercatat minggu ini."
    : `Puncak keramaian hari ${best.day} pukul ${best.hour}.00 (${best.v}% kapasitas).`;

  // Wahana terlaris: jumlah item sewa/wahana dari booking 7 hari terakhir (dibuat dalam seminggu ke belakang).
  const batas = Date.now() - 7 * 24 * 3600 * 1000;
  const hitung = new Map<string, { name: string; count: number }>();
  for (const b of bookingList.items) {
    if (Date.parse(b.createdAt) < batas) continue;
    for (const l of b.lines ?? []) {
      const prev = hitung.get(l.rideId);
      hitung.set(l.rideId, { name: l.name || l.rideId, count: (prev?.count ?? 0) + (l.qty ?? 0) });
    }
  }
  const wahana = [...hitung.entries()].map(([id, v]) => ({ id, name: v.name, count: v.count })).sort((a, b) => b.count - a.count).slice(0, 5);

  return { days, total: days.reduce((s, d) => s + d.tiket + d.sewa, 0), pola, wahana };
}

const store = createPollStore<MingguanData>(ambil, 60_000);

export function useMingguan() {
  const { data, ready, error } = store.use();
  return { data, ready, error, refresh: store.refresh };
}
