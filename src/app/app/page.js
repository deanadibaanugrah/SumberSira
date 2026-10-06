"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

// Layar Splash: tampil sebentar, lalu lanjut otomatis ke "Tentang Sumber Sira". Ketuk untuk lewati.
// Posisi elemen memakai persen tinggi layar agar sejajar dengan foto latar (rasio frame desain 375×812).
export default function SplashPage() {
  const router = useRouter();
  const [dot, setDot] = useState(1);

  useEffect(() => {
    const timer = setTimeout(() => router.replace("/app/tentang"), 2600);
    const loader = setInterval(() => setDot((d) => (d + 1) % 3), 450);
    return () => {
      clearTimeout(timer);
      clearInterval(loader);
    };
  }, [router]);

  return (
    <button type="button" onClick={() => router.replace("/app/tentang")} aria-label="Masuk ke aplikasi"
            className="relative block min-h-dvh w-full overflow-hidden text-left">
      <Image src="/images/splash-sumber-sira.webp" alt="" fill priority sizes="430px" className="object-cover" />

      <div className="absolute left-1/2 top-[37%] size-[100px] -translate-x-1/2">
        <span className="absolute inset-0 rounded-full border border-white/40 bg-gradient-to-b from-white/10 to-white/0 backdrop-blur-[2px] animate-pop" />
        <h1 className="absolute left-1/2 top-[54px] -translate-x-1/2 -translate-y-1/2 whitespace-nowrap font-display text-[28px] font-semibold animate-fade-up">
          Sumber Sira
        </h1>
        <p className="absolute left-1/2 top-[87px] -translate-x-1/2 -translate-y-1/2 whitespace-nowrap text-xs text-white/85 animate-fade-up"
           style={{ animationDelay: "200ms" }}>
          Kunjungan Jernih Tanpa Antre
        </p>
      </div>

      <div className="absolute inset-x-0 bottom-[12.9%] flex justify-center gap-2" aria-hidden="true">
        {[0, 1, 2].map((i) => (
          <span key={i} className={`size-2 rounded-full transition-colors duration-300 ${i === dot ? "bg-white" : "bg-white/20"}`} />
        ))}
      </div>
    </button>
  );
}
