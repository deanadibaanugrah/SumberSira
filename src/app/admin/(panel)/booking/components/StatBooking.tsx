"use client";

import { CalendarCheck, Check, Clock, XCircle } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { ringkasanBooking, useBooking } from "@/viewmodels/booking-viewmodel";
import { tanggalHariIni } from "@/viewmodels/tiket-viewmodel";

// Kartu ringkasan jumlah booking per status pembayaran (dari backend).
export default function StatBooking() {
  const { rows, ready } = useBooking();
  const s = ringkasanBooking(rows, tanggalHariIni());
  const angka = (n: number) => (ready ? n : "–");
  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      <StatCard icon={CalendarCheck} solid value={angka(s.hariIni)} label="Booking hari ini" />
      <StatCard icon={Clock} value={angka(s.menunggu)} label="Menunggu pembayaran" />
      <StatCard icon={Check} value={angka(s.lunas)} label="Lunas" />
      <StatCard icon={XCircle} value={angka(s.batal)} label="Batal & kedaluwarsa" />
    </div>
  );
}
