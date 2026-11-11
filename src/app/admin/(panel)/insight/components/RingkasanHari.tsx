import { rupiah } from "@/lib/format";
import type { InsightData } from "@/lib/insight-store";

import { TrendingUp } from "lucide-react";

// Catatan singkat dari aturan sederhana (bukan AI): menyesuaikan dengan label keramaian saat ini.
const CATATAN = {
  Sepi: "Masih lengang. Cocok untuk pengunjung yang ingin suasana tenang.",
  Sedang: "Pengunjung mulai banyak. Pantau antrean di loket dan pintu masuk.",
  Ramai: "Hampir penuh. Siapkan petugas tambahan di pintu masuk dan parkir.",
};

// "2026-11-11" -> "Rabu, 11 November 2026"
const tanggal = (d: string) =>
  new Intl.DateTimeFormat("id-ID", { weekday: "long", day: "numeric", month: "long", year: "numeric", timeZone: "Asia/Jakarta" }).format(new Date(`${d}T00:00:00+07:00`));

// Kartu hijau ringkasan hari yang dipilih: keramaian sekarang (hanya hari ini), jam tersibuk, tiket, dan pendapatan.
export default function RingkasanHari({ data }: { data: InsightData | null }) {
  const s = data?.summary;
  const live = data?.crowd;
  const peak = s?.peak;
  return (
    <section className="rounded-3xl bg-gradient-to-b from-forest to-ink p-6 text-white">
      <div className="flex items-center gap-3">
        <span className="grid size-10 place-items-center rounded-full bg-white/12"><TrendingUp size={18} aria-hidden="true" /></span>
        <div>
          <h2 className="text-lg font-semibold leading-tight">Ringkasan Hari</h2>
          <p className="text-[13px] text-white/70">{data ? tanggal(data.date) : "Memuat..."}</p>
        </div>
      </div>

      <div className="mt-5 flex items-end justify-between gap-4">
        <div>
          <p className="text-[13px] text-white/70">{live ? "Keramaian sekarang" : "Jam tersibuk"}</p>
          <p className="font-display text-5xl font-semibold leading-none tabular-nums">
            {live ? `${live.percent}%` : peak ? `${String(peak.hour).padStart(2, "0")}.00` : "-"}
          </p>
          <p className="mt-2 text-sm text-white/80">
            {live ? `${live.inside} orang di dalam · ${live.label}` : peak ? `${peak.peak} orang · ${peak.percent}% kapasitas` : "Tidak ada pengunjung"}
          </p>
        </div>
        {live && (
          <div className="w-[160px] rounded-2xl bg-white/10 p-3.5">
            <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-white/70">Catatan</p>
            <p className="mt-1.5 text-sm font-semibold leading-snug">{CATATAN[live.label] ?? CATATAN.Sepi}</p>
          </div>
        )}
      </div>

      <dl className="mt-5 grid grid-cols-3 gap-2 text-center">
        {[
          ["Tiket terjual", `${s?.sold ?? 0}`],
          ["Orang masuk", `${s?.entered ?? 0}`],
          ["Pendapatan", rupiah(s?.revenue ?? 0)],
        ].map(([k, v]) => (
          <div key={k} className="rounded-2xl bg-white/10 px-2 py-2.5">
            <dt className="text-[11px] text-white/70">{k}</dt>
            <dd className="mt-0.5 text-sm font-semibold tabular-nums">{v}</dd>
          </div>
        ))}
      </dl>
      {live && peak && <p className="mt-4 text-[13px] text-white/70">Jam tersibuk hari ini {String(peak.hour).padStart(2, "0")}.00, {peak.peak} orang ({peak.percent}%).</p>}
    </section>
  );
}
