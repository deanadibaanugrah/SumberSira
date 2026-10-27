import { LifeBuoy, Package, Ticket } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import type { WahanaItem } from "@/lib/server/wahana-store";

// Kartu ringkasan jumlah item.
export default function StatWahana({ items }: { items: WahanaItem[] }) {
  // Menghitung jumlah item per kategori untuk kartu ringkasan.
  const count = (category) => items.filter((w) => w.category === category).length;

  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-3">
      <StatCard icon={Package} solid value={items.length} label="Total item" />
      <StatCard icon={LifeBuoy} value={count("Sewa Alat")} label="Sewa alat" />
      <StatCard icon={Ticket} value={count("Wahana")} label="Wahana" />
    </div>
  );
}
