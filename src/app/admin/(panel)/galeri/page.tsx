import { requirePermission } from "@/lib/auth/dal";

import GaleriView from "./components/GaleriView";

// Halaman server: hanya peran yang punya izin "galeri" (admin). Petugas loket mendapat halaman 403.
export default async function GaleriPage() {
  await requirePermission("galeri");
  return <GaleriView />;
}
