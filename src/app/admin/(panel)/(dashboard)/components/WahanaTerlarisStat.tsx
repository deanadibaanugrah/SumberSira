"use client";

import { Ticket } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { useMingguan } from "@/viewmodels/mingguan-viewmodel";

// Kartu Wahana Terlaris: agregasi klien dari booking 7 hari terakhir
// (backend belum punya endpoint mingguan, lihat src/viewmodels/mingguan-viewmodel.ts).
export default function WahanaTerlarisStat() {
  const { data, ready, error } = useMingguan();
  const top = data?.wahana[0];
  const nama = top?.name ?? null;
  return (
    <StatCard variant="tall" icon={Ticket}
              value={ready ? nama ?? "–" : "…"} label="Wahana Terlaris"
              note={top ? `${top.count} booking minggu ini` : ready ? "Belum ada booking minggu ini" : undefined} />
  );
}
