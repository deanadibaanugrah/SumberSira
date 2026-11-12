import { Clock, MessageCircle, Sparkles } from "lucide-react";

import { StatCard } from "@/components/admin/ui";
import { FAQ_AUTO_RATE } from "@/data/dummy";

// Kartu ringkasan FAQ.
export default function StatFaq({ faqCount, pendingCount }: { faqCount: number; pendingCount: number }) {
  return (
    <div className="mt-6 grid gap-5 sm:grid-cols-3">
      <StatCard icon={MessageCircle} solid value={faqCount} label="FAQ aktif" />
      <StatCard icon={Clock} value={pendingCount} label="Belum terjawab" />
      <StatCard icon={Sparkles} value={`${FAQ_AUTO_RATE}%`} label="Dijawab otomatis oleh AI" />
    </div>
  );
}
