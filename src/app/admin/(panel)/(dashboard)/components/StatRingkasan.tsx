import { CalendarCheck, Star, Ticket, TrendingUp, Users } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { STATS } from "@/data/dummy";

import LiveCrowdStat from "./LiveCrowdStat";

// Ikon untuk 4 kartu ringkasan.
const STAT_ICONS = [CalendarCheck, Ticket, Users, Star];

// Baris 1: empat kartu ringkasan. Kartu ketiga (keramaian) memakai angka live dari tiket.
export default function StatRingkasan() {
  return (
    <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      {STATS.map((s, i) => (i === 2
        ? <LiveCrowdStat key={s.label} />
        : <StatCard key={s.label} variant="tall" icon={STAT_ICONS[i]} solid={i === 0} trendIcon={TrendingUp} {...s} />))}
    </div>
  );
}
