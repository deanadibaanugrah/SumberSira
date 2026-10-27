"use client";

import { Upload } from "lucide-react";
import { useMemo, useState } from "react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import { GALLERY } from "@/data/dummy";

import FotoGrid from "./FotoGrid";
import FotoList from "./FotoList";
import StatGaleri from "./StatGaleri";
import ToolbarGaleri from "./ToolbarGaleri";

// Admin 5/7: Galeri & Konten. Moderasi foto AI-enhanced kiriman pengunjung (tampilkan/tolak).
// File ini memegang data dan pilihan pengguna, lalu menyusun bagian-bagiannya (StatGaleri, ToolbarGaleri, FotoGrid, FotoList).
export default function GaleriView() {
  // Data foto, filter, urutan (terbaru atau terlama), dan mode tampilan (grid atau list).
  const [photos, setPhotos] = useState(GALLERY);
  const [filter, setFilter] = useState("Semua");
  const [sort, setSort] = useState("Terbaru");
  const [view, setView] = useState("grid");

  // Foto yang tampil: disaring sesuai filter lalu diurutkan sesuai pilihan.
  const visible = useMemo(() => {
    const list = photos.filter((p) => filter === "Semua" || p.status === filter);
    return [...list].sort((a, b) => (sort === "Terbaru" ? b.date.localeCompare(a.date) || a.id - b.id : a.date.localeCompare(b.date) || a.id - b.id));
  }, [photos, filter, sort]);

  // Mengganti status satu foto (Ditampilkan atau Ditolak).
  const setStatus = (id, status) => setPhotos((all) => all.map((p) => (p.id === id ? { ...p, status } : p)));

  return (
    <>
      <AdminHeader title="Galeri & Konten" subtitle="Moderasi foto AI-enhanced kiriman pengunjung"
                   action={<PrimaryButton icon={Upload}>Unggah Foto</PrimaryButton>} />

      <StatGaleri photos={photos} />

      <ToolbarGaleri filter={filter} onFilter={setFilter} sort={sort} onSort={setSort} view={view} onView={setView} />

      {/* Tampilan grid (kartu foto) atau list (baris foto), sesuai tombol yang dipilih */}
      {view === "grid" ? <FotoGrid visible={visible} onSet={setStatus} /> : <FotoList visible={visible} onSet={setStatus} />}
      {visible.length === 0 && <p className="mt-6 text-center text-sm text-ink/60">Tidak ada foto di kategori ini.</p>}
    </>
  );
}
