import { Star } from "lucide-react";

import ProgressBar from "@/components/charts/ProgressBar";
import { Card, CardTitle } from "@/components/admin/ui";
import type { AdminInsight } from "@/models/admin";

// Persentase satu bintang dari seluruh ulasan.
const pct = (n: number, total: number) => (total === 0 ? 0 : Math.round((n / total) * 100));

// Sebaran bintang 1-5 dari backend. Bintang 5 di atas.
export default function SebaranRating({ data }: { data: AdminInsight }) {
  const total = data.reviewCount;
  const baris = [5, 4, 3, 2, 1] as const;

  return (
    <Card>
      <CardTitle sub={`${total} ulasan`}>Sebaran Rating</CardTitle>
      <ul className="mt-5 space-y-3">
        {baris.map((bintang, i) => {
          const jumlah = data.distribution[String(bintang) as "1" | "2" | "3" | "4" | "5"] ?? 0;
          return (
            <li key={bintang}>
              <div className="flex items-center justify-between text-sm text-ink">
                <span className="flex items-center gap-1.5">
                  <Star size={14} className="text-leaf" aria-hidden="true" /> {bintang}
                </span>
                <span className="font-mono tabular-nums">{jumlah}</span>
              </div>
              <div className="mt-1.5">
                <ProgressBar value={pct(jumlah, total)} fillClass="bg-leaf" trackClass="bg-paper" height="h-2.5" delay={i * 80} />
              </div>
            </li>
          );
        })}
      </ul>
      {total === 0 && <p className="mt-4 text-[13px] text-abu">Belum ada ulasan yang masuk.</p>}
    </Card>
  );
}
