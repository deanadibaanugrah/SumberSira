"use client";

import { ArrowUp, Sparkles } from "lucide-react";
import Image from "next/image";
import { useEffect, useRef, useState } from "react";

import BottomNav from "@/components/mobile/BottomNav";
import PageHeader from "@/components/mobile/PageHeader";
import { GALLERY } from "@/data/dummy";

// Foto "sebelum" = foto bawah air yang buram/kusam; "sesudah" = hasil enhance.
// Tahap UTS: enhance disimulasikan dengan filter CSS. Tahap backend: kirim foto ke API AI, tampilkan hasilnya.
const DULL = "saturate(0.25) brightness(0.7) contrast(0.85)";
const ENHANCE = "saturate(1.45) contrast(1.12) brightness(1.06)";
const COMMUNITY = ["/images/komunitas-1.webp", "/images/komunitas-2.webp", "/images/komunitas-3.webp"];

function Photo({ src, label, filter, badge }) {
  return (
    <figure className="relative aspect-[161/200] overflow-hidden rounded-[20px] border border-white/20">
      {/* Foto unggahan pengguna berupa blob URL, jadi pakai <img> biasa. */}
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img src={src} alt={`Foto ${label.toLowerCase()} enhance`} className="size-full object-cover" style={{ filter }} />
      {badge && (
        <span className="absolute right-3 top-3 flex h-6 items-center gap-1 rounded-full bg-white/95 px-2.5 text-[8.5px] font-semibold text-forest">
          <Sparkles size={10} className="text-leaf" /> AI Enhanced
        </span>
      )}
      <figcaption className="glass absolute bottom-2.5 left-3 flex h-6 items-center rounded-full px-3 text-[10px] font-semibold">{label}</figcaption>
    </figure>
  );
}

export default function AiPhotoPage() {
  const [photo, setPhoto] = useState(null);
  const [showAll, setShowAll] = useState(false);
  const input = useRef(null);

  useEffect(() => () => photo && URL.revokeObjectURL(photo), [photo]);

  const onPick = (e) => {
    const file = e.target.files?.[0];
    if (file) setPhoto(URL.createObjectURL(file));
  };

  const src = photo ?? "/images/onboarding-bawah-air.webp";
  return (
    <main className="px-5 pb-24">
      <PageHeader title="AI Underwater Photo Studio" backHref="/app/home" />

      <div className="grid grid-cols-2 gap-3">
        <Photo src={src} label="Sebelum" filter={photo ? "none" : DULL} />
        <Photo src={src} label="Sesudah" filter={photo ? ENHANCE : "none"} badge />
      </div>

      <input ref={input} type="file" accept="image/*" className="hidden" onChange={onPick} />
      <button type="button" onClick={() => input.current?.click()}
              className="mt-5 flex h-12 w-full items-center gap-3 rounded-full bg-leaf px-5 text-xs font-semibold shadow-lg shadow-black/25 transition hover:brightness-110">
        <span className="grid size-6 place-items-center rounded-full bg-white/15"><ArrowUp size={16} strokeWidth={1.8} /></span>
        Upload Foto untuk Enhance
      </button>
      {photo && <p className="mt-2 text-center text-[9px] text-white/60">Tampilan enhance masih simulasi; proses AI sungguhan dikerjakan di tahap backend.</p>}

      <div className="mt-7 flex items-center justify-between pr-[13px]">
        <h2 className="font-display text-[15px] font-semibold">Galeri Komunitas</h2>
        <button type="button" onClick={() => setShowAll((v) => !v)} className="text-[10px] font-semibold">
          {showAll ? "Sembunyikan" : "Lihat semua >"}
        </button>
      </div>
      <div className="mt-3 grid grid-cols-3 gap-3">
        {COMMUNITY.map((src) => (
          <div key={src} className="relative aspect-[103/110] overflow-hidden rounded-[20px]">
            <Image src={src} alt="Foto pengunjung Sumber Sira" fill sizes="140px" className="object-cover" />
          </div>
        ))}
        {showAll && GALLERY.filter((g) => g.status === "Ditampilkan").map((g) => (
          <div key={g.id} className="relative aspect-[103/110] overflow-hidden rounded-[20px] animate-fade-up">
            <Image src={g.src} alt={`Foto dari ${g.owner}`} fill sizes="140px" className="object-cover" style={{ objectPosition: g.pos }} />
          </div>
        ))}
      </div>
      <p className="mt-2 text-[9px] text-white/65">Diambil oleh pengunjung, di-enhance otomatis oleh AI</p>

      <BottomNav />
    </main>
  );
}
