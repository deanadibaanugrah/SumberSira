import { getGalleryForAdmin, requirePermission } from "@/repositories/admin-repository";

import GaleriView from "./components/GaleriView";

// Jumlah foto per halaman. Cukup untuk mengisi grid tanpa membuat browser berat.
const PER_HALAMAN = 12;

type StatusFoto = "pending" | "approved" | "rejected";

// Halaman server: hanya peran yang punya izin "galeri" (admin). Petugas loket mendapat halaman 403.
// Daftar foto diambil dari backend agar status moderasi selalu sama dengan yang dilihat pengunjung.
// Halaman dan filter status disimpan di URL (?page=&status=) supaya data diambil per halaman.
export default async function GaleriPage({
  searchParams,
}: {
  searchParams: Promise<{ page?: string; status?: string }>;
}) {
  await requirePermission("galeri");

  const sp = await searchParams;
  const nomor = Array.isArray(sp.page) ? sp.page[0] : sp.page;
  const page = Math.max(1, Number(nomor) || 1);

  const nilaiStatus = Array.isArray(sp.status) ? sp.status[0] : sp.status;
  const status: StatusFoto | undefined =
    nilaiStatus === "pending" || nilaiStatus === "approved" || nilaiStatus === "rejected"
      ? nilaiStatus
      : undefined;

  const data = await getGalleryForAdmin(page, status, PER_HALAMAN);

  return (
    <GaleriView
      photos={data.items}
      total={data.total}
      limit={data.limit}
      counts={data.counts}
      page={data.page}
      status={status}
      error={data.error}
    />
  );
}
