import { AdminHeader } from "@/components/admin/ui";
import type { AdminInsight } from "@/models/admin";

import SaranInsight from "./SaranInsight";
import SebaranRating from "./SebaranRating";
import StatInsight from "./StatInsight";

// Halaman AI Insight: rating dan sebaran ulasan, keramaian saat ini, jam terpadat, dan saran dari aturan backend.
// Bagian lama yang datanya tidak disediakan backend (grafik per 30 menit, rincian tiket, pola 7 hari,
// unduh CSV) tidak ditampilkan.
export default function InsightView({ data, error }: { data: AdminInsight | null; error: string | null }) {
  return (
    <>
      <AdminHeader title="Insight Keramaian" subtitle="Analisis otomatis dari ulasan dan keramaian" />

      {error && (
        <p role="alert" className="mt-6 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">
          Data insight belum bisa dimuat. Pastikan backend menyala, lalu muat ulang halaman.
        </p>
      )}

      {data && (
        <>
          <StatInsight data={data} />
          <div className="mt-5 grid grid-cols-1 gap-5 xl:grid-cols-[736fr_380fr]">
            <SebaranRating data={data} />
            <SaranInsight data={data} />
          </div>
        </>
      )}
    </>
  );
}
