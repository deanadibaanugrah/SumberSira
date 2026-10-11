"use client";

import { Ticket } from "lucide-react";
import Link from "next/link";

import ProgressBar from "@/components/charts/ProgressBar";
import { KAPASITAS, useTiket } from "@/lib/tiket-store";

// Angka keramaian di aplikasi pengunjung, dihitung dari tiket online yang sudah discan masuk.

// Titik kecil berdenyut sebagai tanda data live.
function LivePing({ className = "bg-white" }) {
  return (
    <span className="relative flex size-2 shrink-0">
      <span className={`absolute inline-flex size-full animate-ping rounded-full opacity-60 ${className}`} />
      <span className={`relative size-2 rounded-full ${className}`} />
    </span>
  );
}

// Pill di Home: "Crowd saat ini: Sedang".
export function CrowdNowPill() {
  // Data tiket dan ringkasan keramaian diambil dari useTiket, jadi angkanya ikut berubah saat ada scan.
  const t = useTiket();
  return (
    <Link href="/app/crowd" className="glass mt-4 flex h-10 items-center justify-between rounded-full px-4">
      <span className="flex items-center gap-2 text-[11px]">
        <LivePing /> Crowd saat ini: {t.label}
      </span>
      <span className="text-[10px] font-semibold">Lihat prediksi &gt;</span>
    </Link>
  );
}

// Kartu status utama di halaman Live Crowd.
export function CrowdStatusCard() {
  const t = useTiket();
  return (
    <section className="glass rounded-[20px] px-5 pb-4 pt-[19px]">
      <p className="flex items-center gap-2 text-[11px] text-white/75"><LivePing className="bg-leaf" /> Status Saat Ini</p>
      <div className="mt-1 flex items-center">
        <span className="w-[155px] font-display text-[38px] font-semibold leading-tight">{t.percent}%</span>
        <span className={`grid h-8 w-[90px] place-items-center rounded-full text-xs font-semibold ${t.label === "Ramai" ? "bg-coral text-white" : "bg-white/95 text-forest"}`}>
          {t.label}
        </span>
      </div>
      <div className="mt-4">
        <ProgressBar value={t.percent} fillClass={t.label === "Ramai" ? "bg-coral" : "bg-white/90"} trackClass="bg-white/15" height="h-3.5" />
      </div>
      <p className="mt-2.5 text-[11px]"><span className="font-semibold">{t.inside} orang</span> <span className="text-white/70">di dalam dari kapasitas {KAPASITAS}</span></p>
      <p className="mt-1.5 flex items-center gap-1.5 text-[9.5px] text-white/65">
        <Ticket size={11} className="shrink-0" /> Dihitung dari tiket online yang sudah discan di pintu masuk
        {t.updatedAt ? `, update ${t.updatedAt}` : ""}
      </p>
    </section>
  );
}

// Banner kecil di halaman tiket.
export function LiveCrowdBanner() {
  const t = useTiket();
  return (
    <Link href="/app/crowd" className="glass flex items-center gap-3 rounded-[20px] px-4 py-3">
      <LivePing className="bg-leaf" />
      <span className="flex-1 text-[11px]">
        Sekarang <span className="font-semibold">{t.inside} orang</span> di dalam · <span className="font-semibold">{t.label} ({t.percent}%)</span>
        <span className="block text-[9.5px] text-white/65">Dari tiket yang sudah discan di pintu masuk</span>
      </span>
    </Link>
  );
}

// Warna label status tiket.
const STATUS_STYLE = {
  "Belum masuk": "bg-white/15 text-white",
  "Di dalam": "bg-leaf text-white",
  Keluar: "bg-white/10 text-white/70",
};

// Label status tiket: Belum masuk, Di dalam, atau Keluar.
export function TicketStatus({ status, className = "" }) {
  return (
    <span className={`inline-flex h-6 items-center rounded-full px-2.5 text-[9.5px] font-semibold ${STATUS_STYLE[status] ?? STATUS_STYLE["Belum masuk"]} ${className}`}>
      {status}
    </span>
  );
}
