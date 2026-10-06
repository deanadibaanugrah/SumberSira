import { Bell, Calendar, Camera, ChartColumn, MessageSquare } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

import BottomNav from "@/components/mobile/BottomNav";
import { CROWD_NOW, CROWD_TODAY } from "@/data/dummy";

const ACTIONS = [
  { href: "/app/booking", label: "Sewa & Booking", icon: Calendar },
  { href: "/app/crowd", label: "Live Crowd", icon: ChartColumn },
  { href: "/app/ai-photo", label: "AI Photo Studio", icon: Camera },
  { href: "/app/chat", label: "Tanya Sira", icon: MessageSquare },
];

// Tinggi batang (px) dari persen keramaian; ada tinggi minimum agar jam sepi tetap terlihat (sesuai desain).
const barHeight = (value) => Math.round(18 + value * 0.45);

export default function HomePage() {
  const visits = CROWD_TODAY.slice(0, 5);
  const busiest = Math.max(...visits.map((d) => d.value));
  return (
    <main className="px-5 pb-24">
      <header className="flex items-center justify-between pt-8 pb-5">
        <h1 className="font-display text-xl font-semibold">Sumber Sira</h1>
        <button type="button" aria-label="Notifikasi (ada yang baru)"
                className="glass relative grid size-9 place-items-center rounded-full">
          <Bell size={14} strokeWidth={2.6} />
          <span className="absolute -right-px -top-px size-[7px] rounded-full bg-coral" />
        </button>
      </header>

      <section className="relative h-[170px] overflow-hidden rounded-[20px] border border-white/20">
        <Image src="/images/hero-sawah.webp" alt="" fill priority sizes="430px" className="object-cover" />
        <div className="absolute inset-0 bg-gradient-to-br from-ink/70 via-ink/45 to-ink/25" />
        <div className="relative px-4 pt-5">
          <p className="font-mono text-[9px] font-medium uppercase">Sumber Sira</p>
          <h2 className="mt-2 font-display text-[22px] font-semibold leading-[1.2]">Kunjungan Jernih<br />Tanpa Antre</h2>
          <p className="mt-4 max-w-[262px] text-[11px] leading-[1.2] text-white/90">Booking wahana, cek keramaian, &amp; foto AI dalam satu app</p>
        </div>
      </section>

      <Link href="/app/crowd" className="glass mt-4 flex h-10 items-center justify-between rounded-full px-4">
        <span className="flex items-center gap-2 text-[11px]">
          <span className="size-2 rounded-full bg-white" /> Crowd saat ini: {CROWD_NOW.label}
        </span>
        <span className="text-[10px] font-semibold">Lihat prediksi &gt;</span>
      </Link>

      <nav aria-label="Fitur" className="mt-4 grid grid-cols-4 text-center">
        {ACTIONS.map(({ href, label, icon: Icon }) => (
          <Link key={href} href={href} className="group flex flex-col items-center gap-1.5">
            <span className="grid size-[55px] place-items-center rounded-2xl border border-white/25 bg-leaf/45 transition group-hover:bg-leaf">
              <Icon size={20} strokeWidth={2.4} />
            </span>
            <span className="text-[9px] leading-tight text-white/90">{label}</span>
          </Link>
        ))}
      </nav>

      <h2 className="mt-9 font-display text-[15px] font-semibold">Rekomendasi Kunjungan</h2>
      <section className="glass mt-2 h-[109px] rounded-[20px] px-4 pt-3">
        <div className="flex h-[60px] items-end gap-9 pl-1" role="img"
             aria-label={`Keramaian: ${visits.map((d) => `${d.hour}.00 ${d.value}%`).join(", ")}`}>
          {visits.map((d, i) => (
            <span key={d.hour} style={{ height: barHeight(d.value), animationDelay: `${i * 90}ms` }}
                  className={`w-6 origin-bottom rounded-md animate-grow-up ${d.value === busiest ? "bg-white/90" : "bg-leaf/70"}`} />
          ))}
        </div>
        <div className="mt-1.5 flex gap-9 pl-1 font-mono text-[8px] text-white/70" aria-hidden="true">
          {visits.map((d) => <span key={d.hour} className="w-6">{d.hour}</span>)}
        </div>
        <p className="text-[10px]">Jam sepi terbaik: 08.00–09.00</p>
      </section>

      <Link href="/app/ai-photo" className="glass mt-[25px] flex h-[89px] items-start gap-3.5 rounded-[20px] px-4 pt-3.5 transition hover:bg-white/10">
        <span className="relative mt-0.5 size-10 shrink-0 overflow-hidden rounded-full border border-white/25">
          <Image src="/images/onboarding-bawah-air.webp" alt="" fill sizes="40px" className="object-cover" />
        </span>
        <span>
          <span className="block text-xs font-semibold">AI Underwater Photo Studio</span>
          <span className="mt-0.5 block text-[10px] text-white/65">Belum ada fotografer? Coba enhance otomatis.</span>
          <span className="mt-2 block text-[10px] font-semibold">Coba Sekarang →</span>
        </span>
      </Link>

      <BottomNav />
    </main>
  );
}
