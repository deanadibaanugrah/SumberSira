import { Timer } from "lucide-react";

import LineChart from "@/components/charts/LineChart";
import ProgressBar from "@/components/charts/ProgressBar";
import BottomNav from "@/components/mobile/BottomNav";
import PageHeader from "@/components/mobile/PageHeader";
import { CROWD_NOW, CROWD_TODAY } from "@/data/dummy";

const LEGEND = [
  { label: "Sepi", dot: "bg-leaf" },
  { label: "Sedang", dot: "bg-white" },
  { label: "Ramai", dot: "bg-coral" },
];

// Live Crowd Tracker: status keramaian sekarang + prediksi per jam (data dummy, nanti dari API).
export default function CrowdPage() {
  return (
    <main className="px-5 pb-24">
      <PageHeader title="Live Crowd Tracker (AI)" backHref="/app/home" />

      <section className="glass h-[190px] rounded-[20px] px-5 pt-[19px]">
        <p className="text-[11px] text-white/75">Status Saat Ini</p>
        <div className="mt-1 flex items-center">
          <span className="w-[155px] font-display text-[38px] font-semibold leading-tight">{CROWD_NOW.percent}%</span>
          <span className="grid h-8 w-[90px] place-items-center rounded-full bg-white/95 text-xs font-semibold text-forest">{CROWD_NOW.label}</span>
        </div>
        <div className="mt-[22px]">
          <ProgressBar value={CROWD_NOW.percent} fillClass="bg-white/90" trackClass="bg-white/15" height="h-3.5" />
        </div>
        <p className="mt-2.5 font-mono text-[9px] text-white/70">Update terakhir: {CROWD_NOW.updated}</p>
      </section>

      <section className="glass mt-4 h-[230px] rounded-[20px] px-5 pt-[17px]">
        <h2 className="text-xs font-semibold">Prediksi Keramaian Hari Ini</h2>
        <div className="mt-2">
          <LineChart data={CROWD_TODAY.map((d) => ({ label: d.hour, value: d.value }))} band={[1, 3]} max={100}
                     width={295} height={172} padX={0} top={6} bottom={146} bandTop={6} labelY={164.5} labelSize={9}
                     lineColor="#ffffff" pointColor="#40916c" ringWidth={0} pointRadius={4.5} strokeWidth={3}
                     bandColor="rgba(255,255,255,0.14)" axisColor="rgba(255,255,255,0.25)" labelColor="rgba(255,255,255,0.7)" />
        </div>
      </section>

      <section className="mt-4 flex h-[79px] items-start gap-3 rounded-[20px] border border-white/20 bg-moss/40 px-4 pt-4">
        <span className="grid size-8 shrink-0 place-items-center rounded-full bg-leaf"><Timer size={16} /></span>
        <span>
          <span className="block text-[11px] font-semibold leading-tight">Waktu terbaik berkunjung</span>
          <span className="mt-1 block text-[10px] text-white/75">08.00–09.00 atau setelah 15.00</span>
        </span>
      </section>

      <ul className="mt-4 grid grid-cols-3 text-[9.5px]">
        {LEGEND.map((l) => (
          <li key={l.label} className="flex items-center gap-2"><span className={`size-[9px] rounded-full ${l.dot}`} />{l.label}</li>
        ))}
      </ul>

      <BottomNav />
    </main>
  );
}
