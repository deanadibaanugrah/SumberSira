"use client";

import { Users } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { useTiket } from "@/lib/tiket-store";

// Kartu Tingkat Keramaian di dashboard, angkanya dari tiket yang sudah discan (src/lib/tiket-store.js).
export default function LiveCrowdStat() {
  const t = useTiket();
  return <StatCard variant="tall" icon={Users} value={t.label} label="Tingkat Keramaian" note={`${t.percent}% kapasitas · ${t.inside} orang`} />;
}
