import { Fragment } from "react";

// Heatmap keramaian: baris = hari, kolom = jam. Warna makin pekat = makin ramai (dua hijau + coral untuk hampir penuh).
// Kotak muncul berurutan (animasi), arahkan kursor untuk melihat angkanya.
// Tingkatan warna: makin tinggi persen keramaian, makin pekat warnanya.
const TONES = [
  { max: 25, cls: "bg-leaf/12", label: "< 25%" },
  { max: 45, cls: "bg-leaf/30", label: "25-45%" },
  { max: 65, cls: "bg-leaf/60", label: "45-65%" },
  { max: 80, cls: "bg-leaf", label: "65-80%" },
  { max: 90, cls: "bg-forest", label: "80-90%" },
  { max: 101, cls: "bg-coral", label: "90% ke atas" },
];
// Memilih warna kotak sesuai nilai persen.
const tone = (v) => TONES.find((t) => v < t.max).cls;

// Komponen heatmap keramaian 7 hari di dashboard admin.
export default function Heatmap({ hours, rows }) {
  const grid = { gridTemplateColumns: `36px repeat(${hours.length}, minmax(0, 1fr))` };
  return (
    <div>
      <div className="grid gap-1.5" style={grid} role="img"
           aria-label={`Keramaian per jam: ${rows.map((r) => `${r.day} puncak ${Math.max(...r.values)}%`).join(", ")}`}>
        <span />
        {/* Baris judul jam di atas */}
        {hours.map((h) => <span key={h} className="text-center font-mono text-[11px] text-abu">{h}</span>)}
        {/* Satu baris per hari, satu kotak per jam */}
        {rows.map((r, ri) => (
          <Fragment key={r.day}>
            <span className="self-center text-[13px] text-abu">{r.day}</span>
            {r.values.map((v, ci) => (
              <span key={hours[ci]} title={`${r.day} ${hours[ci]}.00: ${v}%`}
                    className={`h-7 rounded-lg ${tone(v)} animate-pop transition hover:ring-2 hover:ring-ink/20`}
                    style={{ animationDelay: `${(ri * hours.length + ci) * 10}ms` }} />
            ))}
          </Fragment>
        ))}
      </div>
      {/* Keterangan warna dari sepi ke ramai */}
      <div className="mt-4 flex flex-wrap items-center gap-x-3 gap-y-2 text-xs text-abu">
        <span>Sepi</span>
        {TONES.map((t) => <span key={t.label} title={t.label} className={`h-3 w-6 rounded-full ${t.cls}`} />)}
        <span>Ramai</span>
      </div>
    </div>
  );
}
