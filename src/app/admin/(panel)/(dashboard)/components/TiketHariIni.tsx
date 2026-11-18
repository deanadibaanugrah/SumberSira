"use client";

import { ArrowRight } from "lucide-react";
import Link from "next/link";

import ProgressBar from "@/components/charts/ProgressBar";
import { Avatar } from "@/components/admin/ui";
import { jumlahOrang, useTiket } from "@/lib/tiket-store";

// Warna batang keramaian sesuai status.
const BAR: Record<string, string> = { Sepi: "bg-leaf", Sedang: "bg-leaf/30", Ramai: "bg-coral" };

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
  const kapasitas = t.capacity; // dari server via /crowd; null sampai data tersedia
  const persen = t.percent; // dari server via /crowd; null bila kapasitas belum ada
  const label = t.label; // tingkat keramaian; null bila tidak ada data

  return (
    <section className="flex flex-col rounded-3xl bg-white p-6">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h2 className="text-lg font-semibold leading-tight">Tiket Online Hari Ini</h2>
          <p className="mt-1.5 text-[13px] text-abu">Dasar perhitungan Live Crowd</p>
        </div>
        <LiveDot />
      </div>

      {t.ready && kapasitas != null && persen != null ? (
        <>
          <p className="mt-5 flex items-end gap-2">
            <span className="font-display text-[40px] font-semibold leading-none tabular-nums text-forest">{t.inside}</span>
            <span className="pb-1 text-sm text-abu">/ {kapasitas} orang di dalam</span>
          </p>
          <div className="mt-3">
            <ProgressBar value={persen} fillClass={BAR[label ?? "Sepi"]} trackClass="bg-ink/10" height="h-3" />
          </div>
        </>
      ) : (
        <p className="mt-5 grid h-40 place-items-center rounded-2xl bg-paper text-sm text-abu">
          {t.error ? "Tidak bisa terhubung ke server." : "Memuat data..."}
        </p>
      )}

      <dl className="mt-4 grid grid-cols-3 gap-2 text-center">
        {[["Terjual", `${t.sold} tiket`], ["Belum datang", `${t.waiting} orang`], ["Sudah keluar", `${t.out} orang`]].map(([k, v]) => (
          <div key={k} className="rounded-2xl bg-paper px-2 py-2.5">
            <dt className="text-[11px] text-abu">{k}</dt>
            <dd className="mt-0.5 text-sm font-semibold">{v}</dd>
          </div>
        ))}
      </dl>

      <p className="mt-4 text-[13px] text-abu">Check-in terbaru</p>
      <ul className="mt-2 space-y-2">
        {masuk.map((x) => (
          <li key={x.code} className="flex items-center gap-3 animate-fade-up">
            <Avatar name={x.name} size={30} />
            <span className="min-w-0 flex-1 truncate text-sm font-medium">{x.name}</span>
            <span className="text-xs text-abu">{jumlahOrang(x)} orang</span>
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
