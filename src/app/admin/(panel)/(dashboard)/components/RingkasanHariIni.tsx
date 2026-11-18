"use client";

import { Ticket, TrendingUp, Users } from "lucide-react";
import Link from "@/components/HardLink";

import { useCrowd } from "@/viewmodels/crowd-viewmodel";
import { useDashboard } from "@/viewmodels/dashboard-viewmodel";
import { useTiket } from "@/viewmodels/tiket-viewmodel";

// Kartu hijau ringkasan hari ini: angka dari dashboard backend, tiket live, dan Live Crowd.
export default function RingkasanHariIni({ canInsight }: { canInsight: boolean }) {
  const d = useDashboard();
  const t = useTiket();
  const c = useCrowd();
  const puncak = (c.data?.forecast ?? []).reduce<{ hour: string; count: number } | null>((a, f) => (!a || f.count > a.count ? f : a), null);
  const kapasitas = c.data?.capacity ?? 0;
  const persenPuncak = puncak && kapasitas ? Math.round((puncak.count / kapasitas) * 100) : null;
  return (
    <section className="flex flex-col rounded-3xl bg-gradient-to-b from-forest to-ink p-6 text-white">
      <div className="flex items-center gap-3">
        <span className="grid size-10 place-items-center rounded-full bg-white/12"><TrendingUp size={18} aria-hidden="true" /></span>
        <div>
          <h2 className="text-lg font-semibold leading-tight">Ringkasan Hari Ini</h2>
          <p className="text-[13px] text-white/70">{d.data ? "Dari tiket yang discan" : "Memuat..."}</p>
        </div>
      </div>
      <ul className="mt-5 space-y-2">
        <Baris icon={TrendingUp}
               title={puncak ? `Prakiraan puncak ${puncak.hour}.00, ${puncak.count} orang` : "Belum ada pengunjung masuk"}
               sub={puncak ? (persenPuncak == null ? "Belum ada kapasitas dari server" : `${persenPuncak}% dari kapasitas`) : "Grafik naik saat tiket discan masuk"} />
        <Baris icon={Ticket} title={`${d.data?.ticketsToday ?? t.sold} tiket terjual`}
               sub={`${d.data?.pendingCash ?? 0} pembayaran tunai menunggu konfirmasi`} />
        <Baris icon={Users} title={`${t.inside} orang di dalam`} sub={`Keramaian ${t.label ?? "–"}`} />
      </ul>
      {canInsight && (
        <Link href="/admin/insight"
              className="mt-auto flex h-10 items-center justify-center gap-2 rounded-full bg-white text-[15px] font-semibold text-forest transition hover:bg-white/90 max-xl:mt-5">
          <TrendingUp size={17} aria-hidden="true" /> Buka Insight
        </Link>
      )}
    </section>
  );
}

function Baris({ icon: Icon, title, sub }: { icon: typeof TrendingUp; title: string; sub: string }) {
  return (
    <li className="flex items-center gap-3 rounded-2xl bg-white/[0.08] px-3 py-2.5 animate-fade-up">
      <span className="grid size-9 shrink-0 place-items-center rounded-full bg-white/10"><Icon size={16} aria-hidden="true" /></span>
      <span className="min-w-0">
        <span className="block text-sm font-semibold leading-tight">{title}</span>
        <span className="mt-0.5 block text-xs text-white/70">{sub}</span>
      </span>
    </li>
  );
}
