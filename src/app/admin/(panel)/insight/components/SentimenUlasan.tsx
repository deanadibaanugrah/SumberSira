import DonutChart from "@/components/charts/DonutChart";
import { Card, CardTitle } from "@/components/admin/ui";
import { REVIEW_COUNT, SENTIMENT } from "@/data/dummy";

// Kartu sentimen ulasan dengan grafik donat.
export default function SentimenUlasan() {
  return (
    <Card>
      <CardTitle sub={`${REVIEW_COUNT.total} ulasan · ${REVIEW_COUNT.period}`}>Sentimen Ulasan</CardTitle>
      <div className="mt-4 flex items-center gap-6">
        <DonutChart segments={SENTIMENT} />
        <ul className="flex-1 space-y-3 text-sm text-ink">
          {SENTIMENT.map((x) => (
            <li key={x.label} className="flex items-center gap-2.5">
              <span className="size-2.5 rounded-full" style={{ background: x.color }} aria-hidden="true" />
              <span className="flex-1">{x.label}</span>
              <span>{x.value}%</span>
            </li>
          ))}
        </ul>
      </div>
    </Card>
  );
}
