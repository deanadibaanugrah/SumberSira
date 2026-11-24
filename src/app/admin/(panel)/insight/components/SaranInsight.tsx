import { Sparkles } from "lucide-react";

import { Card, CardTitle } from "@/components/admin/ui";
import type { AdminInsight } from "@/models/admin";

// Saran dari aturan backend (keramaian dan ulasan terbaru), maksimal lima kalimat.
export default function SaranInsight({ data }: { data: AdminInsight }) {
  return (
    <Card>
      <CardTitle sub="Dari keramaian saat ini dan ulasan terbaru">Saran</CardTitle>
      {data.suggestions.length > 0 ? (
        <ul className="mt-5 space-y-3">
          {data.suggestions.map((saran, i) => (
            <li key={`${i}-${saran}`} className="flex items-start gap-3 rounded-2xl bg-leaf/12 px-4 py-3 text-sm leading-snug text-forest">
              <Sparkles size={16} className="mt-0.5 shrink-0" aria-hidden="true" />
              <span>{saran}</span>
            </li>
          ))}
        </ul>
      ) : (
        <p className="mt-4 text-sm text-abu">Belum ada saran untuk saat ini.</p>
      )}
    </Card>
  );
}
