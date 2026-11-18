"use client";

import { Users } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { useCrowd } from "@/lib/crowd-store";

// Kartu Tingkat Keramaian di dashboard, dari Live Crowd publik (/crowd) —
// angka yang sama dengan yang dilihat pengunjung di aplikasi.
export default function LiveCrowdStat() {
  const t = useCrowd();
  return <StatCard variant="tall" icon={Users} value={t.label} label="Tingkat Keramaian" note={`${t.percent}% kapasitas · ${t.inside} orang`} />;
}
