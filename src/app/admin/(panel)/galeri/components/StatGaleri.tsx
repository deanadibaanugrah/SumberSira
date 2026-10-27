import { Check, Clock, Image as ImageIcon } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { GALLERY, GALLERY_TOTALS } from "@/data/dummy";

// Kartu ringkasan jumlah foto.
export default function StatGaleri({ photos }: { photos: typeof GALLERY }) {
  // Angka desain dipakai sebagai dasar; perubahan moderasi di halaman ini ikut menggeser angkanya.
  // Selisih jumlah status dibanding data awal untuk memperbarui angka di kartu ringkasan.
  const delta = (status) => photos.filter((p) => p.status === status).length - GALLERY.filter((p) => p.status === status).length;

  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-3">
      <StatCard icon={ImageIcon} solid value={GALLERY_TOTALS.masuk} label="Foto masuk" />
      <StatCard icon={Clock} value={GALLERY_TOTALS.menunggu + delta("Baru")} label="Menunggu review" />
      <StatCard icon={Check} value={GALLERY_TOTALS.tampil + delta("Ditampilkan")} label="Ditampilkan di aplikasi" />
    </div>
  );
}
