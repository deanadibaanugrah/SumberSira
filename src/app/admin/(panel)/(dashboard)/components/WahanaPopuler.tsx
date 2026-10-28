import WahanaIcon from "@/components/WahanaIcon";
import ProgressBar from "@/components/charts/ProgressBar";
import { Card, CardTitle } from "@/components/admin/ui";
import { WAHANA_POPULER } from "@/data/dummy";
import { WAHANA } from "@/data/wahana";

// Peringkat wahana dengan booking terbanyak 7 hari terakhir.
export default function WahanaPopuler() {
  return (
    <Card>
      <CardTitle sub="Jumlah booking 7 hari terakhir">Wahana Terpopuler</CardTitle>
      <ol className="mt-5 space-y-4">
        {WAHANA_POPULER.map((w, i) => {
          // Cari data wahana (nama dan ikon) berdasarkan id.
          const item = WAHANA.find((x) => x.id === w.id);
          return (
            <li key={w.id} className="flex items-center gap-3">
              <span className={`grid size-7 shrink-0 place-items-center rounded-full text-xs font-semibold ${i === 0 ? "bg-forest text-white" : "bg-paper text-abu"}`}>{i + 1}</span>
              <span className="grid size-9 shrink-0 place-items-center rounded-full bg-leaf/12 text-forest"><WahanaIcon name={item.icon} variant="admin" size={16} /></span>
              <div className="min-w-0 flex-1">
                <div className="flex items-center justify-between text-sm">
                  <span className="font-semibold">{item.name}</span>
                  <span className="text-abu">{w.count} booking</span>
                </div>
                <div className="mt-1.5">
                  <ProgressBar value={Math.round((w.count / WAHANA_POPULER[0].count) * 100)} fillClass={i === 0 ? "bg-forest" : "bg-leaf"}
                               trackClass="bg-paper" height="h-2" delay={i * 120} />
                </div>
              </div>
            </li>
          );
        })}
      </ol>
    </Card>
  );
}
