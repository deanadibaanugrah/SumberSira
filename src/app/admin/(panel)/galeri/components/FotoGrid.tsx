import Image from "next/image";

import { StatusPill } from "@/components/admin/ui";
import type { GALLERY } from "@/data/dummy";

import AiBadge from "./AiBadge";
import AksiFoto from "./AksiFoto";
import { formatDate } from "./tanggal";

// Tampilan grid: kartu foto dengan label AI, nama pengirim, tanggal, status, dan tombol aksi.
export default function FotoGrid({ visible, onSet }: { visible: typeof GALLERY; onSet: (id: number, status: string) => void }) {
  return (
    <div className="mt-5 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      {visible.map((p) => (
        <article key={p.id} className="rounded-3xl bg-white p-3 pb-4 animate-fade-up">
          <div className="relative aspect-[245/150] overflow-hidden rounded-2xl">
            <Image src={p.src} alt={`Foto dari ${p.owner}`} fill sizes="(min-width:1280px) 25vw, 50vw" className="object-cover" style={{ objectPosition: p.pos }} />
            <AiBadge className="absolute left-2.5 top-2.5" />
          </div>
          <div className="px-1">
            <p className="mt-3 text-[15px] font-semibold text-ink">{p.owner}</p>
            <p className="mt-0.5 text-[13px] text-abu">{formatDate(p.date)}</p>
            <div className="mt-4 flex items-center justify-between">
              <StatusPill status={p.status} />
              <AksiFoto photo={p} onSet={onSet} />
            </div>
          </div>
        </article>
      ))}
    </div>
  );
}
