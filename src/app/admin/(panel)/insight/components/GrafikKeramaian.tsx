import AreaChart from "@/components/charts/AreaChart";
import { Card, CardTitle } from "@/components/admin/ui";
import type { InsightData } from "@/lib/insight-store";

// Grafik area keramaian sepanjang hari (persen kapasitas), titik tiap 30 menit sejak pukul 08.00.
// Hanya jam bulat yang diberi label di sumbu. Garis bergerak naik dan turun mengikuti check-in dan check-out.
export default function GrafikKeramaian({ data, ready }: { data: InsightData | null; ready: boolean }) {
  const points = data?.timeline ?? [];
  const chart = points.map((p) => ({ label: p.label.endsWith(".00") ? p.label.slice(0, 2) : "", value: p.percent, inside: p.inside, time: p.label }));
  const live = data?.crowd;
  // Skala sumbu menyesuaikan puncak hari itu (20, 40, 60, 80, atau 100%) supaya hari sepi tetap terbaca. Angka di sumbu tetap persen kapasitas sebenarnya.
  const puncak = Math.max(0, ...chart.map((d) => d.value));
  const top = Math.min(100, Math.max(20, Math.ceil((puncak * 1.3) / 20) * 20));
  return (
    <Card>
      <CardTitle sub={data ? `Persen kapasitas (${live ? live.capacity : 300} orang) menurut tiket yang discan` : "Persen kapasitas menurut tiket yang discan"}
                 right={live && (
                   <span className="flex h-8 items-center gap-2 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest">
                     <span className="relative flex size-2"><span className="absolute inline-flex size-full animate-ping rounded-full bg-leaf opacity-60" /><span className="relative size-2 rounded-full bg-leaf" /></span>
                     Sekarang {live.percent}% · {live.label}
                   </span>
                 )}>
        Grafik Keramaian
      </CardTitle>
      <div className="mt-2">
        {chart.length >= 2 ? (
          <AreaChart data={chart} dots="peak" ariaLabel="Keramaian sepanjang hari" max={top} ticks={[0, top / 4, top / 2, (top * 3) / 4, top]}
                     tooltip={(d) => (d.value > 0 ? `Puncak ${d.value}% · ${d.time}` : "Belum ada pengunjung")} />
        ) : (
          <p className="grid h-64 place-items-center rounded-2xl bg-paper px-6 text-center text-sm text-abu">
            {ready ? "Belum ada data untuk tanggal ini. Grafik mulai terisi pukul 08.00 saat tiket discan masuk." : "Memuat grafik..."}
          </p>
        )}
      </div>
    </Card>
  );
}
