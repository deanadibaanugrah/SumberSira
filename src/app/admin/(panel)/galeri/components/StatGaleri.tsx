import { Check, Clock, Image as ImageIcon } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import type { AdminGalleryCounts } from "@/models/admin";

// Kartu ringkasan jumlah foto: semua foto masuk, yang menunggu review, dan yang tampil di aplikasi.
// Angka berasal dari rekap backend (seluruh data), bukan hanya halaman yang sedang dibuka.
export default function StatGaleri({ counts }: { counts: AdminGalleryCounts }) {
  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-3">
      <StatCard icon={ImageIcon} solid value={counts.all} label="Foto masuk" />
      <StatCard icon={Clock} value={counts.pending} label="Menunggu review" />
      <StatCard icon={Check} value={counts.approved} label="Ditampilkan di aplikasi" />
    </div>
  );
}
