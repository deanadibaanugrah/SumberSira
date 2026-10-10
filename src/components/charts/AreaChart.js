// Grafik area dengan garis halus untuk "AI Crowd Forecast" di admin.
// Animasi: garis digambar dari kiri ke kanan, titik muncul satu per satu, pita jam ramai memudar masuk.
// data: [{ label: "08", value: 10 }] dalam persen  ·  band: [indeksAwal, indeksAkhir] (boleh pecahan, mis. 1.5).
const W = 700;
const H = 316;
const LEFT = 44;
const RIGHT = 10;
const TOP = 30; // ruang untuk label puncak
const AXIS = H - 26;

// Kurva Catmull-Rom diubah ke Bezier kubik agar garis melengkung halus melewati semua titik.
function smoothPath(points) {
  return points.reduce((d, p, i) => {
    if (i === 0) return `M${p[0]},${p[1]}`;
    const p0 = points[i - 2] ?? points[i - 1];
    const p1 = points[i - 1];
    const p2 = p;
    const p3 = points[i + 1] ?? p;
    const c1 = [p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6];
    const c2 = [p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6];
    return `${d} C${c1[0]},${c1[1]} ${c2[0]},${c2[1]} ${p2[0]},${p2[1]}`;
  }, "");
}

export default function AreaChart({ data, band = null, max = 100, ticks = [0, 25, 50, 75, 100], tooltip }) {
  const x = (i) => LEFT + (i * (W - LEFT - RIGHT)) / (data.length - 1);
  const y = (v) => AXIS - (v / max) * (AXIS - TOP);
  const points = data.map((d, i) => [x(i), y(d.value)]);
  const line = smoothPath(points);
  const area = `${line} L${x(data.length - 1)},${AXIS} L${x(0)},${AXIS} Z`;
  const peakIndex = data.reduce((best, d, i) => (d.value > data[best].value ? i : best), 0);
  const [px, py] = points[peakIndex];

  return (
    <div className="relative">
      <svg viewBox={`0 0 ${W} ${H}`} className="h-auto w-full overflow-visible" role="img"
           aria-label={`Prediksi keramaian: ${data.map((d) => `${d.label}.00 ${d.value}%`).join(", ")}`}>
        {band && (
          <rect x={x(band[0])} y={y(max)} width={x(band[1]) - x(band[0])} height={AXIS - y(max)} rx="16"
                fill="rgba(64, 145, 108, 0.12)" className="animate-fade-up" />
        )}
        {ticks.map((t) => (
          <g key={t}>
            <line x1={LEFT} x2={W - RIGHT} y1={y(t)} y2={y(t)} stroke="rgba(23, 35, 33, 0.08)" strokeWidth="1" />
            <text x={0} y={y(t) + 4} fill="rgba(23, 35, 33, 0.6)" style={{ fontFamily: "var(--font-mono)", fontSize: 11 }}>{t}%</text>
          </g>
        ))}
        <path d={area} fill="rgba(64, 145, 108, 0.14)" className="animate-fade-up" style={{ animationDelay: "300ms" }} />
        <path d={line} fill="none" stroke="#1b4332" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"
              pathLength="1" strokeDasharray="1" strokeDashoffset="1" style={{ animation: "draw-line 1.4s ease-out 0.15s forwards" }} />
        {points.map(([cx, cy], i) => (
          <circle key={data[i].label} cx={cx} cy={cy} r={i === peakIndex ? 6 : 5}
                  fill={i === peakIndex ? "#1b4332" : "#ffffff"} stroke={i === peakIndex ? "#ffffff" : "#1b4332"} strokeWidth="2.5"
                  className="animate-pop" style={{ animationDelay: `${0.2 + i * 0.12}s`, transformOrigin: `${cx}px ${cy}px` }} />
        ))}
        {data.map((d, i) => (
          <text key={d.label} x={x(i)} y={H - 4} textAnchor="middle" fill="rgba(23, 35, 33, 0.6)"
                style={{ fontFamily: "var(--font-mono)", fontSize: 12 }}>
            {d.label}
          </text>
        ))}
      </svg>
      {tooltip && (
        <span className="absolute -translate-x-1/2 -translate-y-full whitespace-nowrap rounded-full bg-forest px-3.5 py-2 text-[13px] font-semibold leading-none text-white animate-fade-up"
              style={{ left: `${(px / W) * 100}%`, top: `calc(${(py / H) * 100}% - 12px)`, animationDelay: "1.2s" }}>
          {tooltip(data[peakIndex])}
        </span>
      )}
    </div>
  );
}
