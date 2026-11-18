import { requirePermission } from "@/repositories/admin-repository";

import TiketView from "./components/TiketView";

// Halaman server: cek login dan izin "tiket" dulu (DAL), baru tampilkan Tiket & Check-in.
export default async function TiketPage() {
  await requirePermission("tiket");
  return <TiketView />;
}
