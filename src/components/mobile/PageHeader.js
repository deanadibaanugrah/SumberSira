"use client";

import { ArrowLeft } from "lucide-react";
import { useRouter } from "next/navigation";

// Header halaman mobile: tombol kembali bulat (kaca) + judul serif, seperti di desain.
export default function PageHeader({ title, backHref, children }) {
  const router = useRouter();
  const goBack = () => (backHref ? router.push(backHref) : router.back());
  return (
    <header className="flex items-center gap-3 pt-[34px] pb-[18px]">
      <button type="button" onClick={goBack} aria-label="Kembali"
              className="glass grid size-8 shrink-0 place-items-center rounded-full text-white transition hover:bg-white/15">
        <ArrowLeft size={15} strokeWidth={2.6} />
      </button>
      {children ?? <h1 className="font-display text-base font-semibold leading-tight text-white">{title}</h1>}
    </header>
  );
}
