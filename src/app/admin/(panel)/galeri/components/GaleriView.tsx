"use client";

import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";

import Pager from "@/components/admin/Pager";
import { AdminHeader } from "@/components/admin/ui";
import type { AdminGalleryCounts, AdminGalleryPhoto } from "@/models/admin";

import { setStatusGaleri } from "../actions";
import FotoGrid from "./FotoGrid";
import FotoList from "./FotoList";
import StatGaleri from "./StatGaleri";
import ToolbarGaleri from "./ToolbarGaleri";

// Admin 5/7: Galeri & Konten. Moderasi foto kiriman pengunjung: setujui, tolak, atau hapus.
// Daftar berasal dari server (GET /admin/gallery) per halaman; filter status dan nomor halaman
// disimpan di URL, setiap tindakan memanggil Server Action lalu memuat ulang halaman yang sama.
export default function GaleriView({
  photos,
  total,
  limit,
  counts,
  page,
  status,
  error,
}: {
  photos: AdminGalleryPhoto[];
  total: number;
  limit: number;
  counts: AdminGalleryCounts;
  page: number;
  status?: "pending" | "approved" | "rejected";
  error: string | null;
}) {
  // Urutan, mode tampilan, dan pencarian tetap di sisi klien; filter status dan halaman lewat URL.
  const [sort, setSort] = useState("Terbaru");
  const [view, setView] = useState("grid");
  const [query, setQuery] = useState("");
  // Foto yang sedang diproses dan pesan galat tindakan terakhir.
  const [busyId, setBusyId] = useState<string | null>(null);
  const [pesan, setPesan] = useState<string | null>(null);
  const router = useRouter();

  const filter =
    status === "pending" ? "Baru" : status === "approved" ? "Ditampilkan" : status === "rejected" ? "Ditolak" : "Semua";

  // Foto yang tampil: dicari lalu diurutkan menurut waktu kirim (data sudah difilter server).
  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();
    const list = q
      ? photos.filter((p) => p.title.toLowerCase().includes(q) || p.owner.toLowerCase().includes(q) || (p.caption ?? "").toLowerCase().includes(q))
      : photos;
    return [...list].sort((a, b) => {
      const urut = (a.createdAt ?? "").localeCompare(b.createdAt ?? "");
      return sort === "Terbaru" ? -urut : urut;
    });
  }, [photos, sort, query]);

  // Ganti filter status: kembali ke halaman 1 supaya hasil selalu konsisten.
  const ubahFilter = (label: string) => {
    const next =
      label === "Baru" ? "pending" : label === "Ditampilkan" ? "approved" : label === "Ditolak" ? "rejected" : undefined;
    router.push(next ? `/admin/galeri?status=${next}` : "/admin/galeri");
  };

  const pesanGalat = (kode: string) => {
    if (kode === "UNAUTHORIZED") return "Sesi berakhir. Silakan login lagi.";
    if (kode === "FORBIDDEN") return "Hanya admin yang boleh mengubah status foto.";
    if (kode === "NOT_FOUND") return "Foto sudah tidak ada.";
    return "Status foto belum bisa diubah. Coba lagi.";
  };

  // Setujui atau tolak satu foto (PATCH /admin/gallery/:id).
  const ubahStatus = async (id: string, statusBaru: "approved" | "rejected") => {
    if (busyId) return;
    setBusyId(id);
    setPesan(null);
    try {
      const hasil = await setStatusGaleri(id, statusBaru);
      if ("error" in hasil) {
        setPesan(pesanGalat(hasil.error));
        return;
      }
      router.refresh();
    } catch {
      setPesan("Status foto belum bisa diubah. Periksa koneksi, lalu coba lagi.");
    } finally {
      setBusyId(null);
    }
  };

  const pesanMuat =
    error === "BACKEND_UNREACHABLE"
      ? "Tidak bisa terhubung ke server. Pastikan backend menyala, lalu muat ulang halaman."
      : "Foto belum bisa dimuat. Coba muat ulang halaman.";

  return (
    <>
      <AdminHeader
        title="Galeri & Konten"
        subtitle="Moderasi foto kiriman pengunjung"
        search={{ value: query, onChange: setQuery, placeholder: "Cari judul, pengirim, atau caption..." }}
      />

      <StatGaleri counts={counts} />

      {error && <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">{pesanMuat}</p>}
      {pesan && <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">{pesan}</p>}

      <ToolbarGaleri filter={filter} onFilter={ubahFilter} sort={sort} onSort={setSort} view={view} onView={setView} />

      {/* Tampilan grid (kartu foto) atau list (baris foto), sesuai tombol yang dipilih */}
      {view === "grid" ? (
        <FotoGrid visible={visible} busyId={busyId} onSet={ubahStatus} />
      ) : (
        <FotoList visible={visible} busyId={busyId} onSet={ubahStatus} />
      )}
      {!error && visible.length === 0 && <p className="mt-6 text-center text-sm text-abu">Tidak ada foto di kategori ini.</p>}

      <Pager page={page} total={total} limit={limit} basePath="/admin/galeri" params={{ status }} />
    </>
  );
}
