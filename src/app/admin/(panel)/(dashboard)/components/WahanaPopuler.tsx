"use client";

import WahanaIcon from "@/components/WahanaIcon";
import ProgressBar from "@/components/charts/ProgressBar";
import { Card, CardTitle } from "@/components/admin/ui";
import { WAHANA } from "@/data/wahana";
import { useMingguan } from "@/lib/mingguan-store";

// Peringkat wahana dengan booking terbanyak 7 hari terakhir, agregasi klien dari daftar booking
// (backend belum punya endpoint mingguan, lihat src/lib/mingguan-store.ts).
export default function WahanaPopuler() {
  const { data, ready } = useMingguan();
  const list = data?.wahana ?? [];
  return (
    <Card>
      <CardTitle sub="Jumlah booking 7 hari terakhir">Wahana Terpopuler</CardTitle>
      <ol className="mt-5 space-y-4">
        {list.map((w, i) => {
          // Cari data wahana (nama dan ikon) berdasarkan id.
          const item = WAHANA.find((x) => x.id === w.id);
          return (
            <li key={w.id} className="flex items-center gap-3">
              <span className={`grid size-7 shrink-0 place-items-center rounded-full text-xs font-semibold ${i === 0 ? "bg-forest text-white" : "bg-paper text-abu"}`}>{i + 1}</span>
              <span className="grid size-9 shrink-0 place-items-center rounded-full bg-leaf/12 text-forest"><WahanaIcon name={item?.icon ?? w.id} variant="admin" size={16} /></span>
              <div className="min-w-0 flex-1">
                <div className="flex items-center justify-between text-sm">
                  <span className="font-semibold">{item?.name ?? w.id}</span>
                  <span className="text-abu">{w.count} booking</span>
                </div>
                <div className="mt-1.5">
                  <ProgressBar value={Math.round((w.count / list[0].count) * 100)} fillClass={i === 0 ? "bg-forest" : "bg-leaf"}
                               trackClass="bg-paper" height="h-2" delay={i * 120} />
                </div>
              </div>
            </li>
          );
        })}
      </ol>
      {!ready && <p className="grid h-48 place-items-center rounded-2xl bg-paper text-sm text-abu">Memuat data booking...</p>}
      {ready && list.length === 0 && <p className="grid h-48 place-items-center rounded-2xl bg-paper text-sm text-abu">Belum ada booking wahana minggu ini.</p>}
    </Card>
  );
}
