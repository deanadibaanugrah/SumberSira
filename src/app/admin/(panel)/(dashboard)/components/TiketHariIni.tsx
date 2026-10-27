"use client";

import { ArrowRight } from "lucide-react";
import Link from "next/link";

import ProgressBar from "@/components/charts/ProgressBar";
import { Avatar } from "@/components/admin/ui";
import { KAPASITAS, jumlahOrang, useTiket } from "@/lib/tiket-store";

// Bagian dashboard yang ikut berubah saat tiket discan (data dari src/lib/tiket-store.js).
// Warna batang keramaian sesuai status.
const BAR = { Sepi: "bg-leaf", Sedang: "bg-forest", Ramai: "bg-coral" };

// Label kecil Live dengan titik berdenyut.
function LiveDot() {
  return (
    <span className="flex h-8 items-center gap-2 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest">
      <span className="relative flex size-2">
        <span className="absolute inline-flex size-full animate-ping rounded-full bg-leaf opacity-60" />
        <span className="relative size-2 rounded-full bg-leaf" />
      </span>
      Live
    </span>
  );
}

// Kartu Tiket Online Hari Ini: jumlah orang di dalam, terjual, belum datang, keluar, dan check-in terbaru.
export default function TiketHariIni() {
  const t = useTiket();
  // Tiga pengunjung terakhir yang masih di dalam.
  const masuk = t.recent.filter((x) => x.status === "Di dalam").slice(0, 3);
  return (
    <section className="flex flex-col rounded-3xl bg-white p-6">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h2 className="text-lg font-semibold leading-tight">Tiket Online Hari Ini</h2>
          <p className="mt-1.5 text-[13px] text-ink/60">Dasar perhitungan Live Crowd</p>
        </div>
        <LiveDot />
      </div>

      <p className="mt-5 flex items-end gap-2">
        <span className="text-[40px] font-semibold leading-none tracking-tight">{t.inside}</span>
        <span className="pb-1 text-sm text-ink/60">/ {KAPASITAS} orang di dalam</span>
      </p>
      <div className="mt-3">
        <ProgressBar value={t.percent} fillClass={BAR[t.label]} trackClass="bg-ink/[0.07]" height="h-3" />
      </div>

      <dl className="mt-4 grid grid-cols-3 gap-2 text-center">
        {[["Terjual", `${t.sold} tiket`], ["Belum datang", `${t.waiting} orang`], ["Sudah keluar", `${t.out} orang`]].map(([k, v]) => (
          <div key={k} className="rounded-2xl bg-paper px-2 py-2.5">
            <dt className="text-[11px] text-ink/60">{k}</dt>
            <dd className="mt-0.5 text-sm font-semibold">{v}</dd>
          </div>
        ))}
      </dl>

      <p className="mt-4 text-[13px] text-ink/60">Check-in terbaru</p>
      <ul className="mt-2 space-y-2">
        {masuk.map((x) => (
          <li key={x.code} className="flex items-center gap-3 animate-fade-up">
            <Avatar name={x.name} size={30} />
            <span className="min-w-0 flex-1 truncate text-sm font-medium">{x.name}</span>
            <span className="text-xs text-ink/60">{jumlahOrang(x)} orang</span>
            <span className="w-11 text-right font-mono text-xs">{x.checkInAt}</span>
          </li>
        ))}
      </ul>

      <Link href="/admin/tiket" className="mt-auto flex items-center gap-1.5 pt-4 text-sm font-semibold text-leaf hover:text-forest">
        Buka Tiket & Check-in <ArrowRight size={15} />
      </Link>
    </section>
  );
}
