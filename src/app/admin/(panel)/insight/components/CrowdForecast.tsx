import AreaChart from "@/components/charts/AreaChart";
import { Card, CardTitle } from "@/components/admin/ui";
import { CROWD_FORECAST, FORECAST_SUMMARY } from "@/data/dummy";

// Grafik area prediksi keramaian per jam untuk besok.
export default function CrowdForecast() {
  // Ubah data prediksi ke bentuk yang dibaca grafik area.
  const forecast = CROWD_FORECAST.map((d) => ({ label: d.hour, value: d.value }));
  const s = FORECAST_SUMMARY;
  return (
    <Card>
      <CardTitle sub={`Prediksi keramaian per jam untuk besok, ${s.day}`}
                 right={<span className="flex h-8 items-center gap-2 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest"><span className="size-2 rounded-full bg-leaf" /> Jam ramai {s.busyRange}</span>}>
        AI Crowd Forecast
      </CardTitle>
      <div className="mt-2">
        {/* Pita jam ramai dari pertengahan 09-10 sampai pertengahan 14-15, sama seperti di desain. */}
        <AreaChart data={forecast} band={[1.5, 6.5]} tooltip={(d) => `${d.value}% · ${d.label}.00`} />
      </div>
    </Card>
  );
}
