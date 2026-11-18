import { Clock, MessageCircle } from "lucide-react";

import { StatCard } from "@/components/admin/ui";

// Kartu ringkasan FAQ. Angka "dijawab otomatis" tidak ditampilkan karena backend tidak menyediakannya.
export default function StatFaq({ faqAktif, pendingCount }: { faqAktif: number; pendingCount: number }) {
  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-2">
      <StatCard icon={MessageCircle} solid value={faqAktif} label="FAQ aktif" />
      <StatCard icon={Clock} value={pendingCount} label="Belum terjawab" />
    </div>
  );
}
