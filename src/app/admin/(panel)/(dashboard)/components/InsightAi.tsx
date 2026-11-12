import { MessageCircle, Package, Sparkles, TrendingUp } from "lucide-react";
import Link from "next/link";

import { AI_NOTIFICATIONS } from "@/data/dummy";

// Ikon notifikasi Insight AI.
const NOTIF_ICONS = { trend: TrendingUp, chat: MessageCircle, box: Package };

// Kartu hijau Insight AI: notifikasi singkat dan tombol ke halaman AI Insight.
export default function InsightAi() {
  return (
    <section className="flex flex-col rounded-3xl bg-gradient-to-b from-forest to-ink p-6 text-white">
      <div className="flex items-center gap-3">
        <span className="grid size-10 place-items-center rounded-full bg-white/12"><Sparkles size={18} aria-hidden="true" /></span>
        <div>
          <h2 className="text-lg font-semibold leading-tight">Insight AI</h2>
          <p className="text-[13px] text-white/70">Diperbarui 2 menit lalu</p>
        </div>
      </div>
      <ul className="mt-5 space-y-2">
        {AI_NOTIFICATIONS.map((n) => {
          const Icon = NOTIF_ICONS[n.icon] ?? Sparkles;
          return (
            <li key={n.title} className="flex items-center gap-3 rounded-2xl bg-white/[0.08] px-3 py-2.5 animate-fade-up">
              <span className="grid size-9 shrink-0 place-items-center rounded-full bg-white/10"><Icon size={16} aria-hidden="true" /></span>
              <span className="min-w-0">
                <span className="block text-sm font-semibold leading-tight">{n.title}</span>
                <span className="mt-0.5 block text-xs text-white/70">{n.sub}</span>
              </span>
            </li>
          );
        })}
      </ul>
      <Link href="/admin/insight"
            className="mt-auto flex h-10 items-center justify-center gap-2 rounded-full bg-white text-[15px] font-semibold text-forest transition hover:bg-white/90 max-xl:mt-5">
        <Sparkles size={17} aria-hidden="true" /> Buka AI Insight
      </Link>
    </section>
  );
}
