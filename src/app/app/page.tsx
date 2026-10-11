"use client";

import { MapPin } from "lucide-react";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

import LogoMark from "@/components/Logo";
import { FOTO } from "@/lib/foto";

// Layar Splash: tampil sebentar, lalu lanjut otomatis ke "Tentang Sumber Sira". Ketuk untuk lewati.
// Supaya tidak membosankan: foto latar bergerak pelan, riak air keluar dari logo, gelembung naik,
// ombak di bawah, dan garis loading terisi sampai pindah halaman. Semua animasi memakai CSS (globals.css).
const DURASI = 3200; // lama splash dalam milidetik sebelum pindah otomatis

// Tiga keunggulan singkat yang muncul bergantian di bawah nama.
const CHIPS = ["Air jernih", "Tanpa antre", "Live Crowd"];

// Gelembung air: [posisi kiri %, ukuran px, durasi naik (detik), jeda mulai (detik)].
const BUBBLES = [[10, 8, 7, 0], [22, 5, 6, 1.5], [35, 10, 8, 0.6], [52, 6, 6.5, 2.2], [64, 9, 7.5, 0.9], [76, 5, 6, 1.8], [88, 11, 8.5, 0.3]];

// Bentuk ombak (path SVG), sama dengan ombak di halaman login admin.
const WAVE = "M0 40 C 120 10, 240 70, 360 40 S 600 10, 720 40 S 960 70, 1080 40 S 1320 10, 1440 40 V 120 H 0 Z";

// Halaman Splash: pembuka aplikasi sebelum halaman Tentang.
export default function SplashPage() {
  const router = useRouter();

  // Setelah DURASI habis, pindah otomatis ke halaman Tentang.
  useEffect(() => {
    const timer = setTimeout(() => router.replace("/app/tentang"), DURASI);
    return () => clearTimeout(timer);
  }, [router]);

  return (
    <button type="button" onClick={() => router.replace("/app/tentang")} aria-label="Masuk ke aplikasi"
            className="relative block min-h-dvh w-full overflow-hidden text-left">
      {/* Foto latar yang pelan-pelan membesar (efek Ken Burns) */}
      <div className="absolute inset-0" style={{ animation: "ken-burns 9s ease-in-out infinite alternate" }}>
        <Image src={FOTO.splash} alt="" fill priority sizes="430px" className="object-cover" />
      </div>
      {/* Lapisan warna: hijau di atas, gelap di bawah, dan cahaya hijau di belakang logo */}
      <div className="absolute inset-0 bg-gradient-to-b from-forest/60 via-forest/25 to-ink/90" />
      <div className="absolute inset-0 bg-[radial-gradient(60%_35%_at_50%_37%,rgba(64,145,108,0.45),transparent_70%)]" />

      {/* Gelembung air yang naik dari bawah */}
      {BUBBLES.map(([left, size, dur, delay], i) => (
        <span key={i} aria-hidden="true" className="absolute bottom-[-20px] rounded-full border border-white/40 bg-white/10"
              style={{ left: `${left}%`, width: size, height: size, animation: `bubble-rise ${dur}s ease-in ${delay}s infinite` }} />
      ))}

      {/* Lokasi di bagian atas */}
      <p className="glass absolute left-1/2 top-[7%] flex -translate-x-1/2 items-center gap-1.5 whitespace-nowrap rounded-full px-3 py-1.5 text-[10px] font-medium animate-fade-up">
        <MapPin size={11} aria-hidden="true" /> Desa Putukrejo, Malang
      </p>

      <div className="absolute inset-x-0 top-[29%] flex flex-col items-center">
        {/* Riak air: tiga lingkaran bergantian melebar dari logo lalu hilang */}
        <div className="relative grid size-24 place-items-center">
          {[0, 1, 2].map((i) => (
            <span key={i} aria-hidden="true" className="absolute inset-0 rounded-full border-2 border-white/50"
                  style={{ animation: `splash-ring 2.4s ease-out ${i * 0.8}s infinite` }} />
          ))}
          <LogoMark size={96} ring className="shadow-xl shadow-black/30 animate-pop" />
        </div>

        {/* Nama dan tagline muncul bergantian */}
        <h1 className="mt-7 whitespace-nowrap font-display text-[34px] font-semibold leading-tight animate-fade-up" style={{ animationDelay: "250ms" }}>
          Sumber Sira
        </h1>
        <p className="mt-1.5 whitespace-nowrap text-[13px] text-white/85 animate-fade-up" style={{ animationDelay: "400ms" }}>
          Kunjungan Jernih Tanpa Antre
        </p>

        {/* Chip keunggulan, muncul satu per satu */}
        <ul className="mt-5 flex gap-2">
          {CHIPS.map((chip, i) => (
            <li key={chip} className="glass flex h-7 items-center gap-1.5 rounded-full px-3 text-[10px] font-medium animate-fade-up"
                style={{ animationDelay: `${650 + i * 150}ms` }}>
              <span className="size-1.5 rounded-full bg-leaf" aria-hidden="true" /> {chip}
            </li>
          ))}
        </ul>
      </div>

      {/* Dua lapis ombak yang bergeser terus di bagian bawah */}
      <div className="absolute inset-x-0 bottom-0 h-24 overflow-hidden" aria-hidden="true">
        <svg viewBox="0 0 2880 120" preserveAspectRatio="none" className="absolute bottom-0 h-full w-[200%]"
             style={{ animation: "wave-x 14s linear infinite" }}>
          <path d={WAVE} fill="rgba(255,255,255,0.07)" />
          <path d={WAVE} transform="translate(1440 0)" fill="rgba(255,255,255,0.07)" />
        </svg>
        <svg viewBox="0 0 2880 120" preserveAspectRatio="none" className="absolute -bottom-2 h-[80%] w-[200%]"
             style={{ animation: "wave-x 9s linear infinite reverse" }}>
          <path d={WAVE} fill="rgba(64,145,108,0.3)" />
          <path d={WAVE} transform="translate(1440 0)" fill="rgba(64,145,108,0.3)" />
        </svg>
      </div>

      {/* Garis loading: terisi penuh tepat saat pindah ke halaman berikutnya */}
      <div className="absolute inset-x-0 bottom-[8.5%] flex flex-col items-center" aria-hidden="true">
        <span className="h-1.5 w-40 overflow-hidden rounded-full bg-white/20">
          <span className="block h-full origin-left rounded-full bg-white" style={{ animation: `fill-x ${DURASI}ms linear both` }} />
        </span>
        <span className="mt-2.5 text-[10px] text-white/75">Menyiapkan kunjunganmu...</span>
        <span className="mt-1 text-[9px] text-white/50">Ketuk di mana saja untuk lanjut</span>
      </div>
    </button>
  );
}
