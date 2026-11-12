import BarChart from "@/components/charts/BarChart";
import { Card, CardTitle } from "@/components/admin/ui";
import { BUSY_HOURS, VISITORS_TODAY } from "@/data/dummy";

// Grafik jumlah pengunjung per jam hari ini, jam ramai diberi warna berbeda.
export default function LiveCrowdMonitor() {
  return (
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
  );
}
