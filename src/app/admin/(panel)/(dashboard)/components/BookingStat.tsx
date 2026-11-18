"use client";

import { CalendarCheck } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { useDashboard } from "@/viewmodels/dashboard-viewmodel";

// Kartu Booking Sewa Hari Ini: jumlah booking yang dibuat hari ini, dari GET /admin/dashboard.
export default function BookingStat() {
  const { data, ready } = useDashboard();
  return (
    <StatCard variant="tall" icon={CalendarCheck} solid
              value={ready && data ? data.bookingsToday : "–"} label="Booking Sewa Hari Ini"
              note={data ? `${data.pendingCash + data.pendingQris} pembayaran menunggu` : undefined} />
  );
}
