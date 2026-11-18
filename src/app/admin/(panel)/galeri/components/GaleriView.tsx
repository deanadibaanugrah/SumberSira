"use client";

import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";

import { AdminHeader } from "@/components/admin/ui";
import type { AdminGalleryPhoto } from "@/lib/auth/dal";

import { setStatusGaleri } from "../actions";
import FotoGrid from "./FotoGrid";
import FotoList from "./FotoList";
import StatGaleri from "./StatGaleri";
import ToolbarGaleri from "./ToolbarGaleri";

// Admin 5/7: Galeri & Konten. Moderasi foto kiriman pengunjung: setujui, tolak, atau hapus.
// Daftar berasal dari server (GET /admin/gallery); setiap tindakan memanggil Server Action lalu memuat ulang.
export default function GaleriView({ photos, error }: { photos: AdminGalleryPhoto[]; error: string | null }) {
  // Filter status, urutan, dan mode tampilan (grid atau list).
  const [filter, setFilter] = useState("Semua");
  const [sort, setSort] = useState("Terbaru");
  const [view, setView] = useState("grid");
  // Foto yang sedang diproses dan pesan galat tindakan terakhir.
  const [busyId, setBusyId] = useState<string | null>(null);
  const [pesan, setPesan] = useState<string | null>(null);
  const router = useRouter();

  // Foto yang tampil: disaring sesuai filter lalu diurutkan menurut waktu kirim.
  const visible = useMemo(() => {
    const status = filter === "Baru" ? "pending" : filter === "Ditampilkan" ? "approved" : filter === "Ditolak" ? "rejected" : null;
    const list = status ? photos.filter((p) => p.status === status) : photos;
    return [...list].sort((a, b) => {
      const urut = (a.createdAt ?? "").localeCompare(b.createdAt ?? "");
      return sort === "Terbaru" ? -urut : urut;
    });
  }, [photos, filter, sort]);

  const pesanGalat = (kode: string) => {
    if (kode === "UNAUTHORIZED") return "Sesi berakhir. Silakan login lagi.";
    if (kode === "FORBIDDEN") return "Hanya admin yang boleh mengubah status foto.";
    if (kode === "NOT_FOUND") return "Foto sudah tidak ada.";
    return "Status foto belum bisa diubah. Coba lagi.";
  };

  // Setujui atau tolak satu foto (PATCH /admin/gallery/:id).
  const ubahStatus = async (id: string, status: "approved" | "rejected") => {
    if (busyId) return;
    setBusyId(id);
    const hasil = await setStatusGaleri(id, status);
    setBusyId(null);
    if ("error" in hasil) {
      setPesan(pesanGalat(hasil.error));
      return;
    }
    setPesan(null);
    router.refresh();
  };

  const pesanMuat =
    error === "BACKEND_UNREACHABLE"
      ? "Tidak bisa terhubung ke server. Pastikan backend menyala, lalu muat ulang halaman."
      : "Foto belum bisa dimuat. Coba muat ulang halaman.";

  return (
    <>
      <AdminHeader title="Galeri & Konten" subtitle="Moderasi foto kiriman pengunjung" />

      <StatGaleri photos={photos} />

      {error && <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">{pesanMuat}</p>}
      {pesan && <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">{pesan}</p>}

      <ToolbarGaleri filter={filter} onFilter={setFilter} sort={sort} onSort={setSort} view={view} onView={setView} />

      {/* Tampilan grid (kartu foto) atau list (baris foto), sesuai tombol yang dipilih */}
      {view === "grid" ? (
        <FotoGrid visible={visible} busyId={busyId} onSet={ubahStatus} />
      ) : (
        <FotoList visible={visible} busyId={busyId} onSet={ubahStatus} />
      )}
      {!error && visible.length === 0 && <p className="mt-6 text-center text-sm text-abu">Tidak ada foto di kategori ini.</p>}
    </>
  );
}
