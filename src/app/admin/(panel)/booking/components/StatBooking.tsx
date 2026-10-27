import { Check, CalendarCheck, Clock, TrendingUp } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { BOOKINGS, BOOKING_TOTALS } from "@/data/dummy";

// Kartu ringkasan jumlah booking per status.
export default function StatBooking({ rows }: { rows: typeof BOOKINGS }) {
  // Angka desain dipakai sebagai dasar; perubahan status di halaman ini ikut menggeser angkanya.
  // Selisih jumlah status dibanding data awal, supaya angka di kartu ringkasan ikut berubah saat status diganti.
  const delta = (status) => rows.filter((r) => r.status === status).length - BOOKINGS.filter((r) => r.status === status).length;

  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      <StatCard icon={CalendarCheck} solid value={BOOKING_TOTALS.hariIni} label="Booking hari ini" />
      <StatCard icon={Clock} value={BOOKING_TOTALS.menunggu + delta("Baru")} label="Menunggu konfirmasi" />
      <StatCard icon={TrendingUp} value={BOOKING_TOTALS.diproses + delta("Diproses")} label="Sedang diproses" />
      <StatCard icon={Check} value={BOOKING_TOTALS.selesai + delta("Selesai")} label="Selesai" />
    </div>
  );
}
