"use client";

import { Check, ChevronDown, Clock, Image as ImageIcon, LayoutGrid, List, Sparkles, Upload, X } from "lucide-react";
import Image from "next/image";
import { useMemo, useState } from "react";

import { AdminHeader, FilterPills, IconButton, PrimaryButton, StatCard, StatusPill } from "@/components/admin/ui";
import { GALLERY, GALLERY_TOTALS } from "@/data/dummy";

// Admin 4/6: Galeri & Konten. Moderasi foto AI-enhanced kiriman pengunjung (tampilkan/tolak).
const FILTERS = ["Semua", "Baru", "Ditampilkan", "Ditolak"];
const DATE = new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "short", year: "numeric", timeZone: "UTC" });
const formatDate = (iso) => DATE.format(new Date(`${iso}T00:00:00Z`)).replace(".", "");

function Actions({ photo, onSet }) {
  return (
    <div className="flex gap-2">
      <IconButton tone="gray" label={`Tampilkan foto ${photo.owner}`} onClick={() => onSet(photo.id, "Ditampilkan")}><Check size={17} /></IconButton>
      <IconButton tone="coral" label={`Tolak foto ${photo.owner}`} onClick={() => onSet(photo.id, "Ditolak")}><X size={17} /></IconButton>
    </div>
  );
}

function AiBadge({ className = "" }) {
  return (
    <span className={`inline-flex h-[26px] items-center gap-1.5 rounded-full bg-white/90 px-2.5 text-xs font-semibold text-forest ${className}`}>
      <Sparkles size={13} aria-hidden="true" /> AI Enhanced
    </span>
  );
}

export default function GaleriPage() {
  const [photos, setPhotos] = useState(GALLERY);
  const [filter, setFilter] = useState("Semua");
  const [sort, setSort] = useState("Terbaru");
  const [view, setView] = useState("grid");

  const visible = useMemo(() => {
    const list = photos.filter((p) => filter === "Semua" || p.status === filter);
    return [...list].sort((a, b) => (sort === "Terbaru" ? b.date.localeCompare(a.date) || a.id - b.id : a.date.localeCompare(b.date) || a.id - b.id));
  }, [photos, filter, sort]);

  // Angka desain dipakai sebagai dasar; perubahan moderasi di halaman ini ikut menggeser angkanya.
  const delta = (status) => photos.filter((p) => p.status === status).length - GALLERY.filter((p) => p.status === status).length;
  const setStatus = (id, status) => setPhotos((all) => all.map((p) => (p.id === id ? { ...p, status } : p)));

  return (
    <>
      <AdminHeader title="Galeri & Konten" subtitle="Moderasi foto AI-enhanced kiriman pengunjung"
                   action={<PrimaryButton icon={Upload}>Unggah Foto</PrimaryButton>} />

      <div className="mt-6 grid gap-5 sm:grid-cols-3">
        <StatCard icon={ImageIcon} solid value={GALLERY_TOTALS.masuk} label="Foto masuk" />
        <StatCard icon={Clock} value={GALLERY_TOTALS.menunggu + delta("Baru")} label="Menunggu review" />
        <StatCard icon={Check} value={GALLERY_TOTALS.tampil + delta("Ditampilkan")} label="Ditampilkan di aplikasi" />
      </div>

      <div className="mt-6 flex flex-wrap items-center justify-between gap-4">
        <FilterPills options={FILTERS} value={filter} onChange={setFilter} label="Filter status foto" />
        <div className="flex items-center gap-4">
          <label className="relative">
            <span className="sr-only">Urutkan</span>
            <ChevronDown size={16} className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-ink" aria-hidden="true" />
            <select value={sort} onChange={(e) => setSort(e.target.value)}
                    className="h-10 appearance-none rounded-full border border-ink/10 bg-white pl-10 pr-5 text-sm text-ink outline-none focus:ring-2 focus:ring-leaf/30">
              <option>Terbaru</option>
              <option>Terlama</option>
            </select>
          </label>
          <div className="flex rounded-full bg-white p-1" role="group" aria-label="Tampilan">
            {[["grid", LayoutGrid, "Tampilan grid"], ["list", List, "Tampilan daftar"]].map(([key, Icon, label]) => (
              <button key={key} type="button" aria-label={label} aria-pressed={view === key} onClick={() => setView(key)}
                      className={`grid size-9 place-items-center rounded-full transition ${view === key ? "bg-forest text-white" : "text-ink hover:bg-paper"}`}>
                <Icon size={18} />
              </button>
            ))}
          </div>
        </div>
      </div>

      {view === "grid" ? (
        <div className="mt-5 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
          {visible.map((p) => (
            <article key={p.id} className="rounded-3xl bg-white p-3 pb-4 animate-fade-up">
              <div className="relative aspect-[245/150] overflow-hidden rounded-2xl">
                <Image src={p.src} alt={`Foto dari ${p.owner}`} fill sizes="(min-width:1280px) 25vw, 50vw" className="object-cover" style={{ objectPosition: p.pos }} />
                <AiBadge className="absolute left-2.5 top-2.5" />
              </div>
              <div className="px-1">
                <p className="mt-3 text-[15px] font-semibold text-ink">{p.owner}</p>
                <p className="mt-0.5 text-[13px] text-ink/60">{formatDate(p.date)}</p>
                <div className="mt-4 flex items-center justify-between">
                  <StatusPill status={p.status} />
                  <Actions photo={p} onSet={setStatus} />
                </div>
              </div>
            </article>
          ))}
        </div>
      ) : (
        <ul className="mt-5 space-y-3">
          {visible.map((p) => (
            <li key={p.id} className="flex items-center gap-4 rounded-3xl bg-white p-3 pr-5 animate-fade-up">
              <div className="relative h-16 w-28 shrink-0 overflow-hidden rounded-xl">
                <Image src={p.src} alt={`Foto dari ${p.owner}`} fill sizes="112px" className="object-cover" style={{ objectPosition: p.pos }} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[15px] font-semibold text-ink">{p.owner}</p>
                <p className="text-[13px] text-ink/60">{formatDate(p.date)}</p>
              </div>
              <AiBadge className="hidden bg-leaf/12! sm:inline-flex" />
              <StatusPill status={p.status} />
              <Actions photo={p} onSet={setStatus} />
            </li>
          ))}
        </ul>
      )}
      {visible.length === 0 && <p className="mt-6 text-center text-sm text-ink/60">Tidak ada foto di kategori ini.</p>}
    </>
  );
}
