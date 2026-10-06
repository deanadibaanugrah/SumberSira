// Grafik garis beranimasi: garis "digambar" dari kiri ke kanan, titik muncul satu per satu,
// dan rentang jam sibuk disorot. data: [{ label: "08", value: 10 }]  ·  band: [indeksAwal, indeksAkhir].
// Satuan geometri = satuan viewBox (width × height); SVG lalu diskalakan selebar wadahnya.
export default function LineChart({
  data,
  band = null,
  max = null, // null = nilai tertinggi data; isi 100 untuk skala persen
  width = 600,
  height = 240,
  padX = 18,
  top = 18,
  bottom = null, // garis sumbu; default height - 36
  labelY = null, // baseline label sumbu X; default height - 8
  labelSize = 15,
  lineColor = "#40916c",
  pointColor = "#40916c",
  pointRing = "#ffffff",
  ringWidth = 2,
  pointRadius = null, // default strokeWidth + 3
  bandColor = "rgba(64, 145, 108, 0.14)",
  bandTop = null, // default top - 8
  axisColor = "rgba(23, 35, 33, 0.12)",
  labelColor = "rgba(23, 35, 33, 0.6)",
  strokeWidth = 4,
}) {
  const W = width;
  const H = height;
  const axis = bottom ?? H - 36;
  const peak = max ?? Math.max(...data.map((d) => d.value), 1);
  const r = pointRadius ?? strokeWidth + 3;
  const x = (i) => padX + (i * (W - padX * 2)) / (data.length - 1);
  const y = (v) => axis - (v / peak) * (axis - top);
  const points = data.map((d, i) => [x(i), y(d.value)]);
  const path = points.map(([px, py], i) => `${i ? "L" : "M"}${px},${py}`).join(" ");
  const bandY = bandTop ?? top - 8;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} className="h-auto w-full overflow-visible" role="img"
         aria-label={`Grafik: ${data.map((d) => `${d.label} ${d.value}%`).join(", ")}`}>
      {band && (
        <rect x={x(band[0])} y={bandY} width={x(band[1]) - x(band[0])} height={axis - bandY}
              fill={bandColor} className="animate-fade-up" />
      )}
      <line x1={padX} x2={W - padX} y1={axis} y2={axis} stroke={axisColor} strokeWidth="1" />
      <path d={path} fill="none" stroke={lineColor} strokeWidth={strokeWidth} strokeLinejoin="round"
            strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset="1"
            style={{ animation: "draw-line 1.4s ease-out 0.15s forwards" }} />
      {points.map(([px, py], i) => (
        <circle key={data[i].label} cx={px} cy={py} r={r} fill={pointColor} stroke={pointRing}
                strokeWidth={ringWidth} className="animate-pop" style={{ animationDelay: `${0.2 + i * 0.12}s`, transformOrigin: `${px}px ${py}px` }} />
      ))}
      {data.map((d, i) => (
        <text key={d.label} x={x(i)} y={labelY ?? H - 8} textAnchor="middle" fill={labelColor}
              style={{ fontFamily: "var(--font-mono)", fontSize: labelSize }}>
          {d.label}
        </text>
      ))}
    </svg>
  );
}
