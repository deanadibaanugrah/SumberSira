"use client";

import WahanaIcon from "@/components/WahanaIcon";
import ProgressBar from "@/components/charts/ProgressBar";
import { Card, CardTitle } from "@/components/admin/ui";
import { useMingguan } from "@/viewmodels/mingguan-viewmodel";

// Peringkat wahana dengan booking terbanyak 7 hari terakhir, agregasi klien dari daftar booking
// (backend belum punya endpoint mingguan, lihat src/viewmodels/mingguan-viewmodel.ts).
export default function WahanaPopuler() {
  const { data, ready, error } = useMingguan();
  const list = data?.wahana ?? [];
  const maks = list[0]?.count ?? 0;
  return (
    <Card>
      <CardTitle sub="Jumlah booking 7 hari terakhir">Wahana Terpopuler</CardTitle>
      <ol className="mt-5 space-y-4">
        {list.map((w, i) => (
          <li key={w.id} className="flex items-center gap-3">
            <span className={`grid size-7 shrink-0 place-items-center rounded-full text-xs font-semibold ${i < 3 ? "bg-forest text-white" : "bg-leaf/12 text-forest"}`}>{i + 1}</span>
            <span className="grid size-9 shrink-0 place-items-center rounded-full bg-leaf/12 text-forest"><WahanaIcon name={w.id} variant="admin" size={16} /></span>
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-semibold text-ink">{w.name}</p>
              <ProgressBar value={maks ? Math.round((w.count / maks) * 100) : 0} trackClass="bg-ink/10" height="h-2" />
            </div>
            <span className="font-mono text-sm font-semibold text-ink">{w.count} booking</span>
          </li>
        ))}
        {!ready && <li className="grid h-24 place-items-center rounded-2xl bg-paper text-sm text-abu">Memuat...</li>}
        {ready && list.length === 0 && <li className="grid h-24 place-items-center rounded-2xl bg-paper text-sm text-abu">Belum ada booking minggu ini.</li>}
        {ready && error && <li className="grid h-24 place-items-center rounded-2xl bg-paper text-sm text-abu">Tidak bisa terhubung ke server.</li>}
      </ol>
    </Card>
  );
}
