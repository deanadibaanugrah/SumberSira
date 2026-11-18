import { Check, Clock, Image as ImageIcon } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import type { AdminGalleryPhoto } from "@/models/admin";

// Kartu ringkasan jumlah foto: semua foto masuk, yang menunggu review, dan yang tampil di aplikasi.
export default function StatGaleri({ photos }: { photos: AdminGalleryPhoto[] }) {
  const menunggu = photos.filter((p) => p.status === "pending").length;
  const tampil = photos.filter((p) => p.status === "approved").length;

  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-3">
      <StatCard icon={ImageIcon} solid value={photos.length} label="Foto masuk" />
      <StatCard icon={Clock} value={menunggu} label="Menunggu review" />
      <StatCard icon={Check} value={tampil} label="Ditampilkan di aplikasi" />
    </div>
  );
}
