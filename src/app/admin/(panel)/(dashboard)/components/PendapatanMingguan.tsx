"use client";

import { Card, CardTitle } from "@/components/admin/ui";
import { rupiah } from "@/lib/format";
import { useMingguan } from "@/lib/mingguan-store";

// Total pendapatan seminggu dan grafik batang per hari (tiket dan sewa), agregasi klien dari backend
// (src/lib/mingguan-store.ts). Perbandingan dengan minggu sebelumnya tidak tersedia, jadi pil tren dihilangkan.
export default function PendapatanMingguan() {
  const { data, ready, error } = useMingguan();
  const days = data?.days ?? [];
  return (
    <Card>
      <CardTitle sub="Tiket masuk dan parkir, serta sewa alat dan wahana">Pendapatan 7 Hari</CardTitle>
      <p className="mt-4 font-display text-[32px] font-semibold leading-none tabular-nums text-forest">
        {/* Total pendapatan seminggu = jumlah tiket + sewa setiap hari */}
        {ready ? rupiah(data?.total ?? 0) : "–"}
      </p>
      {days.length > 0 ? (
        <>
          <div className="mt-5 flex h-[150px] items-end gap-3" role="img"
               aria-label={`Pendapatan per hari: ${days.map((d) => `${d.day} ${rupiah(d.tiket + d.sewa)}`).join(", ")}`}>
            {days.map((d, i) => {
              // Pendapatan tertinggi dipakai sebagai tinggi 100% batang.
              const nilai = d.tiket + d.sewa;
              const top = Math.max(...days.map((x) => x.tiket + x.sewa), 1);
              return (
                <div key={d.date} className="flex h-full flex-1 flex-col items-center justify-end gap-2">
                  <div className="flex w-full max-w-8 origin-bottom flex-col justify-end overflow-hidden rounded-[10px] animate-grow-up"
                       style={{ height: `${(nilai / top) * 100}%`, animationDelay: `${i * 80}ms` }}
                       title={`${d.day}: tiket ${rupiah(d.tiket)}, sewa ${rupiah(d.sewa)}`}>
                    {/* Satu batang dibagi dua warna: bagian bawah tiket, bagian atas sewa */}
                    <span className="w-full bg-leaf/45" style={{ height: `${nilai ? (d.sewa / nilai) * 100 : 0}%` }} />
                    <span className="w-full bg-forest" style={{ height: `${nilai ? (d.tiket / nilai) * 100 : 0}%` }} />
                  </div>
                </div>
              );
            })}
          </div>
          <div className="mt-2 flex gap-3 font-mono text-xs text-abu">
            {days.map((d) => <span key={d.date} className="flex-1 text-center">{d.day}</span>)}
          </div>
        </>
      ) : (
        <p className="mt-5 grid h-[150px] place-items-center rounded-2xl bg-paper text-sm text-abu">
          {!ready ? (error ? "Tidak bisa terhubung ke server." : "Memuat data...") : "Belum ada pendapatan yang tercatat minggu ini."}
        </p>
      )}
      <div className="mt-4 flex gap-4 text-[13px] text-abu">
        <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-forest" /> Tiket masuk & parkir</span>
        <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-leaf/45" /> Sewa alat & wahana</span>
      </div>
    </Card>
  );
}
