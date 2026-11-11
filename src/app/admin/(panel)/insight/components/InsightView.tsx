"use client";

import { Download } from "lucide-react";
import { useState } from "react";

import PolaKeramaian from "@/components/admin/PolaKeramaian";
import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import { useInsight, type InsightData } from "@/lib/insight-store";

import GrafikKeramaian from "./GrafikKeramaian";
import PuncakPerJam from "./PuncakPerJam";
import RincianTiket from "./RincianTiket";
import RingkasanHari from "./RingkasanHari";

// Hari ini (WIB) dalam bentuk 2026-11-11, dipakai sebagai batas tanggal yang boleh dipilih.
const hariIni = () => new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Jakarta" }).format(new Date());

// Mengunduh grafik hari itu sebagai file CSV (bisa dibuka di Excel / Google Sheets).
function unduhCsv(data: InsightData) {
  const rows = [
    ["Waktu (WIB)", "Orang di dalam", "Persen kapasitas"],
    ...data.timeline.map((p) => [p.label, p.inside, p.percent]),
    [],
    ["Jam", "Puncak orang di dalam", "Persen kapasitas"],
    ...data.hourly.map((h) => [`${String(h.hour).padStart(2, "0")}.00`, h.peak, h.percent]),
  ];
  const blob = new Blob([rows.map((r) => r.join(",")).join("\n")], { type: "text/csv;charset=utf-8" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = `insight-keramaian-${data.date}.csv`;
  a.click();
  URL.revokeObjectURL(a.href);
}

// Halaman Insight: grafik keramaian sepanjang hari, ringkasan, puncak per jam, rincian tiket, dan pola 7 hari.
export default function InsightView() {
  // date "" = hari ini (data disegarkan otomatis); tanggal lain = rekap hari itu.
  const [date, setDate] = useState("");
  const { data, ready, error } = useInsight(date);

  return (
    <>
      <AdminHeader title="Insight Keramaian" subtitle="Naik saat tiket discan masuk, turun saat pengunjung keluar, per hari"
                   action={
                     <div className="flex items-center gap-2">
                       <label className="flex h-12 items-center gap-2 rounded-full border border-ink/10 bg-white px-4 text-sm text-abu">
                         <span className="sr-only md:not-sr-only">Tanggal</span>
                         <input type="date" value={date || hariIni()} max={hariIni()} onChange={(e) => setDate(e.target.value === hariIni() ? "" : e.target.value)}
                                className="bg-transparent text-ink outline-none" aria-label="Pilih tanggal" />
                       </label>
                       <PrimaryButton icon={Download} disabled={!data} onClick={() => data && unduhCsv(data)}>Unduh CSV</PrimaryButton>
                     </div>
                   } />

      {error && !data && (
        <p role="alert" className="mt-6 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">Data keramaian belum bisa dimuat. Pastikan backend menyala, lalu muat ulang halaman.</p>
      )}

      <div className="mt-6 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <GrafikKeramaian data={data} ready={ready} />
        <RingkasanHari data={data} />
        <PuncakPerJam data={data} />
        <RincianTiket data={data} />
      </div>

      <div className="mt-5">
        <PolaKeramaian />
      </div>
    </>
  );
}
