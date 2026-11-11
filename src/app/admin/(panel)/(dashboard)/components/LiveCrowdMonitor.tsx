"use client";

import BarChart from "@/components/charts/BarChart";
import { Card, CardTitle } from "@/components/admin/ui";
import { niceTicks, useInsight } from "@/lib/insight-store";

// Grafik jumlah orang di dalam per jam hari ini, dihitung dari tiket yang discan: check-in menaikkan, keluar menurunkan.
// Tiap batang = puncak jumlah orang di dalam pada jam itu. Jam dengan keramaian Sedang ke atas diberi warna hijau tua.
export default function LiveCrowdMonitor() {
  const { data, ready } = useInsight();
  const hours = data?.hourly ?? [];
  const chart = hours.map((h) => ({ label: `${String(h.hour).padStart(2, "0")}.00`, value: h.peak }));
  const kosong = chart.every((d) => d.value === 0);
  return (
    <Card>
      <CardTitle sub="Puncak jumlah orang di dalam per jam, hari ini"
                 right={
                   <div className="flex gap-2 text-[13px] text-ink">
                     <span className="flex h-8 items-center gap-2 rounded-full bg-paper px-3"><span className="size-2 rounded-full bg-forest" /> Sedang ke atas</span>
                     <span className="flex h-8 items-center gap-2 rounded-full bg-paper px-3"><span className="size-2 rounded-full bg-leaf" /> Sepi</span>
                   </div>
                 }>
        Live Crowd Monitor
      </CardTitle>
      <div className="mt-8">
        {chart.length > 0 ? (
          <BarChart data={chart} ticks={niceTicks(Math.max(...chart.map((d) => d.value)))} highlight={(_, i) => hours[i].percent >= 40} tooltip={(d) => `${d.value} orang`} />
        ) : (
          <p className="grid h-[174px] place-items-center rounded-2xl bg-paper px-6 text-center text-sm text-abu">
            {ready ? "Grafik mulai terisi pukul 08.00, saat tiket pertama discan masuk." : "Memuat grafik..."}
          </p>
        )}
        {chart.length > 0 && kosong && <p className="mt-4 text-center text-[13px] text-abu">Belum ada pengunjung yang discan masuk hari ini.</p>}
      </div>
    </Card>
  );
}
