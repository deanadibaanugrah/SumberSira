import { Clock, MessageCircle, Zap } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import type { ChatStats } from "@/lib/chat-store";

// Kartu ringkasan FAQ. Persen otomatis = pertanyaan "jawab cepat" 30 hari terakhir yang terjawab FAQ atau AI tanpa menunggu pengelola.
export default function StatFaq({ stats, faqCount, pendingCount }: { stats: ChatStats | null; faqCount: number; pendingCount: number }) {
  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-3">
      <StatCard icon={MessageCircle} solid value={faqCount} label="FAQ aktif" />
      <StatCard icon={Clock} value={pendingCount} label="Menunggu pengelola" />
      <StatCard icon={Zap} value={stats && stats.total > 0 ? `${stats.autoPercent}%` : "-"} label="Dijawab otomatis (30 hari)" />
    </div>
  );
}
