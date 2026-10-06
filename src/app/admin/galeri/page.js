"use client";

import { Check, X } from "lucide-react";
import Image from "next/image";
import { useMemo, useState } from "react";

import { AdminHeader, Card, FilterPills, IconButton, StatCard } from "@/components/admin/ui";
import { GALLERY, GALLERY_TOTALS } from "@/data/dummy";

// Admin 4/6: Galeri & Konten — moderasi foto pengunjung (tampilkan/tolak).
const FILTERS = ["Semua", "Menunggu Review", "Ditampilkan", "Ditolak"];
const BADGE = {
  Baru: "bg-white/75 text-forest",
  Ditampilkan: "bg-forest text-white",
  Ditolak: "bg-coral text-white",
};

export default function GaleriPage() {
  const [photos, setPhotos] = useState(GALLERY);
  const [filter, setFilter] = useState("Semua");

  const visible = useMemo(() => photos.filter((p) =>
    filter === "Semua" || (filter === "Menunggu Review" ? p.status === "Baru" : p.status === filter)), [photos, filter]);

  // Angka desain dipakai sebagai dasar; perubahan moderasi di halaman ini ikut menggeser angkanya.
  const delta = (status) => photos.filter((p) => p.status === status).length - GALLERY.filter((p) => p.status === status).length;
  const setStatus = (id, status) => setPhotos((all) => all.map((p) => (p.id === id ? { ...p, status } : p)));

  return (
    <>
      <AdminHeader title="Galeri & Konten" />
      <main className="p-6 lg:p-8">
        <div className="grid gap-5 sm:grid-cols-3">
          <StatCard label="Total Foto Masuk" value={GALLERY_TOTALS.masuk} />
          <StatCard label="Menunggu Review" value={GALLERY_TOTALS.menunggu + delta("Baru")} dot="forest" />
          <StatCard label="Tampil di Galeri" value={GALLERY_TOTALS.tampil + delta("Ditampilkan")} />
        </div>

        <div className="mt-[30px]">
          <FilterPills options={FILTERS} value={filter} onChange={setFilter} />
        </div>

        <div className="mt-[29px] grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
          {visible.map((p) => (
            <Card key={p.id} className="px-2.5! pb-4! pt-[11px]! animate-fade-up">
              <div className="relative aspect-[254/130] overflow-hidden rounded-lg">
                <Image src={p.src} alt={`Foto dari ${p.owner}`} fill sizes="(min-width:1280px) 25vw, 50vw" className="object-cover" />
                <span className={`absolute right-[19px] top-[9px] flex h-[18px] items-center rounded-full px-2.5 text-[9px] font-semibold ${BADGE[p.status]}`}>{p.status}</span>
              </div>
              <p className="mt-2.5 text-[11px] font-semibold text-ink">{p.owner}</p>
              <div className="mt-2 flex gap-1.5">
                <IconButton label="Tampilkan di galeri" onClick={() => setStatus(p.id, "Ditampilkan")}><Check size={15} strokeWidth={1.8} /></IconButton>
                <IconButton label="Tolak foto" tone="coral" onClick={() => setStatus(p.id, "Ditolak")}><X size={15} strokeWidth={1.8} /></IconButton>
              </div>
            </Card>
          ))}
        </div>
        {visible.length === 0 && <p className="mt-6 text-center text-[11px] text-ink/60">Tidak ada foto di kategori ini.</p>}
      </main>
    </>
  );
}
