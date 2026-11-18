import { getGalleryForAdmin, requirePermission } from "@/repositories/admin-repository";

import GaleriView from "./components/GaleriView";

// Halaman server: hanya peran yang punya izin "galeri" (admin). Petugas loket mendapat halaman 403.
// Daftar foto diambil dari backend agar status moderasi selalu sama dengan yang dilihat pengunjung.
export default async function GaleriPage() {
  await requirePermission("galeri");
  const { items, error } = await getGalleryForAdmin();
  return <GaleriView photos={items} error={error} />;
}
