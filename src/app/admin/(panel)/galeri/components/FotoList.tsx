import Image from "next/image";

import { StatusPill } from "@/components/admin/ui";
import type { GALLERY } from "@/data/dummy";

import AiBadge from "./AiBadge";
import AksiFoto from "./AksiFoto";
import { formatDate } from "./tanggal";

// Tampilan list: satu baris per foto dengan gambar kecil, nama, tanggal, status, dan tombol aksi.
export default function FotoList({ visible, onSet }: { visible: typeof GALLERY; onSet: (id: number, status: string) => void }) {
  return (
    <ul className="mt-5 space-y-3">
      {visible.map((p) => (
        <li key={p.id} className="flex items-center gap-4 rounded-3xl bg-white p-3 pr-5 animate-fade-up">
          <div className="relative h-16 w-28 shrink-0 overflow-hidden rounded-xl">
            <Image src={p.src} alt={`Foto dari ${p.owner}`} fill sizes="112px" className="object-cover" style={{ objectPosition: p.pos }} />
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-[15px] font-semibold text-ink">{p.owner}</p>
            <p className="text-[13px] text-abu">{formatDate(p.date)}</p>
          </div>
          <AiBadge className="hidden bg-leaf/12! sm:inline-flex" />
          <StatusPill status={p.status} />
          <AksiFoto photo={p} onSet={onSet} />
        </li>
      ))}
    </ul>
  );
}
