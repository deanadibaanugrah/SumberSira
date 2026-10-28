import { TrendingUp } from "lucide-react";

import { Card, CardTitle } from "@/components/admin/ui";
import { PENDAPATAN_MINGGU } from "@/data/dummy";
import { rupiah } from "@/lib/format";

// Total pendapatan seminggu dan grafik batang per hari (tiket dan sewa).
export default function PendapatanMingguan() {
  return (
    <Card>
      <CardTitle sub="Tiket masuk dan parkir, serta sewa alat dan wahana"
                 right={<span className="flex h-8 items-center gap-1.5 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest"><TrendingUp size={15} aria-hidden="true" /> {PENDAPATAN_MINGGU.change}</span>}>
        Pendapatan 7 Hari
      </CardTitle>
      <p className="mt-4 font-display text-[32px] font-semibold leading-none tabular-nums text-forest">
        {/* Total pendapatan seminggu = jumlah tiket + sewa setiap hari */}
        {rupiah(PENDAPATAN_MINGGU.days.reduce((sum, d) => sum + d.tiket + d.sewa, 0))}
      </p>
      <div className="mt-5 flex h-[150px] items-end gap-3" role="img"
           aria-label={`Pendapatan per hari: ${PENDAPATAN_MINGGU.days.map((d) => `${d.day} ${rupiah(d.tiket + d.sewa)}`).join(", ")}`}>
        {PENDAPATAN_MINGGU.days.map((d, i) => {
          // Pendapatan tertinggi dipakai sebagai tinggi 100% batang.
          const top = Math.max(...PENDAPATAN_MINGGU.days.map((x) => x.tiket + x.sewa));
          return (
            <div key={d.day} className="flex h-full flex-1 flex-col items-center justify-end gap-2">
              <div className="flex w-full max-w-8 origin-bottom flex-col justify-end overflow-hidden rounded-[10px] animate-grow-up"
                   style={{ height: `${((d.tiket + d.sewa) / top) * 100}%`, animationDelay: `${i * 80}ms` }}
                   title={`${d.day}: tiket ${rupiah(d.tiket)}, sewa ${rupiah(d.sewa)}`}>
                {/* Satu batang dibagi dua warna: bagian bawah tiket, bagian atas sewa */}
                <span className="w-full bg-leaf/45" style={{ height: `${(d.sewa / (d.tiket + d.sewa)) * 100}%` }} />
                <span className="w-full bg-forest" style={{ height: `${(d.tiket / (d.tiket + d.sewa)) * 100}%` }} />
              </div>
            </div>
          );
        })}
      </div>
      <div className="mt-2 flex gap-3 font-mono text-xs text-abu">
        {PENDAPATAN_MINGGU.days.map((d) => <span key={d.day} className="flex-1 text-center">{d.day}</span>)}
      </div>
      <div className="mt-4 flex gap-4 text-[13px] text-abu">
        <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-forest" /> Tiket masuk & parkir</span>
        <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-leaf/45" /> Sewa alat & wahana</span>
      </div>
    </Card>
  );
}
