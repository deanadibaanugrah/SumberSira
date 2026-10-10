import { CalendarCheck, Download, Ellipsis, MessageCircle, Package, Sparkles, Star, Ticket, TrendingUp, Users } from "lucide-react";
import Link from "next/link";

import BarChart from "@/components/charts/BarChart";
import Today from "@/components/admin/Today";
import { AdminHeader, Avatar, Card, CardTitle, PrimaryButton, StatCard, StatusPill } from "@/components/admin/ui";
import { AI_NOTIFICATIONS, BOOKINGS, BUSY_HOURS, STATS, VISITORS_TODAY } from "@/data/dummy";

// Admin 1/6: Dashboard Overview. Kartu ringkasan, grafik keramaian beranimasi, Insight AI, dan booking masuk.
const STAT_ICONS = [CalendarCheck, Ticket, Users, Star];
const NOTIF_ICONS = { trend: TrendingUp, chat: MessageCircle, box: Package };

export default function DashboardPage() {
  return (
    <>
      <AdminHeader title="Halo, Pak Yono!"
                   subtitle={<><Today /> · ringkasan operasional Sumber Sira hari ini</>}
                   action={<PrimaryButton icon={Download}>Unduh Laporan</PrimaryButton>} />

      <div className="mt-6 space-y-5">
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
          {STATS.map((s, i) => (
            <StatCard key={s.label} variant="tall" icon={STAT_ICONS[i]} solid={i === 0} trendIcon={TrendingUp} {...s} />
          ))}
        </div>

        <div className="grid gap-5 xl:grid-cols-[736fr_380fr]">
          <Card>
            <CardTitle sub="Jumlah pengunjung per jam, hari ini"
                       right={
                         <div className="flex gap-2 text-[13px] text-ink">
                           <span className="flex h-8 items-center gap-2 rounded-full bg-paper px-3"><span className="size-2 rounded-full bg-forest" /> Jam ramai</span>
                           <span className="flex h-8 items-center gap-2 rounded-full bg-paper px-3"><span className="size-2 rounded-full bg-leaf" /> Normal</span>
                         </div>
                       }>
              Live Crowd Monitor
            </CardTitle>
            <div className="mt-8">
              <BarChart data={VISITORS_TODAY} highlight={(d) => BUSY_HOURS.includes(d.label)} tooltip={(d) => `${d.value} orang`} />
            </div>
          </Card>

          <section className="flex flex-col rounded-3xl bg-forest p-6 text-white">
            <div className="flex items-center gap-3">
              <span className="grid size-10 place-items-center rounded-full bg-white/12"><Sparkles size={18} aria-hidden="true" /></span>
              <div>
                <h2 className="text-lg font-semibold leading-tight">Insight AI</h2>
                <p className="text-[13px] text-white/70">Diperbarui 2 menit lalu</p>
              </div>
            </div>
            <ul className="mt-5 space-y-2">
              {AI_NOTIFICATIONS.map((n) => {
                const Icon = NOTIF_ICONS[n.icon] ?? Sparkles;
                return (
                  <li key={n.title} className="flex items-center gap-3 rounded-2xl bg-white/[0.08] px-3 py-2.5 animate-fade-up">
                    <span className="grid size-9 shrink-0 place-items-center rounded-full bg-white/10"><Icon size={16} aria-hidden="true" /></span>
                    <span className="min-w-0">
                      <span className="block text-sm font-semibold leading-tight">{n.title}</span>
                      <span className="mt-0.5 block text-xs text-white/70">{n.sub}</span>
                    </span>
                  </li>
                );
              })}
            </ul>
            <Link href="/admin/insight"
                  className="mt-auto flex h-10 items-center justify-center gap-2 rounded-full bg-white text-[15px] font-semibold text-forest transition hover:bg-white/90 max-xl:mt-5">
              <Sparkles size={17} aria-hidden="true" /> Buka AI Insight
            </Link>
          </section>
        </div>

        <Card className="px-4! pb-2! pt-5!">
          <CardTitle className="px-2"
                     right={<Link href="/admin/booking" className="text-sm font-semibold text-leaf hover:text-forest">Lihat semua</Link>}>
            Booking Sewa Masuk
          </CardTitle>
          <div className="mt-2 overflow-x-auto">
            <table className="w-full min-w-[640px] border-separate border-spacing-y-2 text-left text-sm">
              <thead className="text-[13px] text-ink/60">
                <tr>
                  <th className="pl-[52px] font-normal">Pemesan</th>
                  <th className="font-normal">Item</th>
                  <th className="font-normal">Jam</th>
                  <th className="font-normal">Status</th>
                  <th className="w-12"><span className="sr-only">Aksi</span></th>
                </tr>
              </thead>
              <tbody>
                {BOOKINGS.slice(0, 3).map((b) => (
                  <tr key={b.id} className="bg-paper [&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl">
                    <td className="h-10 py-1 pl-3">
                      <span className="flex items-center gap-3"><Avatar name={b.name} size={28} /><span className="font-semibold text-ink">{b.name}</span></span>
                    </td>
                    <td className="text-ink">{b.items}</td>
                    <td className="font-mono text-ink">{b.time}</td>
                    <td><StatusPill status={b.status} /></td>
                    <td className="pr-3 text-right">
                      <Link href="/admin/booking" aria-label={`Buka booking ${b.name}`} className="inline-grid size-8 place-items-center rounded-full text-ink/70 hover:bg-white">
                        <Ellipsis size={18} />
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      </div>
    </>
  );
}
