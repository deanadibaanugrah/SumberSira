import { StatusPill } from "@/components/admin/ui";
import type { AdminGalleryPhoto } from "@/models/admin";

import AiBadge from "./AiBadge";
import AksiFoto from "./AksiFoto";
import { LABEL_STATUS } from "./status";
import { formatDate } from "./tanggal";

// Tampilan grid: kartu foto dengan label AI, judul, pengirim, tanggal, status, dan tombol aksi.
export default function FotoGrid({
  visible,
  busyId,
  onSet,
}: {
  visible: AdminGalleryPhoto[];
  busyId: string | null;
  onSet: (id: string, status: "approved" | "rejected") => void;
}) {
  return (
    <div className="mt-5 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      {visible.map((p) => (
        <article key={p.id} className="rounded-3xl bg-white p-3 pb-4 animate-fade-up">
          <div className="relative aspect-[245/150] overflow-hidden rounded-2xl">
            {/* URL foto berasal dari backend (host berubah-ubah), jadi memakai img biasa, bukan next/image. */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={p.url} alt={`Foto ${p.title} dari ${p.owner}`} loading="lazy" className="absolute inset-0 size-full object-cover" />
            {p.ai && <AiBadge className="absolute left-2.5 top-2.5" />}
          </div>
          <div className="px-1">
            <p className="mt-3 truncate text-[15px] font-semibold text-ink">{p.title}</p>
            <p className="mt-0.5 text-[13px] text-abu">{p.owner} · {formatDate(p.createdAt)}</p>
            {p.caption?.trim() ? (
              <p className="mt-1 line-clamp-2 text-[13px] leading-snug text-abu">{p.caption}</p>
            ) : null}
            <div className="mt-4 flex items-center justify-between gap-2">
              <StatusPill status={LABEL_STATUS[p.status]} />
              <AksiFoto photo={p} busy={busyId === p.id} onSet={onSet} />
            </div>
          </div>
        </article>
      ))}
    </div>
  );
}
