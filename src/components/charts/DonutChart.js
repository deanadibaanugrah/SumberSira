// Donat sentimen ulasan. Segmen digambar searah jarum jam mulai dari atas, lalu muncul dengan animasi.
// segments: [{ label: "Positif", value: 75, color: "#1b4332" }] dalam persen (jumlah 100).
const R = 46;
const C = 2 * Math.PI * R;
const GAP = 1.6; // celah putih tipis antar segmen

export default function DonutChart({ segments, size = 112, stroke = 20 }) {
  const total = segments.reduce((s, x) => s + x.value, 0) || 1;
  // Titik mulai tiap segmen = jumlah panjang segmen sebelumnya.
  const arcs = segments.map((s, i) => ({
    ...s,
    len: (s.value / total) * C,
    start: (segments.slice(0, i).reduce((sum, x) => sum + x.value, 0) / total) * C,
  }));
  return (
    <svg viewBox="0 0 120 120" width={size} height={size} className="shrink-0 -rotate-90 animate-pop" role="img"
         aria-label={segments.map((s) => `${s.label} ${s.value}%`).join(", ")}>
      {arcs.map((a) => {
        const dash = Math.max(a.len - GAP, 0.1);
        return (
          <circle key={a.label} cx="60" cy="60" r={R} fill="none" stroke={a.color} strokeWidth={stroke}
                  strokeDasharray={`${dash} ${C - dash}`} strokeDashoffset={-a.start} />
        );
      })}
    </svg>
  );
}
