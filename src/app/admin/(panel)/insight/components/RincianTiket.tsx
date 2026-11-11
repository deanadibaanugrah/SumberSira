import DonutChart from "@/components/charts/DonutChart";
import ProgressBar from "@/components/charts/ProgressBar";
import { Card, CardTitle } from "@/components/admin/ui";
import type { InsightData } from "@/lib/insight-store";

const pct = (n: number, total: number) => (total === 0 ? 0 : Math.round((n / total) * 100));

// Rincian tiket hari itu: cara bayar (donat), pilihan parkir (batang), dan asal tiket (aplikasi atau loket). Hitungan per tiket.
export default function RincianTiket({ data }: { data: InsightData | null }) {
  const s = data?.summary;
  const total = s?.sold ?? 0;
  const payment = [
    { label: "QRIS", value: pct(s?.payment.qris ?? 0, total), color: "#1b4332" },
    { label: "Tunai", value: pct(s?.payment.cash ?? 0, total), color: "rgba(64, 145, 108, 0.4)" },
  ];
  const parking = [
    ["Tanpa parkir", s?.parking.none ?? 0],
    ["Motor", s?.parking.motor ?? 0],
    ["Mobil", s?.parking.mobil ?? 0],
    ["Bus", s?.parking.bus ?? 0],
  ] as const;
  return (
    <Card>
      <CardTitle sub={`${total} tiket`}>Rincian Tiket</CardTitle>
      <div className="mt-4 flex items-center gap-6">
        <DonutChart segments={total === 0 ? [{ label: "Kosong", value: 1, color: "rgba(23, 35, 33, 0.08)" }] : payment} />
        <ul className="flex-1 space-y-3 text-sm text-ink">
          {payment.map((x) => (
            <li key={x.label} className="flex items-center gap-2.5">
              <span className="size-2.5 rounded-full" style={{ background: x.color }} aria-hidden="true" />
              <span className="flex-1">{x.label}</span>
              <span className="tabular-nums">{total === 0 ? "-" : `${x.value}%`}</span>
            </li>
          ))}
        </ul>
      </div>
      <ul className="mt-5 space-y-3">
        {parking.map(([label, n], i) => (
          <li key={label}>
            <div className="flex items-center justify-between text-sm text-ink"><span>{label}</span><span className="font-mono">{n}</span></div>
            <div className="mt-1.5"><ProgressBar value={pct(n, total)} fillClass="bg-leaf" trackClass="bg-paper" height="h-2.5" delay={i * 100} /></div>
          </li>
        ))}
      </ul>
      <p className="mt-4 text-[13px] text-abu">Dari aplikasi {s?.source.app ?? 0} tiket · dari loket {s?.source.loket ?? 0} tiket</p>
    </Card>
  );
}
