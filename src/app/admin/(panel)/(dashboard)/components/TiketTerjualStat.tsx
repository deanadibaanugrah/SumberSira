"use client";

import { Ticket } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { useTiket } from "@/lib/tiket-store";

// Kartu Tiket Terjual Hari Ini di dashboard, angkanya dari tiket yang dibeli pengunjung (backend).
export default function TiketTerjualStat() {
  const t = useTiket();
  return <StatCard variant="tall" icon={Ticket} value={t.sold} label="Tiket Terjual Hari Ini" note={`${t.inside} orang sedang di dalam`} />;
}
