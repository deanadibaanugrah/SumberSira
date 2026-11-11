import { CalendarCheck, Ticket, TrendingUp } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { STATS } from "@/data/dummy";

import LiveCrowdStat from "./LiveCrowdStat";
import TiketTerjualStat from "./TiketTerjualStat";

// Ikon untuk 4 kartu ringkasan.
const STAT_ICONS = [CalendarCheck, Ticket];

// Baris 1: empat kartu ringkasan. Kartu ketiga (keramaian) dan keempat (tiket terjual) memakai angka live dari tiket.
export default function StatRingkasan() {
  return (
    <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      {STATS.map((s, i) => (i === 2
        ? <LiveCrowdStat key={s.label} />
        : i === 3
          ? <TiketTerjualStat key={s.label} />
          : <StatCard key={s.label} variant="tall" icon={STAT_ICONS[i]} solid={i === 0} trendIcon={TrendingUp} {...s} />))}
    </div>
  );
}
