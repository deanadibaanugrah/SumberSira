"use client";

import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useRef, useState } from "react";

import { FOTO } from "@/lib/foto";

// Onboarding 3 slide: bisa digeser (swipe/drag) DAN pakai tombol Kembali/Lanjut (syarat dosen).
// Slide juga maju sendiri tiap AUTOPLAY_MS sampai slide ketiga, lalu berhenti (tidak berulang).
// Begitu pengguna menggeser atau menekan tombol/titik, putar otomatis berhenti dan pengguna yang mengatur.
// Isi tiga slide onboarding: foto, judul, dan teks.
const SLIDES = [
  {
    image: FOTO.airJernih,
    title: "Air Jernih dari Mata Air Asli",
    text: "Nikmati kolam alami dengan air jernih langsung dari sumber, dikelilingi rumput ganggang & ikan wader lokal.",
  },
  {
    image: FOTO.keretaSawah,
    title: "Booking Wahana Tanpa Antre",
    text: "Sewa ban, ATV, flying fox, & wahana lain dari rumah. Cek keramaian real-time sebelum berangkat.",
  },
  {
    image: FOTO.bawahAir,
    title: "Foto Bawah Air Jadi Lebih Jernih",
    text: "Belum ada fotografer di lokasi? AI Underwater Photo Studio bikin fotomu tetap estetik.",
  },
];
const SWIPE_THRESHOLD = 50; // px
const AUTOPLAY_MS = 2000; // jeda antar slide otomatis

// Halaman onboarding: slide bisa digeser, diklik lewat titik, atau pakai tombol Kembali dan Lanjut.
export default function OnboardingPage() {
  const router = useRouter();
  const [index, setIndex] = useState(0);
  const [drag, setDrag] = useState(0);
  const [dragging, setDragging] = useState(false);
  const [autoplay, setAutoplay] = useState(true);
  const start = useRef(null);
  const last = index === SLIDES.length - 1;
  const playing = autoplay && !last && !dragging;

  // Putar otomatis: selama masih jalan, pindah ke slide berikutnya setiap 2 detik.
  useEffect(() => {
    if (!playing) return;
    const timer = setTimeout(() => setIndex((i) => Math.min(SLIDES.length - 1, i + 1)), AUTOPLAY_MS);
    return () => clearTimeout(timer);
  }, [playing, index]);

  // Semua perpindahan dari pengguna lewat sini, sehingga putar otomatis berhenti.
  const go = (next) => {
    setAutoplay(false);
    setIndex(Math.max(0, Math.min(SLIDES.length - 1, next)));
  };
  // Selesai onboarding: masuk ke halaman Home.
  const finish = () => router.push("/app/home");

  // Mulai menggeser: catat posisi jari atau mouse.
  const onPointerDown = (e) => {
    start.current = e.clientX;
    setDragging(true);
    e.currentTarget.setPointerCapture?.(e.pointerId);
  };
  // Saat menggeser: slide ikut bergerak sejauh jari bergeser.
  const onPointerMove = (e) => {
    if (start.current !== null) setDrag(e.clientX - start.current);
  };
  // Jari dilepas: kalau geserannya lebih dari 50px, pindah slide. Kalau kurang, kembali ke posisi semula.
  const onPointerUp = () => {
    if (drag < -SWIPE_THRESHOLD) go(index + 1);
    else if (drag > SWIPE_THRESHOLD) go(index - 1);
    start.current = null;
    setDragging(false);
    setDrag(0);
  };
  // Panah kiri dan kanan di keyboard juga bisa mengganti slide.
  const onKeyDown = (e) => {
    if (e.key === "ArrowRight") go(index + 1);
    if (e.key === "ArrowLeft") go(index - 1);
  };

  return (
    <main className="flex min-h-dvh flex-col pb-8">
      <header className="flex h-16 items-end justify-end pb-3.5 pr-[45px]">
        {!last && <Link href="/app/home" className="text-[11px] font-semibold text-white/75 hover:text-white">Lewati</Link>}
      </header>

      {/* Area slide yang bisa digeser */}
      <section aria-roledescription="carousel" aria-label="Pengenalan aplikasi" tabIndex={0} onKeyDown={onKeyDown}
               className="touch-pan-y select-none overflow-hidden outline-none"
               onPointerDown={onPointerDown} onPointerMove={onPointerMove} onPointerUp={onPointerUp} onPointerCancel={onPointerUp}>
        <div className="flex" style={{
          transform: `translateX(calc(${-index * 100}% + ${drag}px))`,
          transition: dragging ? "none" : "transform 0.45s cubic-bezier(0.22, 1, 0.36, 1)",
        }}>
          {SLIDES.map((slide, i) => (
            <article key={slide.title} aria-hidden={i !== index} className="w-full shrink-0 px-5">
              <div className="relative aspect-[67/76] overflow-hidden rounded-[20px] border border-white/20">
                <Image src={slide.image} alt="" fill sizes="430px" className="pointer-events-none object-cover" priority={i === 0} draggable={false} />
              </div>
            </article>
          ))}
        </div>
      </section>

      {/* Titik penanda slide, bisa diklik untuk loncat ke slide tertentu */}
      <div className="mt-[22px] flex justify-center gap-2" role="tablist" aria-label="Pilih slide">
        {SLIDES.map((slide, i) => (
          <button key={slide.title} type="button" role="tab" aria-selected={i === index} aria-label={`Slide ${i + 1}`}
                  onClick={() => go(i)}
                  className={`relative h-2 overflow-hidden rounded-full bg-white/25 transition-all duration-300 ${i === index ? "w-5" : "w-2"}`}>
            {/* Titik aktif terisi selama jeda otomatis, jadi terlihat kapan slide berikutnya muncul. */}
            {i === index && (
              <span key={`${index}-${playing}`} className="absolute inset-0 origin-left rounded-full bg-leaf"
                    style={playing ? { animation: `fill-x ${AUTOPLAY_MS}ms linear both` } : undefined} />
            )}
          </button>
        ))}
      </div>

      {/* Judul dan teks slide yang sedang aktif */}
      <div key={index} aria-live={playing ? "off" : "polite"} className="px-9 pt-[26px] text-center animate-fade-up">
        <h1 className="font-display text-[22px] font-semibold leading-[1.2]">{SLIDES[index].title}</h1>
        <p className="mt-3.5 text-xs leading-[15px] text-white/70">{SLIDES[index].text}</p>
      </div>

      {/* Tombol Kembali & Lanjut dibagi rata (flex-1, maks 150px) dan dipasang di tengah. */}
      <div className="mt-auto flex justify-center gap-[19px] px-5 pt-8">
        {index > 0 && (
          <button type="button" onClick={() => go(index - 1)}
                  className="glass h-[50px] min-w-[130px] max-w-[150px] flex-1 rounded-full text-[13px] font-semibold transition hover:bg-white/15">
            Kembali
          </button>
        )}
        <button type="button" onClick={() => (last ? finish() : go(index + 1))}
                className="h-[50px] min-w-[130px] max-w-[150px] flex-1 rounded-full bg-leaf text-[13px] font-semibold shadow-lg shadow-black/25 transition hover:brightness-110">
          {last ? "Mulai Jelajahi" : "Lanjut"}
        </button>
      </div>
    </main>
  );
}
