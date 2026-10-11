import { CalendarCheck, Download, Ellipsis, MessageCircle, Package, Sparkles, Star, Ticket, TrendingUp, Users } from "lucide-react";
import Link from "next/link";

import WahanaIcon from "@/components/WahanaIcon";
import BarChart from "@/components/charts/BarChart";
import Heatmap from "@/components/charts/Heatmap";
import ProgressBar from "@/components/charts/ProgressBar";
import { LiveCrowdStat, TiketHariIniCard } from "@/components/admin/DashboardLive";
import Today from "@/components/admin/Today";
import { AdminHeader, Avatar, Card, CardTitle, PrimaryButton, StatCard, StatusPill } from "@/components/admin/ui";
import { AI_NOTIFICATIONS, BOOKINGS, BUSY_HOURS, PENDAPATAN_MINGGU, STATS, VISITORS_TODAY, WAHANA_POPULER, WEEKLY_CROWD } from "@/data/dummy";
import { WAHANA } from "@/data/wahana";
import { rupiah } from "@/lib/format";

// Admin 1/7: Dashboard Overview. Kartu ringkasan, grafik keramaian beranimasi, Insight AI, booking masuk,
// lalu di bawah: heatmap keramaian seminggu, tiket online hari ini (live), wahana terpopuler, dan pendapatan 7 hari.
// Ikon untuk 4 kartu ringkasan dan ikon notifikasi Insight AI.
const STAT_ICONS = [CalendarCheck, Ticket, Users, Star];
const NOTIF_ICONS = { trend: TrendingUp, chat: MessageCircle, box: Package };

// Halaman Dashboard admin, disusun dari atas ke bawah per baris.
export default function DashboardPage() {
  return (
    <>
      <AdminHeader title="Halo, Pak Yono!"
                   subtitle={<><Today /> · ringkasan operasional Sumber Sira hari ini</>}
                   action={<PrimaryButton icon={Download}>Unduh Laporan</PrimaryButton>} />

      <div className="mt-6 space-y-5">
        {/* Baris 1: empat kartu ringkasan. Kartu ketiga (keramaian) memakai angka live dari tiket */}
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
          {STATS.map((s, i) => (i === 2
            ? <LiveCrowdStat key={s.label} />
            : <StatCard key={s.label} variant="tall" icon={STAT_ICONS[i]} solid={i === 0} trendIcon={TrendingUp} {...s} />))}
        </div>

        {/* Baris 2: grafik pengunjung per jam dan kartu Insight AI */}
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

        {/* Baris 3: tabel 3 booking sewa terbaru */}
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
        {/* Baris 4: heatmap keramaian seminggu dan kartu tiket online hari ini */}
        <div className="grid gap-5 xl:grid-cols-[736fr_380fr]">
          <Card>
            <CardTitle sub="Persentase kapasitas per jam, 7 hari terakhir (dari tiket yang discan)">Pola Keramaian Minggu Ini</CardTitle>
            <div className="mt-5">
              <Heatmap hours={WEEKLY_CROWD.hours} rows={WEEKLY_CROWD.days} />
            </div>
            <p className="mt-4 flex items-start gap-2.5 rounded-2xl bg-leaf/10 px-4 py-3 text-sm text-ink">
              <Sparkles size={16} className="mt-0.5 shrink-0 text-forest" aria-hidden="true" /> {WEEKLY_CROWD.insight}
            </p>
          </Card>
          <TiketHariIniCard />
        </div>

        {/* Baris 5: wahana terpopuler dan pendapatan 7 hari */}
        <div className="grid gap-5 xl:grid-cols-2">
          <Card>
            <CardTitle sub="Jumlah booking 7 hari terakhir">Wahana Terpopuler</CardTitle>
            <ol className="mt-5 space-y-4">
              {WAHANA_POPULER.map((w, i) => {
                // Cari data wahana (nama dan ikon) berdasarkan id.
                const item = WAHANA.find((x) => x.id === w.id);
                return (
                  <li key={w.id} className="flex items-center gap-3">
                    <span className={`grid size-7 shrink-0 place-items-center rounded-full text-xs font-semibold ${i === 0 ? "bg-forest text-white" : "bg-paper text-ink/70"}`}>{i + 1}</span>
                    <span className="grid size-9 shrink-0 place-items-center rounded-full bg-leaf/12 text-forest"><WahanaIcon name={item.icon} variant="admin" size={16} /></span>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between text-sm">
                        <span className="font-semibold">{item.name}</span>
                        <span className="text-ink/60">{w.count} booking</span>
                      </div>
                      <div className="mt-1.5">
                        <ProgressBar value={Math.round((w.count / WAHANA_POPULER[0].count) * 100)} fillClass={i === 0 ? "bg-forest" : "bg-leaf"}
                                     trackClass="bg-ink/[0.06]" height="h-2" delay={i * 120} />
                      </div>
                    </div>
                  </li>
                );
              })}
            </ol>
          </Card>

          <Card>
            <CardTitle sub="Tiket masuk dan parkir, serta sewa alat dan wahana"
                       right={<span className="flex h-8 items-center gap-1.5 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest"><TrendingUp size={15} aria-hidden="true" /> {PENDAPATAN_MINGGU.change}</span>}>
              Pendapatan 7 Hari
            </CardTitle>
            <p className="mt-4 text-[32px] font-semibold leading-none tracking-tight">
              {/* Total pendapatan seminggu = jumlah tiket + sewa setiap hari */}
              {rupiah(PENDAPATAN_MINGGU.days.reduce((sum, d) => sum + d.tiket + d.sewa, 0))}
            </p>
            <div className="mt-5 flex h-[150px] items-end gap-3" role="img"
                 aria-label={`Pendapatan per hari: ${PENDAPATAN_MINGGU.days.map((d) => `${d.day} ${rupiah(d.tiket + d.sewa)}`).join(", ")}`}>
              {PENDAPATAN_MINGGU.days.map((d, i) => {
                // Pendapatan tertinggi dipakai sebagai tinggi 100% batang.
                const top = Math.max(...PENDAPATAN_MINGGU.days.map((x) => x.tiket + x.sewa));
                return (
                  <div key={d.day} className="flex h-full flex-1 flex-col items-center justify-end gap-2">
                    <div className="flex w-full max-w-8 origin-bottom flex-col justify-end overflow-hidden rounded-[10px] animate-grow-up"
                         style={{ height: `${((d.tiket + d.sewa) / top) * 100}%`, animationDelay: `${i * 80}ms` }}
                         title={`${d.day}: tiket ${rupiah(d.tiket)}, sewa ${rupiah(d.sewa)}`}>
                      {/* Satu batang dibagi dua warna: bagian bawah tiket, bagian atas sewa */}
                      <span className="w-full bg-leaf/45" style={{ height: `${(d.sewa / (d.tiket + d.sewa)) * 100}%` }} />
                      <span className="w-full bg-forest" style={{ height: `${(d.tiket / (d.tiket + d.sewa)) * 100}%` }} />
                    </div>
                  </div>
                );
              })}
            </div>
            <div className="mt-2 flex gap-3 font-mono text-xs text-ink/60">
              {PENDAPATAN_MINGGU.days.map((d) => <span key={d.day} className="flex-1 text-center">{d.day}</span>)}
            </div>
            <div className="mt-4 flex gap-4 text-[13px] text-ink/70">
              <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-forest" /> Tiket masuk & parkir</span>
              <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-leaf/45" /> Sewa alat & wahana</span>
            </div>
          </Card>
        </div>
      </div>
    </>
  );
}
