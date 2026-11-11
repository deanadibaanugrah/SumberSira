"use client";

import { Info } from "lucide-react";

import Heatmap from "@/components/charts/Heatmap";
import { Card, CardTitle } from "@/components/admin/ui";
import { useWeek } from "@/lib/insight-store";

// Heatmap keramaian 7 hari terakhir (persen kapasitas puncak per jam), dihitung dari tiket yang discan masuk.
// Catatan di bawahnya dibuat dari angka (hari dan jam tertinggi), bukan dari AI.
export default function PolaKeramaian() {
  const { data, ready } = useWeek();
  return (
    <Card>
      <CardTitle sub="Persentase kapasitas per jam, 7 hari terakhir (dari tiket yang discan)">Pola Keramaian Minggu Ini</CardTitle>
      <div className="mt-5">
        {data
          ? <Heatmap hours={data.hours} rows={data.days} />
          : <p className="grid h-48 place-items-center rounded-2xl bg-paper text-sm text-abu">{ready ? "Belum ada data." : "Memuat pola keramaian..."}</p>}
      </div>
      {data && (
        <p className="mt-4 flex items-start gap-2.5 rounded-2xl bg-leaf/12 px-4 py-3 text-sm text-ink">
          <Info size={16} className="mt-0.5 shrink-0 text-forest" aria-hidden="true" /> {data.note}
        </p>
      )}
    </Card>
  );
}
