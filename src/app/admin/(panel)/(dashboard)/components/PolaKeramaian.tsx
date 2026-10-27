import { Sparkles } from "lucide-react";

import Heatmap from "@/components/charts/Heatmap";
import { Card, CardTitle } from "@/components/admin/ui";
import { WEEKLY_CROWD } from "@/data/dummy";

// Heatmap keramaian seminggu beserta catatan dari AI.
export default function PolaKeramaian() {
  return (
    <Card>
      <CardTitle sub="Persentase kapasitas per jam, 7 hari terakhir (dari tiket yang discan)">Pola Keramaian Minggu Ini</CardTitle>
      <div className="mt-5">
        <Heatmap hours={WEEKLY_CROWD.hours} rows={WEEKLY_CROWD.days} />
      </div>
      <p className="mt-4 flex items-start gap-2.5 rounded-2xl bg-leaf/10 px-4 py-3 text-sm text-ink">
        <Sparkles size={16} className="mt-0.5 shrink-0 text-forest" aria-hidden="true" /> {WEEKLY_CROWD.insight}
      </p>
    </Card>
  );
}
