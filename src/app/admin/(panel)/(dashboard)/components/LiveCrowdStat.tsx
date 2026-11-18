"use client";

import { Users } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { useCrowd } from "@/lib/crowd-store";

// Kartu Tingkat Keramaian di dashboard, dari Live Crowd publik (/crowd) —
// angka yang sama dengan yang dilihat pengunjung di aplikasi.
export default function LiveCrowdStat() {
  const t = useCrowd();
  const data = t.data;
  const angka = t.ready && data ? data.inside : 0;
  const persen = t.ready && data ? data.percent : null;
  const label = t.ready && data ? data.label : null;
  return <StatCard variant="tall" icon={Users} value={t.ready ? label : "…"} label="Tingkat Keramaian" note={t.ready ? `${persen}% kapasitas · ${angka} orang` : undefined} />;
}
