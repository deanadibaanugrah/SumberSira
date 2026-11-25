import { getReviewsForAdmin, requirePermission } from "@/repositories/admin-repository";

import UlasanView from "./components/UlasanView";

// Satu halaman berisi 10 ulasan; nomor halaman disimpan di URL (?page=2) agar data diambil per halaman.
const PER_HALAMAN = 10;

export default async function UlasanPage({
  searchParams,
}: {
  searchParams: Promise<{ page?: string }>;
}) {
  // Hanya admin (izin "ulasan"); petugas mendapat halaman 403.
  await requirePermission("ulasan");

  const sp = await searchParams;
  const nomor = Array.isArray(sp.page) ? sp.page[0] : sp.page;
  const page = Math.max(1, Number(nomor) || 1);

  const { items, total, average, error } = await getReviewsForAdmin(page, PER_HALAMAN);

  return <UlasanView items={items} total={total} average={average} page={page} limit={PER_HALAMAN} error={error} />;
}
