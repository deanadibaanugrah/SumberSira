// Grafik batang berbentuk pill dengan garis bantu dan label sumbu Y ("Live Crowd Monitor" di dashboard admin).
// Tiap batang tumbuh dari bawah secara berurutan (syarat dosen: animasi grafik), batang tertinggi diberi label.
// data: [{ label: "08.00", value: 40 }]  ·  highlight: (item, index) => true untuk batang Hijau Tua (jam ramai).
// Komponen grafik batang jumlah pengunjung per jam di dashboard admin.
type Bar = { label: string; value: number };
type BarChartProps = {
  data: Bar[]; ticks?: number[]; height?: number; highlight?: (item: Bar, index: number) => boolean;
  tooltip?: (item: Bar) => string | number; barClass?: string; highlightClass?: string;
};

export default function BarChart({
  data,
  ticks = [0, 40, 80, 120],
  height = 174,
  highlight = () => false,
  tooltip = (d) => d.value,
  barClass = "bg-leaf/35",
  highlightClass = "bg-forest",
}: BarChartProps) {
  // Nilai tertinggi sebagai skala 100%, dan batang tertinggi yang diberi label.
  const top = Math.max(...ticks, ...data.map((d) => d.value), 1);
  const peak = data.reduce((best, d) => (d.value > best.value ? d : best), data[0]);
  // Mengubah angka menjadi persen tinggi batang.
  const pct = (v) => `${(v / top) * 100}%`;
  const grid = { gridTemplateColumns: `repeat(${data.length}, minmax(0, 1fr))` };

  return (
    <div className="flex gap-3">
      {/* Label angka di sumbu kiri */}
      <div className="relative w-8 shrink-0 font-mono text-[11px] text-abu" style={{ height }} aria-hidden="true">
        {ticks.map((t) => (
          <span key={t} className="absolute left-0 leading-none" style={{ bottom: `calc(${pct(t)} - 5px)` }}>{t}</span>
        ))}
      </div>
      <div className="min-w-0 flex-1">
        <div className="relative" style={{ height }}>
          {/* Garis bantu horizontal */}
          {ticks.map((t) => (
            <span key={t} className="absolute inset-x-0 border-t border-ink/[0.08]" style={{ bottom: pct(t) }} aria-hidden="true" />
          ))}
          <div className="absolute inset-0 grid items-end" style={grid}>
            {/* Batang per jam, tumbuh dari bawah satu per satu */}
            {data.map((d, i) => (
              <div key={d.label} className="relative flex h-full items-end justify-center">
                {d === peak && (
                  <span className="absolute left-1/2 z-10 -translate-x-1/2 whitespace-nowrap rounded-full bg-forest px-3 py-1.5 text-[13px] font-semibold leading-none text-white animate-fade-up"
                        style={{ bottom: `calc(${pct(d.value)} + 12px)`, animationDelay: "700ms" }}>
                    {tooltip(d)}
                  </span>
                )}
                <div role="img" aria-label={`${d.label}: ${d.value}`}
                     className={`w-11 max-w-[70%] origin-bottom rounded-full animate-grow-up ${highlight(d, i) ? highlightClass : barClass}`}
                     style={{ height: pct(d.value), animationDelay: `${i * 90}ms` }} />
              </div>
            ))}
          </div>
        </div>
        <div className="mt-3 grid font-mono text-xs text-abu" style={grid} aria-hidden="true">
          {data.map((d) => <span key={d.label} className="text-center">{d.label}</span>)}
        </div>
      </div>
    </div>
  );
}
