import { Sparkles } from "lucide-react";

import { FORECAST_SUMMARY } from "@/data/dummy";

// Kartu Ringkasan AI: jam tersibuk dan saran.
export default function RingkasanAi() {
  const s = FORECAST_SUMMARY;
  return (
    <section className="rounded-3xl bg-forest p-6 text-white">
      <div className="flex items-center gap-3">
        <span className="grid size-10 place-items-center rounded-full bg-white/12"><Sparkles size={18} aria-hidden="true" /></span>
        <div>
          <h2 className="text-lg font-semibold leading-tight">Ringkasan AI</h2>
          <p className="text-[13px] text-white/70">Untuk besok, {s.day.split(" ")[0]}</p>
        </div>
      </div>
      <div className="mt-5 flex items-end justify-between gap-4">
        <div>
          <p className="text-[13px] text-white/70">Jam tersibuk</p>
          <p className="font-display text-5xl font-semibold leading-none">{s.peakHour}</p>
          <p className="mt-2 text-sm text-white/80">{s.peakPercent}% kapasitas</p>
        </div>
        <div className="w-[160px] rounded-2xl bg-white/10 p-3.5">
          <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-white/70">Saran AI</p>
          <p className="mt-1.5 text-sm font-semibold leading-snug">{s.tip}</p>
        </div>
      </div>
    </section>
  );
}
