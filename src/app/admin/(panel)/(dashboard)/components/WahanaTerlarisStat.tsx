"use client";

import { Ticket } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { WAHANA } from "@/data/wahana";
import { useMingguan } from "@/lib/mingguan-store";

// Kartu Wahana Terlaris: agregasi klien dari booking 7 hari terakhir
// (backend belum punya endpoint mingguan, lihat src/lib/mingguan-store.ts).
export default function WahanaTerlarisStat() {
  const { data, ready } = useMingguan();
  const top = data?.wahana[0];
  const nama = top ? WAHANA.find((w) => w.id === top.id)?.name ?? top.id : null;
  return (
    <StatCard variant="tall" icon={Ticket}
              value={ready ? nama ?? "–" : "…"} label="Wahana Terlaris"
              note={top ? `${top.count} booking minggu ini` : ready ? "Belum ada booking minggu ini" : undefined} />
  );
}
