import { Download } from "lucide-react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import { requirePermission } from "@/lib/auth/dal";

import BookingMasuk from "./components/BookingMasuk";
import InsightAi from "./components/InsightAi";
import LiveCrowdMonitor from "./components/LiveCrowdMonitor";
import PendapatanMingguan from "./components/PendapatanMingguan";
import PolaKeramaian from "./components/PolaKeramaian";
import StatRingkasan from "./components/StatRingkasan";
import TiketHariIni from "./components/TiketHariIni";
import Today from "./components/Today";
import WahanaPopuler from "./components/WahanaPopuler";

// Admin 1/7: Dashboard Overview. Kartu ringkasan, grafik keramaian beranimasi, Insight AI, booking masuk,
// lalu di bawah: heatmap keramaian seminggu, tiket online hari ini (live), wahana terpopuler, dan pendapatan 7 hari.
// Tiap bagian ada di folder components/, halaman ini hanya menyusun barisnya.
// Folder (dashboard) adalah route group, jadi alamatnya tetap /admin.
export default async function DashboardPage() {
  // Halaman server: cek login dan izin lewat DAL sebelum data dashboard ditampilkan.
  await requirePermission("dashboard");
  return (
    <>
      <AdminHeader title="Halo, Pak Yono!"
                   subtitle={<><Today /> · ringkasan operasional Sumber Sira hari ini</>}
                   action={<PrimaryButton icon={Download}>Unduh Laporan</PrimaryButton>} />

      <div className="mt-6 space-y-5">
        {/* Baris 1: empat kartu ringkasan */}
        <StatRingkasan />

        {/* Baris 2: grafik pengunjung per jam dan kartu Insight AI */}
        <div className="grid gap-5 xl:grid-cols-[736fr_380fr]">
          <LiveCrowdMonitor />
          <InsightAi />
        </div>

        {/* Baris 3: tabel 3 booking sewa terbaru */}
        <BookingMasuk />

        {/* Baris 4: heatmap keramaian seminggu dan kartu tiket online hari ini */}
        <div className="grid gap-5 xl:grid-cols-[736fr_380fr]">
          <PolaKeramaian />
          <TiketHariIni />
        </div>

        {/* Baris 5: wahana terpopuler dan pendapatan 7 hari */}
        <div className="grid gap-5 xl:grid-cols-2">
          <WahanaPopuler />
          <PendapatanMingguan />
        </div>
      </div>
    </>
  );
}
