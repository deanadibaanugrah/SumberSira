"use client";

import { Star } from "lucide-react";
import { useState } from "react";

import PageHeader from "@/components/mobile/PageHeader";
import { REVIEWS } from "@/data/dummy";

function Stars({ value, size = 13, gap = "gap-[1.5px]" }) {
  return (
    <span className={`flex ${gap}`} aria-label={`${value} dari 5 bintang`}>
      {[1, 2, 3, 4, 5].map((n) => (
        <Star key={n} size={size} className="text-white" fill={n <= value ? "currentColor" : "none"} strokeWidth={1.6} />
      ))}
    </span>
  );
}

// Ulasan & Rating. Di desain halaman ini tidak memakai navigasi bawah; kembali lewat tombol panah.
export default function UlasanPage() {
  const [reviews, setReviews] = useState(REVIEWS);
  const [rating, setRating] = useState(4);
  const [text, setText] = useState("");
  const [sent, setSent] = useState(false);

  const submit = (e) => {
    e.preventDefault();
    if (!text.trim()) return;
    setReviews((r) => [{ id: Date.now(), name: "Kamu", stars: rating, text: text.trim() }, ...r]);
    setText("");
    setSent(true);
  };

  return (
    <main className="px-5 pb-8">
      <PageHeader backHref="/app/home">
        <h1 className="font-display text-lg font-semibold leading-tight">Ulasan &amp; Rating</h1>
      </PageHeader>

      <section className="glass flex h-[90px] items-center rounded-[20px] px-5">
        <span className="w-[70px] font-display text-[30px] font-semibold leading-none">4.8</span>
        <span>
          <Stars value={5} />
          <span className="mt-1.5 block text-[10px] text-white/75">dari {132 + reviews.length - REVIEWS.length} ulasan</span>
        </span>
      </section>

      <form onSubmit={submit} className="glass relative mt-4 min-h-[150px] rounded-[20px] px-5 pb-6 pt-4">
        <h2 className="text-xs font-semibold">Tulis Ulasan</h2>
        <div className="mt-2.5 flex gap-[1.5px]" role="radiogroup" aria-label="Pilih bintang">
          {[1, 2, 3, 4, 5].map((n) => (
            <button key={n} type="button" role="radio" aria-checked={rating === n} aria-label={`${n} bintang`}
                    onClick={() => setRating(n)} className="transition hover:scale-110">
              <Star size={17} className="text-white" fill={n <= rating ? "currentColor" : "none"} strokeWidth={1.6} />
            </button>
          ))}
        </div>
        <label htmlFor="cerita" className="sr-only">Ceritakan pengalamanmu</label>
        <textarea id="cerita" value={text} onChange={(e) => { setText(e.target.value); setSent(false); }} rows={2}
                  placeholder="Ceritakan pengalamanmu..."
                  className="glass mt-3.5 block h-[50px] w-full resize-none rounded-2xl px-3 py-3 text-[10px] text-white outline-none placeholder:text-white/60" />
        {sent && <p className="mt-1.5 text-[9.5px] text-white/80">Terima kasih! Ulasanmu sudah ditambahkan.</p>}
        <button type="submit" disabled={!text.trim()}
                className="absolute -bottom-4 left-5 h-[34px] w-[130px] rounded-full bg-leaf text-[11px] font-semibold shadow-lg shadow-black/25 transition enabled:hover:brightness-110 disabled:opacity-80">
          Kirim Ulasan
        </button>
      </form>

      <h2 className="mt-6 font-display text-sm font-semibold">Ulasan Terbaru</h2>
      <ul className="mt-3 space-y-2.5">
        {reviews.map((r) => (
          <li key={r.id} className="glass min-h-[90px] rounded-[20px] px-4 pb-3 pt-3.5 animate-fade-up">
            <div className="flex items-center gap-2.5">
              <span className="grid size-8 place-items-center rounded-full bg-moss text-[11px] font-semibold">{r.name[0]}</span>
              <span>
                <span className="block text-[10.5px] font-semibold">{r.name}</span>
                <Stars value={r.stars} size={8} gap="gap-px" />
              </span>
            </div>
            <p className="mt-2 text-[10px] text-white/80">{r.text}</p>
          </li>
        ))}
      </ul>
    </main>
  );
}
