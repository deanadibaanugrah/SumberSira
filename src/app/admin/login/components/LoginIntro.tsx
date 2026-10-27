import LogoMark from "@/components/Logo";

import { CrowdWidget, RatingWidget, TiketWidget } from "./LoginWidgets";

// Kiri (layar lebar): cerita singkat + widget live.
export default function LoginIntro() {
  return (
    <section className="hidden text-white lg:block">
      <div className="flex items-center gap-3 animate-fade-up">
        <LogoMark size={48} ring label="" />
        <span>
          <span className="block font-display text-2xl font-semibold leading-tight">Sumber Sira</span>
          <span className="block text-xs text-white/70">Admin Panel · Desa Putukrejo, Malang</span>
        </span>
      </div>
      <h1 className="mt-10 max-w-[520px] font-display text-[48px] font-semibold leading-[1.08] animate-fade-up" style={{ animationDelay: "100ms" }}>
        Kelola wisata mata air dalam satu dasbor
      </h1>
      <p className="mt-4 max-w-[480px] text-[15px] leading-relaxed text-white/80 animate-fade-up" style={{ animationDelay: "200ms" }}>
        Pantau keramaian dari tiket online, konfirmasi booking, dan rangkum ulasan pengunjung dengan AI.
      </p>
      <div className="mt-10 grid max-w-[560px] grid-cols-2 gap-4">
        <CrowdWidget className="row-span-2 self-center" />
        <TiketWidget />
        <RatingWidget />
      </div>
    </section>
  );
}
