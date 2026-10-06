import LineChart from "@/components/charts/LineChart";
import ProgressBar from "@/components/charts/ProgressBar";
import { AdminHeader, Card, CardTitle } from "@/components/admin/ui";
import { COMPLAINT_TAGS, CROWD_FORECAST, FEEDBACK } from "@/data/dummy";

// Admin 3/6: AI Insight — prediksi keramaian (garis beranimasi) dan sentimen ulasan (batang beranimasi).
export default function InsightPage() {
  const forecast = CROWD_FORECAST.map((d) => ({ label: d.hour, value: d.value }));
  return (
    <>
      <AdminHeader title="AI Insight" />
      <main className="grid gap-5 p-6 lg:p-8 xl:grid-cols-[700fr_436fr]">
        <Card className="xl:h-[379px]">
          <CardTitle sub="Prediksi keramaian per jam — highlight jam sibuk 10.00–14.00">AI Crowd Forecast</CardTitle>
          {/* Geometri sesuai desain: lebar plot 660, pita jam sibuk 240 tinggi, skala 0–100%. */}
          <LineChart data={forecast} band={[2, 6]} max={100} width={660} height={270} padX={0} top={4} bottom={244} bandTop={4}
                     labelY={262.5} labelSize={9} strokeWidth={3} pointRadius={4} ringWidth={0} bandColor="rgba(64, 145, 108, 0.15)"
                     axisColor="rgba(23, 35, 33, 0.12)" labelColor="rgba(23, 35, 33, 0.6)" />
        </Card>

        <Card className="xl:h-[379px]">
          <CardTitle>AI Feedback Insight</CardTitle>
          <ul className="mt-5 space-y-3.5">
            {FEEDBACK.map((f, i) => (
              <li key={f.label}>
                <p className="text-[10.5px] text-ink">{f.label}</p>
                <div className="mt-1 flex items-center gap-3">
                  <ProgressBar value={f.value} fillClass={f.color} delay={i * 150} />
                  <span className={`w-12 shrink-0 font-mono text-[9px] leading-none ${f.text}`}>{f.value}%</span>
                </div>
              </li>
            ))}
          </ul>
          <h3 className="mt-8 border-t border-black/10 pt-3.5 text-xs font-semibold text-ink">Tag Keluhan Teratas</h3>
          <ul className="mt-3 space-y-3">
            {COMPLAINT_TAGS.map((t) => (
              <li key={t.label} className="flex items-center justify-between">
                <span className="flex h-7 items-center rounded-full bg-coral/12 pl-3.5 pr-10 text-[10px] text-coral">{t.label}</span>
                <span className="w-10 shrink-0 text-[10px] text-ink">{t.count}x</span>
              </li>
            ))}
          </ul>
        </Card>
      </main>
    </>
  );
}
