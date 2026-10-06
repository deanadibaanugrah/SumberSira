// Grafik batang beranimasi: tiap batang "tumbuh" dari bawah, berurutan (syarat dosen: animasi grafik).
// data: [{ label: "08", value: 22 }]  ·  highlight: (item, index) => true untuk batang yang ditonjolkan.
// columns: jumlah kolom grid (boleh lebih banyak dari data agar ada ruang kosong di kanan, seperti desain).
export default function BarChart({
  data,
  highlight = () => false,
  height = 240,
  columns = null,
  barClass = "bg-leaf/75",
  highlightClass = "bg-forest",
  labelClass = "text-xs text-ink/60",
  rounded = "rounded-lg",
  barWidth = "w-[55%]",
  align = "center", // "center" | "start": posisi batang di dalam kolomnya
  showAxis = true,
}) {
  const max = Math.max(...data.map((d) => d.value), 1);
  const grid = { gridTemplateColumns: `repeat(${columns ?? data.length}, minmax(0, 1fr))` };
  const justify = align === "start" ? "justify-start" : "justify-center";
  return (
    <div>
      <div className={`grid items-end ${showAxis ? "border-b border-black/10" : ""}`} style={{ ...grid, height }}>
        {data.map((d, i) => (
          <div key={d.label} className={`flex h-full items-end ${justify}`}>
            <div
              role="img"
              aria-label={`${d.label}: ${d.value}`}
              className={`${barWidth} ${rounded} origin-bottom animate-grow-up ${highlight(d, i) ? highlightClass : barClass}`}
              style={{ height: `${(d.value / max) * 100}%`, animationDelay: `${i * 90}ms` }}
            />
          </div>
        ))}
      </div>
      <div className="mt-2 grid" style={grid}>
        {data.map((d) => (
          <span key={d.label} className={`flex ${justify}`}>
            <span className={`${barWidth} text-center font-mono ${labelClass}`}>{d.label}</span>
          </span>
        ))}
      </div>
    </div>
  );
}
