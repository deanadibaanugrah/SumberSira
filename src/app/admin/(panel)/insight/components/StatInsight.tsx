import { Clock, Star, Users } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import type { AdminInsight } from "@/models/admin";

// Tiga kartu ringkasan: rating ulasan, keramaian saat ini, dan jam terpadat.
export default function StatInsight({ data }: { data: AdminInsight }) {
  const jam = data.peakHour ? `${String(data.peakHour).padStart(2, "0")}.00` : "-";
  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-3">
      <StatCard
        icon={Star}
        solid
        value={data.reviewCount > 0 ? data.rating.toFixed(1) : "-"}
        label={data.reviewCount > 0 ? `Rating dari ${data.reviewCount} ulasan` : "Belum ada ulasan"}
      />
      <StatCard
        icon={Users}
        value={`${data.crowd.percent}%`}
        label={`${data.crowd.inside} orang di dalam · ${data.crowd.label}`}
      />
      <StatCard icon={Clock} value={jam} label="Jam terpadat" />
    </div>
  );
}
