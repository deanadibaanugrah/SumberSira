import { DoorOpen, LogIn, Ticket, Users } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import type { useTiket } from "@/lib/tiket-store";

// Kartu ringkasan: terjual, orang di dalam, kapasitas, belum datang.
export default function StatTiket({ tiket }: { tiket: ReturnType<typeof useTiket> }) {
  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      <StatCard icon={Ticket} solid value={tiket.sold} label="Tiket terjual hari ini" />
      <StatCard icon={Users} value={tiket.inside} label="Orang di dalam" />
      <StatCard icon={DoorOpen} value={`${tiket.percent}%`} label={`Kapasitas terisi · ${tiket.label}`} />
      <StatCard icon={LogIn} value={tiket.waiting} label="Belum datang (orang)" />
    </div>
  );
}
