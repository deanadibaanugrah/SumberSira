import BarChart from "@/components/charts/BarChart";
import { Card, CardTitle } from "@/components/admin/ui";
import { niceTicks, type InsightData } from "@/lib/insight-store";

// Puncak jumlah orang di dalam pada tiap jam (08.00 sampai 17.00). Batang hijau tua = jam dengan keramaian Sedang ke atas.
export default function PuncakPerJam({ data }: { data: InsightData | null }) {
  const hours = data?.hourly ?? [];
  const chart = hours.map((h) => ({ label: String(h.hour).padStart(2, "0"), value: h.peak }));
  return (
    <Card>
      <CardTitle sub="Jumlah orang terbanyak di dalam pada tiap jam">Puncak per Jam</CardTitle>
      <div className="mt-8">
        {chart.length > 0 ? (
          <BarChart data={chart} ticks={niceTicks(Math.max(...chart.map((d) => d.value)))} highlight={(_, i) => hours[i].percent >= 40} tooltip={(d) => `${d.value} orang`} />
        ) : (
          <p className="grid h-[174px] place-items-center rounded-2xl bg-paper px-6 text-center text-sm text-abu">Belum ada data per jam.</p>
        )}
      </div>
    </Card>
  );
}
