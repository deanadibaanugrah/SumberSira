import { Sparkles } from "lucide-react";

import ProgressBar from "@/components/charts/ProgressBar";
import { Card, CardTitle } from "@/components/admin/ui";
import { COMPLAINT_TAGS, COMPLAINT_TIP } from "@/data/dummy";

// Warna batang keluhan: makin banyak keluhan makin pekat.
const COMPLAINT_FILL = ["bg-coral", "bg-coral/70", "bg-coral/50"];

// Topik keluhan teratas dalam bentuk batang.
export default function KeluhanTeratas() {
  // Keluhan terbanyak dipakai sebagai panjang 100% batang.
  const maxComplaint = Math.max(...COMPLAINT_TAGS.map((t) => t.count));
  return (
    <Card className="flex flex-col">
      <CardTitle sub="Dirangkum AI dari ulasan pengunjung">Topik Keluhan Teratas</CardTitle>
      <ul className="mt-5 space-y-4">
        {COMPLAINT_TAGS.map((t, i) => (
          <li key={t.label}>
            <div className="flex items-center justify-between text-[15px] text-ink">
              <span className="font-medium">{t.label}</span>
              <span className="font-mono text-sm text-ink">{t.count} ulasan</span>
            </div>
            <div className="mt-2.5">
              <ProgressBar value={Math.round((t.count / maxComplaint) * 100)} fillClass={COMPLAINT_FILL[i] ?? "bg-coral/50"}
                           trackClass="bg-paper" height="h-3" delay={i * 150} />
            </div>
          </li>
        ))}
      </ul>
      <p className="mt-auto flex items-center gap-2.5 rounded-full bg-leaf/12 px-4 py-2.5 text-sm text-ink max-xl:mt-6">
        <Sparkles size={16} className="shrink-0 text-forest" aria-hidden="true" /> {COMPLAINT_TIP}
      </p>
    </Card>
  );
}
