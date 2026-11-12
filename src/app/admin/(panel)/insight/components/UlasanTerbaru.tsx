import { Star } from "lucide-react";

import { Avatar, Card, CardTitle } from "@/components/admin/ui";
import { REVIEWS } from "@/data/dummy";

// Ulasan terbaru pengunjung beserta bintangnya.
export default function UlasanTerbaru() {
  return (
    <Card>
      <CardTitle>Ulasan Terbaru</CardTitle>
      <ul className="mt-4 space-y-4">
        {REVIEWS.map((r) => (
          <li key={r.id} className="flex gap-3">
            <Avatar name={r.name} size={36} />
            <div>
              <p className="text-sm font-semibold text-ink">{r.name}</p>
              <p className="mt-1 flex gap-0.5" aria-label={`${r.stars} dari 5 bintang`}>
                {[1, 2, 3, 4, 5].map((n) => (
                  <Star key={n} size={13} className={n <= r.stars ? "fill-leaf text-leaf" : "text-ink/25"} aria-hidden="true" />
                ))}
              </p>
              <p className="mt-1.5 text-[13.5px] leading-snug text-ink">{r.text}</p>
            </div>
          </li>
        ))}
      </ul>
    </Card>
  );
}
