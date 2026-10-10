import { Download, Sparkles, Star } from "lucide-react";

import AreaChart from "@/components/charts/AreaChart";
import DonutChart from "@/components/charts/DonutChart";
import ProgressBar from "@/components/charts/ProgressBar";
import { AdminHeader, Avatar, Card, CardTitle, PrimaryButton } from "@/components/admin/ui";
import { COMPLAINT_TAGS, COMPLAINT_TIP, CROWD_FORECAST, FORECAST_SUMMARY, REVIEWS, REVIEW_COUNT, SENTIMENT } from "@/data/dummy";

// Admin 3/6: AI Insight. Prediksi keramaian (area beranimasi), ringkasan AI, sentimen (donat), keluhan (batang), ulasan terbaru.
const COMPLAINT_FILL = ["bg-coral", "bg-coral/70", "bg-coral/50"];

export default function InsightPage() {
  const forecast = CROWD_FORECAST.map((d) => ({ label: d.hour, value: d.value }));
  const maxComplaint = Math.max(...COMPLAINT_TAGS.map((t) => t.count));
  const s = FORECAST_SUMMARY;

  return (
    <>
      <AdminHeader title="AI Insight" subtitle="Prediksi keramaian dan ringkasan ulasan otomatis"
                   action={<PrimaryButton icon={Download}>Unduh Laporan</PrimaryButton>} />

      <div className="mt-6 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <Card>
          <CardTitle sub={`Prediksi keramaian per jam untuk besok, ${s.day}`}
                     right={<span className="flex h-8 items-center gap-2 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest"><span className="size-2 rounded-full bg-leaf" /> Jam ramai {s.busyRange}</span>}>
            AI Crowd Forecast
          </CardTitle>
          <div className="mt-2">
            {/* Pita jam ramai dari pertengahan 09-10 sampai pertengahan 14-15, sama seperti di desain. */}
            <AreaChart data={forecast} band={[1.5, 6.5]} tooltip={(d) => `${d.value}% · ${d.label}.00`} />
          </div>
        </Card>

        <div className="grid gap-5">
          <section className="rounded-3xl bg-forest p-6 text-white">
            <div className="flex items-center gap-3">
              <span className="grid size-10 place-items-center rounded-full bg-white/12"><Sparkles size={18} aria-hidden="true" /></span>
              <div>
                <h2 className="text-lg font-semibold leading-tight">Ringkasan AI</h2>
                <p className="text-[13px] text-white/70">Untuk besok, {s.day.split(" ")[0]}</p>
              </div>
            </div>
            <div className="mt-5 flex items-end justify-between gap-4">
              <div>
                <p className="text-[13px] text-white/70">Jam tersibuk</p>
                <p className="font-display text-5xl font-semibold leading-none">{s.peakHour}</p>
                <p className="mt-2 text-sm text-white/80">{s.peakPercent}% kapasitas</p>
              </div>
              <div className="w-[160px] rounded-2xl bg-white/10 p-3.5">
                <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-white/70">Saran AI</p>
                <p className="mt-1.5 text-sm font-semibold leading-snug">{s.tip}</p>
              </div>
            </div>
          </section>

          <Card>
            <CardTitle sub={`${REVIEW_COUNT.total} ulasan · ${REVIEW_COUNT.period}`}>Sentimen Ulasan</CardTitle>
            <div className="mt-4 flex items-center gap-6">
              <DonutChart segments={SENTIMENT} />
              <ul className="flex-1 space-y-3 text-sm text-ink">
                {SENTIMENT.map((x) => (
                  <li key={x.label} className="flex items-center gap-2.5">
                    <span className="size-2.5 rounded-full" style={{ background: x.color }} aria-hidden="true" />
                    <span className="flex-1">{x.label}</span>
                    <span>{x.value}%</span>
                  </li>
                ))}
              </ul>
            </div>
          </Card>
        </div>

        <Card className="flex flex-col">
          <CardTitle sub="Dirangkum AI dari ulasan pengunjung">Topik Keluhan Teratas</CardTitle>
          <ul className="mt-5 space-y-4">
            {COMPLAINT_TAGS.map((t, i) => (
              <li key={t.label}>
                <div className="flex items-center justify-between text-[15px] text-ink">
                  <span className="font-medium">{t.label}</span>
                  <span className="font-mono text-sm text-ink/80">{t.count} ulasan</span>
                </div>
                <div className="mt-2.5">
                  <ProgressBar value={Math.round((t.count / maxComplaint) * 100)} fillClass={COMPLAINT_FILL[i] ?? "bg-coral/50"}
                               trackClass="bg-ink/[0.06]" height="h-3" delay={i * 150} />
                </div>
              </li>
            ))}
          </ul>
          <p className="mt-auto flex items-center gap-2.5 rounded-full bg-leaf/10 px-4 py-2.5 text-sm text-ink max-xl:mt-6">
            <Sparkles size={16} className="shrink-0 text-forest" aria-hidden="true" /> {COMPLAINT_TIP}
          </p>
        </Card>

        <Card>
          <CardTitle>Ulasan Terbaru</CardTitle>
          <ul className="mt-4 space-y-4">
            {REVIEWS.map((r) => (
              <li key={r.id} className="flex gap-3">
                <Avatar name={r.name} size={36} />
                <div>
                  <p className="text-sm font-semibold text-ink">{r.name}</p>
                  <p className="mt-1 flex gap-0.5" aria-label={`${r.stars} dari 5 bintang`}>
                    {[1, 2, 3, 4, 5].map((n) => (
                      <Star key={n} size={13} className={n <= r.stars ? "fill-leaf text-leaf" : "text-ink/25"} aria-hidden="true" />
                    ))}
                  </p>
                  <p className="mt-1.5 text-[13.5px] leading-snug text-ink/80">{r.text}</p>
                </div>
              </li>
            ))}
          </ul>
        </Card>
      </div>
    </>
  );
}
