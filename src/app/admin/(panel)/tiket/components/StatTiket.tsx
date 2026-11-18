import { DoorOpen, LogIn, Ticket, Users } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import type { useTiket } from "@/lib/tiket-store";

// Kartu ringkasan: terjual, orang di dalam, kapasitas, belum datang.
export default function StatTiket({ tiket }: { tiket: ReturnType<typeof useTiket> }) {
  const persen = tiket.percent; // dari server via /crowd; null bila kapasitas belum ada
  const label = tiket.label; // tingkat keramaian; null bila tidak ada data
  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      <StatCard icon={Ticket} solid value={tiket.sold} label="Tiket terjual hari ini" />
      <StatCard icon={Users} value={tiket.inside} label="Orang di dalam" />
      <StatCard icon={DoorOpen} value={tiket.ready ? `${persen ?? 0}%` : "…"} label={`Kapasitas terisi · ${label ?? "Menunggu data"}`} />
      <StatCard icon={LogIn} value={tiket.waiting} label="Belum datang (orang)" />
    </div>
  );
}
