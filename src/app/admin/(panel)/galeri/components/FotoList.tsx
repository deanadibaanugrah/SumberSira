import { StatusPill } from "@/components/admin/ui";
import type { AdminGalleryPhoto } from "@/models/admin";

import AiBadge from "./AiBadge";
import AksiFoto from "./AksiFoto";
import { LABEL_STATUS } from "./status";
import { formatDate } from "./tanggal";

// Tampilan list: satu baris per foto dengan gambar kecil, judul, pengirim, tanggal, status, dan tombol aksi.
export default function FotoList({
  visible,
  busyId,
  onSet,
}: {
  visible: AdminGalleryPhoto[];
  busyId: string | null;
  onSet: (id: string, status: "approved" | "rejected") => void;
}) {
  return (
    <ul className="mt-5 space-y-3">
      {visible.map((p) => (
        <li key={p.id} className="flex items-center gap-4 rounded-3xl bg-white p-3 pr-5 animate-fade-up">
          <div className="relative h-16 w-28 shrink-0 overflow-hidden rounded-xl">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={p.url} alt={`Foto ${p.title} dari ${p.owner}`} loading="lazy" className="absolute inset-0 size-full object-cover" />
          </div>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[15px] font-semibold text-ink">{p.title}</p>
            <p className="truncate text-[13px] text-abu">{p.owner} · {formatDate(p.createdAt)}</p>
            {p.caption?.trim() ? (
              <p className="mt-0.5 line-clamp-2 text-[13px] leading-snug text-abu">{p.caption}</p>
            ) : null}
          </div>
          {p.ai && <AiBadge className="hidden bg-leaf/12! sm:inline-flex" />}
          <StatusPill status={LABEL_STATUS[p.status]} />
          <AksiFoto photo={p} busy={busyId === p.id} onSet={onSet} />
        </li>
      ))}
    </ul>
  );
}
