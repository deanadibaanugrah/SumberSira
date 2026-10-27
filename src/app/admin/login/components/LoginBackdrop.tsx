import Image from "next/image";

import { FOTO } from "@/lib/foto";

// Latar halaman login yang bergerak seperti video, dibuat dari foto asli Sumber Sira:
// foto bergantian dengan efek zoom pelan (Ken Burns), gelembung air naik, dan ombak bergerak di bawah.
// Semua memakai CSS, jadi ringan dan tidak butuh file video. Animasi dimatikan bila
// pengguna memilih "kurangi gerakan" di sistemnya (lihat globals.css).
// Empat foto latar yang bergantian, pos = bagian foto yang ditampilkan.
const SLIDES = [
  { src: FOTO.splash, pos: "50% 62%" },
  { src: FOTO.airJernih, pos: "50% 55%" },
  { src: FOTO.sawah, pos: "50% 50%" },
  { src: FOTO.keretaSawah, pos: "50% 45%" },
];

// [kiri %, ukuran px, durasi detik, jeda detik]
const BUBBLES = [
  [6, 10, 13, 0], [14, 6, 10, 3], [22, 14, 16, 6], [31, 8, 12, 1], [40, 5, 9, 7], [48, 12, 15, 4],
  [57, 7, 11, 9], [64, 16, 18, 2], [72, 6, 10, 5], [80, 11, 14, 8], [88, 8, 12, 0.5], [95, 13, 17, 6.5],
];

// Bentuk ombak (path SVG) yang dipakai dua lapis ombak di bawah.
const WAVE = "M0 40 C 120 10, 240 70, 360 40 S 600 10, 720 40 S 960 70, 1080 40 S 1320 10, 1440 40 V 120 H 0 Z";

// Komponen latar bergerak halaman login (hanya hiasan, tidak bisa diklik).
export default function LoginBackdrop() {
  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden bg-forest" aria-hidden="true">
      {/* Foto bergantian setiap 6 detik dengan efek zoom pelan */}
      {SLIDES.map((s, i) => (
        <div key={i} className="absolute inset-0 opacity-0"
             style={{ animation: "slide-fade 24s linear infinite", animationDelay: `${i * 6}s` }}>
          <div className="absolute inset-0" style={{ animation: "ken-burns 12s ease-in-out infinite alternate", animationDelay: `${i * 6}s` }}>
            <Image src={s.src} alt="" fill priority={i === 0} sizes="100vw" className="object-cover" style={{ objectPosition: s.pos }} />
          </div>
        </div>
      ))}

      {/* Lapisan warna supaya teks tetap terbaca dan nuansanya tetap dua hijau. */}
      <div className="absolute inset-0 bg-gradient-to-br from-ink/85 via-forest/70 to-forest/40" />
      <div className="absolute inset-0 bg-[radial-gradient(70%_60%_at_15%_20%,rgba(64,145,108,0.35),transparent_70%)]" />

      {/* Gelembung air yang naik dari bawah */}
      {BUBBLES.map(([left, size, dur, delay], i) => (
        <span key={i} className="absolute bottom-[-24px] rounded-full border border-white/40 bg-white/10"
              style={{ left: `${left}%`, width: size, height: size, animation: `bubble-rise ${dur}s ease-in ${delay}s infinite` }} />
      ))}

      {/* Dua lapis ombak yang bergeser terus ke arah berlawanan */}
      <div className="absolute inset-x-0 bottom-0 h-28 overflow-hidden">
        <svg viewBox="0 0 2880 120" preserveAspectRatio="none" className="absolute bottom-0 h-full w-[200%]"
             style={{ animation: "wave-x 18s linear infinite" }}>
          <path d={WAVE} fill="rgba(255,255,255,0.06)" />
          <path d={WAVE} transform="translate(1440 0)" fill="rgba(255,255,255,0.06)" />
        </svg>
        <svg viewBox="0 0 2880 120" preserveAspectRatio="none" className="absolute -bottom-3 h-[85%] w-[200%]"
             style={{ animation: "wave-x 11s linear infinite reverse" }}>
          <path d={WAVE} fill="rgba(64,145,108,0.28)" />
          <path d={WAVE} transform="translate(1440 0)" fill="rgba(64,145,108,0.28)" />
        </svg>
      </div>
    </div>
  );
}
