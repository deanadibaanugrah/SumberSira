"use client";

import { MessageCircle, Ticket, TrendingUp, Users } from "lucide-react";
import Link from "next/link";

import { useChat } from "@/lib/chat-store";
import { useInsight } from "@/lib/insight-store";
import { jam } from "@/lib/tiket-store";

// Kartu hijau ringkasan hari ini: angka nyata dari tiket yang discan dan pertanyaan yang menunggu pengelola. Tanpa AI.
export default function RingkasanHariIni({ canInsight, canFaq }: { canInsight: boolean; canFaq: boolean }) {
  const { data } = useInsight();
  const peak = data?.summary.peak;
  return (
    <section className="flex flex-col rounded-3xl bg-gradient-to-b from-forest to-ink p-6 text-white">
      <div className="flex items-center gap-3">
        <span className="grid size-10 place-items-center rounded-full bg-white/12"><TrendingUp size={18} aria-hidden="true" /></span>
        <div>
          <h2 className="text-lg font-semibold leading-tight">Ringkasan Hari Ini</h2>
          <p className="text-[13px] text-white/70">{data ? "Dari tiket yang discan" : "Memuat..."}</p>
        </div>
      </div>
      <ul className="mt-5 space-y-2">
        <Baris icon={TrendingUp} title={peak ? `Puncak ${String(peak.hour).padStart(2, "0")}.00, ${peak.peak} orang` : "Belum ada pengunjung masuk"}
               sub={peak ? `${peak.percent}% dari kapasitas` : "Grafik naik saat tiket discan masuk"} />
        <Baris icon={Ticket} title={`${data?.summary.sold ?? 0} tiket terjual`} sub={`${data?.crowd?.waiting ?? 0} orang belum datang`} />
        {/* Pertanyaan chatbot hanya diambil untuk peran yang boleh membuka halaman Chatbot & FAQ */}
        {canFaq
          ? <Pertanyaan />
          : <Baris icon={Users} title={`${data?.crowd?.inside ?? 0} orang di dalam`} sub={data?.crowd ? `Keramaian ${data.crowd.label}` : "-"} />}
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

// Baris pertanyaan yang menunggu jawaban pengelola (dari halaman Chatbot & FAQ).
function Pertanyaan() {
  const { data } = useChat();
  const n = data?.pending.length ?? 0;
  const terlama = data?.pending[0];
  return (
    <Baris icon={MessageCircle} title={n === 0 ? "Tidak ada pertanyaan menunggu" : `${n} pertanyaan menunggu jawaban`}
           sub={terlama ? `Terlama masuk pukul ${jam(terlama.askedAt)}` : "Semua sudah dijawab"} />
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
