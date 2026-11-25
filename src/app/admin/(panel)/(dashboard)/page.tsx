import PolaKeramaian from "@/components/admin/PolaKeramaian";
import { AdminHeader } from "@/components/admin/ui";
import { requirePermission } from "@/repositories/admin-repository";

import BookingMasuk from "./components/BookingMasuk";
import LiveCrowdMonitor from "./components/LiveCrowdMonitor";
import PendapatanMingguan from "./components/PendapatanMingguan";
import RingkasanHariIni from "./components/RingkasanHariIni";
import StatRingkasan from "./components/StatRingkasan";
import TiketHariIni from "./components/TiketHariIni";
import Today from "./components/Today";
import WahanaPopuler from "./components/WahanaPopuler";

// Admin 1/7: Dashboard Overview. Kartu ringkasan, grafik keramaian beranimasi, ringkasan hari ini, booking masuk,
// lalu di bawah: heatmap keramaian seminggu, tiket online hari ini (live), wahana terpopuler, dan pendapatan 7 hari.
// Tiap bagian ada di folder components/, halaman ini hanya menyusun barisnya.
// Folder (dashboard) adalah route group, jadi alamatnya tetap /admin.
export default async function DashboardPage() {
  // Halaman server: cek login dan izin lewat DAL sebelum data dashboard ditampilkan.
  const admin = await requirePermission("dashboard");
  return (
    <>
      <AdminHeader title={`Halo, ${admin.name}!`}
                   subtitle={<><Today /> · ringkasan operasional Sumber Sira hari ini</>} />

      <div className="mt-6 space-y-5">
        {/* Baris 1: empat kartu ringkasan */}
        <StatRingkasan />

        {/* Baris 2: grafik pengunjung per jam dan kartu ringkasan hari ini */}
        <div className="grid grid-cols-1 gap-5 xl:grid-cols-[736fr_380fr]">
          <LiveCrowdMonitor />
          <RingkasanHariIni />
        </div>

        {/* Baris 3: tabel 3 booking sewa terbaru */}
        <BookingMasuk />

        {/* Baris 4: heatmap keramaian seminggu dan kartu tiket online hari ini */}
        <div className="grid grid-cols-1 gap-5 xl:grid-cols-[736fr_380fr]">
          <PolaKeramaian />
          <TiketHariIni />
        </div>

        {/* Baris 5: wahana terpopuler dan pendapatan 7 hari */}
        <div className="grid grid-cols-1 gap-5 xl:grid-cols-2">
          <WahanaPopuler />
          <PendapatanMingguan />
        </div>
      </div>
    </>
  );
}
