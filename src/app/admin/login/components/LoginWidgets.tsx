"use client";

import { Clock, Ticket, Users } from "lucide-react";

import { useCrowd } from "@/lib/crowd-store";
import { jamBukaHariIni } from "@/lib/jam-buka";

// Widget kaca yang melayang di halaman login: angka Live Crowd nyata dari tiket yang discan (src/lib/crowd-store.ts, tanpa login).
const glass = "rounded-[24px] border border-white/20 bg-white/10 p-5 text-white shadow-[0_20px_50px_rgba(0,0,0,0.25)] backdrop-blur-xl";
// Jari-jari dan keliling cincin progres di widget Live Crowd.
const R = 34;
const C = 2 * Math.PI * R;

// Titik hijau berdenyut tanda data live.
function Ping() {
  return (
    <span className="relative flex size-2">
      <span className="absolute inline-flex size-full animate-ping rounded-full bg-leaf opacity-70" />
      <span className="relative size-2 rounded-full bg-leaf" />
    </span>
  );
}

// Widget Live Crowd: cincin progres persen keramaian dan jumlah orang di dalam.
export function CrowdWidget({ className = "" }) {
  const t = useCrowd();
  return (
    <div className={`${glass} ${className}`} style={{ animation: "float-y 6s ease-in-out infinite" }}>
      <p className="flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.14em] text-white/75"><Ping /> Live Crowd</p>
      <div className="mt-4 flex items-center gap-4">
        {/* Cincin progres: panjang garis mengikuti persen keramaian, jadi merah kalau Ramai */}
        <svg viewBox="0 0 80 80" className="size-20 shrink-0 -rotate-90" role="img" aria-label={`Keramaian ${t.percent}%`}>
          <circle cx="40" cy="40" r={R} fill="none" stroke="rgba(255,255,255,0.15)" strokeWidth="8" />
          <circle cx="40" cy="40" r={R} fill="none" stroke={t.label === "Ramai" ? "#e07a5f" : "#ffffff"} strokeWidth="8" strokeLinecap="round"
                  strokeDasharray={C} strokeDashoffset={C * (1 - t.percent / 100)} style={{ transition: "stroke-dashoffset 0.8s ease" }} />
        </svg>
        <div>
          <p className="font-display text-[34px] font-semibold leading-none">{t.ready ? `${t.percent}%` : "..."}</p>
          <p className="mt-1.5 inline-flex rounded-full bg-white px-2.5 py-0.5 text-xs font-semibold text-forest">{t.label}</p>
        </div>
      </div>
      <p className="mt-4 flex items-center gap-2 text-sm text-white/85"><Users size={15} /> {t.ready ? t.inside : "-"} dari {t.capacity} orang di dalam</p>
    </div>
  );
}

// Widget jumlah tiket online terjual hari ini dengan grafik batang kecil.
export function TiketWidget({ className = "" }) {
  const t = useCrowd();
  const bars = [30, 45, 38, 60, 52, 80, 100];
  return (
    <div className={`${glass} ${className}`} style={{ animation: "float-y 7s ease-in-out 1.2s infinite" }}>
      <p className="flex items-center gap-2 text-xs text-white/75"><Ticket size={14} /> Tiket online hari ini</p>
      <p className="mt-2 font-display text-[28px] font-semibold leading-none tabular-nums">{t.ready ? t.sold : "-"}<span className="ml-1 font-sans text-sm font-normal text-white/70">tiket</span></p>
      <div className="mt-3 flex h-10 items-end gap-1.5" aria-hidden="true">
        {bars.map((h, i) => (
          <span key={i} className={`flex-1 origin-bottom rounded-[4px] animate-grow-up ${i === bars.length - 1 ? "bg-white" : "bg-white/30"}`}
                style={{ height: `${h}%`, animationDelay: `${300 + i * 80}ms` }} />
        ))}
      </div>
    </div>
  );
}

// Widget jam buka hari ini (weekday dan weekend berbeda).
export function JamBukaWidget({ className = "" }) {
  const { label, weekend } = jamBukaHariIni();
  return (
    <div className={`${glass} ${className}`} style={{ animation: "float-y 8s ease-in-out 0.6s infinite" }}>
      <p className="flex items-center gap-2 text-xs text-white/75"><Clock size={14} /> Buka hari ini</p>
      <p className="mt-2 font-display text-[28px] font-semibold leading-none tabular-nums">{label}</p>
      <p className="mt-3 text-xs text-white/75">{weekend ? "Akhir pekan" : "Hari kerja"} · Desa Putukrejo, Malang</p>
    </div>
  );
}

// Versi ringkas untuk layar kecil (di atas form).
export function CrowdChip() {
  const t = useCrowd();
  return (
    <span className="inline-flex items-center gap-2 rounded-full border border-white/25 bg-white/10 px-3 py-1.5 text-xs text-white backdrop-blur-md">
      <Ping /> Live Crowd {t.ready ? `${t.percent}% · ${t.label}` : "..."}
    </span>
  );
}
