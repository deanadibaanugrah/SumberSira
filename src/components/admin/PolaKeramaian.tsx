"use client";

import { Info } from "lucide-react";

import Heatmap from "@/components/charts/Heatmap";
import { Card, CardTitle } from "@/components/admin/ui";
import { useMingguan } from "@/viewmodels/mingguan-viewmodel";

// Heatmap keramaian 7 hari terakhir (persen kapasitas puncak per jam), dihitung dari tiket yang di scan masuk.
// Catatan di bawahnya dibuat dari angka (hari dan jam tertinggi), bukan dari AI.
// Backend tidak punya endpoint mingguan, jadi angkanya diagregasi di klien (src/viewmodels/mingguan-viewmodel.ts).
export default function PolaKeramaian() {
  const { data, ready, error } = useMingguan();
  const pola = data?.pola;
  return (
    <Card>
      <CardTitle sub="Persentase kapasitas per jam, 7 hari terakhir (dari tiket yang di scan)">Pola Keramaian Minggu Ini</CardTitle>
      <div className="mt-5">
        {pola
          ? <Heatmap hours={pola.hours} rows={pola.days} />
          : <p className="grid h-48 place-items-center rounded-2xl bg-paper text-sm text-abu">{ready ? (error ? "Tidak bisa terhubung ke server." : "Belum ada data.") : "Memuat pola keramaian..."}</p>}
      </div>
      {pola && (
        <p className="mt-4 flex items-start gap-2.5 rounded-2xl bg-leaf/12 px-4 py-3 text-sm text-ink">
          <Info size={16} className="mt-0.5 shrink-0 text-forest" aria-hidden="true" /> {pola.note}
        </p>
      )}
    </Card>
  );
}
