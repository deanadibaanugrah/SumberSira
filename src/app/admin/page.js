import { Bell } from "lucide-react";

import BarChart from "@/components/charts/BarChart";
import { AdminHeader, Card, CardTitle, StatCard, StatusPill } from "@/components/admin/ui";
import { AI_NOTIFICATIONS, INCOMING, STATS, VISITORS_TODAY } from "@/data/dummy";

// Admin 1/6: Dashboard Overview — kartu statistik, grafik keramaian beranimasi, booking masuk, notifikasi AI.
export default function DashboardPage() {
  return (
    <>
      <AdminHeader title="Dashboard Overview" />
      <main className="space-y-6 p-6 lg:p-8">
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
          {STATS.map((s) => <StatCard key={s.label} {...s} />)}
        </div>

        <div className="grid gap-5 xl:grid-cols-[520fr_340fr_256fr]">
          <Card className="xl:h-[280px]">
            <CardTitle size="sm">Live Crowd Monitor</CardTitle>
            <div className="mt-[37px]">
              <BarChart data={VISITORS_TODAY} height={179} columns={7} align="start" barWidth="w-[73%]" rounded="rounded-md"
                        highlight={(d) => ["12", "14", "16"].includes(d.label)} barClass="bg-[#6fae92]" highlightClass="bg-forest"
                        labelClass="text-[9px] text-ink/60" />
            </div>
          </Card>

          <Card className="xl:h-[280px]">
            <CardTitle size="sm">Booking Sewa Masuk</CardTitle>
            <ul className="mt-5 space-y-5">
              {INCOMING.map((b) => (
                <li key={b.label} className="flex items-center gap-3">
                  <span className="size-8 shrink-0 rounded-full bg-mist" aria-hidden="true" />
                  <span className="flex-1 text-[11px] text-ink">{b.label}</span>
                  <StatusPill status={b.status} />
                </li>
              ))}
            </ul>
          </Card>

          <Card className="xl:h-[280px]">
            <CardTitle size="sm">Notifikasi AI</CardTitle>
            <ul className="mt-[22px] space-y-[45px]">
              {AI_NOTIFICATIONS.map((n) => (
                <li key={n} className="flex min-h-[27px] items-center gap-3 text-[10px] leading-[11.5px] text-ink">
                  <span className="grid size-[27px] shrink-0 place-items-center rounded-full bg-mist text-leaf"><Bell size={11} /></span>
                  {n}
                </li>
              ))}
            </ul>
          </Card>
        </div>
      </main>
    </>
  );
}
