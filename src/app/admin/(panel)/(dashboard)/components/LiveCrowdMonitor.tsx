"use client";

import BarChart from "@/components/charts/BarChart";
import { Card, CardTitle } from "@/components/admin/ui";
import { niceTicks } from "@/lib/nice-ticks";
import { useCrowd } from "@/viewmodels/crowd-viewmodel";

// Prakiraan puncak keramaian per jam dari server (/crowd → forecast, dari HOURLY_FORECAST backend).
// Tiap batang = perkiraan jumlah orang di dalam pada jam itu. Jam dengan keramaian Sedang ke atas diberi warna hijau tua.
export default function LiveCrowdMonitor() {
  const { data, ready, error } = useCrowd();
  const capacity = data?.capacity ?? 0;
  const chart = (data?.forecast ?? []).map((f) => ({ label: `${f.hour}.00`, value: f.count }));
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
          <BarChart data={chart} ticks={niceTicks(Math.max(...chart.map((d) => d.value)))} highlight={(d) => d.value >= capacity * 0.4} tooltip={(d) => `${d.value} orang`} />
        ) : (
          <p className="grid h-[174px] place-items-center rounded-2xl bg-paper px-6 text-center text-sm text-abu">
            {!ready ? (error ? "Tidak bisa terhubung ke server." : "Memuat grafik...") : "Prakiraan keramaian belum tersedia hari ini."}
          </p>
        )}
        {chart.length > 0 && kosong && <p className="mt-4 text-center text-[13px] text-abu">Prakiraan keramaian belum tersedia hari ini.</p>}
      </div>
    </Card>
  );
}
