import { Download } from "lucide-react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import { requirePermission } from "@/lib/auth/dal";

import CrowdForecast from "./components/CrowdForecast";
import KeluhanTeratas from "./components/KeluhanTeratas";
import RingkasanAi from "./components/RingkasanAi";
import SentimenUlasan from "./components/SentimenUlasan";
import UlasanTerbaru from "./components/UlasanTerbaru";

// Admin 4/7: AI Insight. Prediksi keramaian (area beranimasi), ringkasan AI, sentimen (donat), keluhan (batang), ulasan terbaru.
// Tiap bagian ada di folder components/, halaman ini hanya menyusun tata letaknya.
export default async function InsightPage() {
  // Hanya admin (izin "insight"); petugas loket mendapat halaman 403.
  await requirePermission("insight");

  return (
    <>
      <AdminHeader title="AI Insight" subtitle="Prediksi keramaian dan ringkasan ulasan otomatis"
                   action={<PrimaryButton icon={Download}>Unduh Laporan</PrimaryButton>} />

      {/* Baris 1: grafik prediksi keramaian di kiri, ringkasan AI dan sentimen di kanan */}
      <div className="mt-6 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <CrowdForecast />

        <div className="grid gap-5">
          <RingkasanAi />
          <SentimenUlasan />
        </div>

        {/* Baris 2: topik keluhan teratas dan ulasan terbaru */}
        <KeluhanTeratas />
        <UlasanTerbaru />
      </div>
    </>
  );
}
