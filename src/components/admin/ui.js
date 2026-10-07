// Komponen kecil yang dipakai berulang di halaman admin.

export function AdminHeader({ title, action }) {
  return (
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between bg-white pl-16 pr-6 shadow-[0_1px_0_rgba(0,0,0,0.04),0_6px_16px_rgba(0,0,0,0.03)] lg:pl-8">
      <h1 className="font-display text-xl font-semibold text-ink">{title}</h1>
      <div className="flex items-center gap-5">
        {action}
        <span className="grid size-9 place-items-center rounded-full bg-leaf/12 text-[10px] font-semibold text-forest" title="Admin: Pak Yono">PY</span>
      </div>
    </header>
  );
}

export function Card({ className = "", children }) {
  return <section className={`rounded-xl bg-white px-5 pb-5 pt-4 shadow-[0_1px_2px_rgba(0,0,0,0.04)] ${className}`}>{children}</section>;
}

// Judul kartu: 15 px di kebanyakan halaman, 14 px di dashboard (size="sm").
export function CardTitle({ children, sub, size = "md" }) {
  return (
    <div className="mb-4">
      <h2 className={`font-display font-semibold leading-tight text-ink ${size === "sm" ? "text-sm" : "text-[15px]"}`}>{children}</h2>
      {sub && <p className="mt-1 text-[10px] text-ink/70">{sub}</p>}
    </div>
  );
}

// Kartu angka: 110 px dengan catatan kecil di bawah, 90 px tanpa catatan (seperti di desain Galeri).
export function StatCard({ label, value, note, dot = "leaf" }) {
  return (
    <section className={`rounded-xl bg-white px-4 pt-3 shadow-[0_1px_2px_rgba(0,0,0,0.04)] animate-fade-up ${note ? "h-[110px]" : "h-[90px]"}`}>
      <p className="flex items-center gap-2 text-[11px] text-ink/70">
        <span className={`size-[7px] rounded-full ${dot === "forest" ? "bg-forest" : "bg-leaf"}`} /> {label}
      </p>
      <p className={`font-mono text-[22px] font-medium leading-tight text-ink ${note ? "mt-3.5" : "mt-2.5"}`}>{value}</p>
      {note && <p className="mt-2 text-[10px] text-ink/60">{note}</p>}
    </section>
  );
}

const PILL = {
  Baru: "bg-leaf/15 text-leaf",
  Diproses: "bg-leaf/12 text-forest",
  Selesai: "bg-ink/10 text-ink",
  Ditolak: "bg-coral/12 text-coral",
  Aktif: "bg-ink/10 text-ink",
  Nonaktif: "bg-coral/12 text-coral",
};

// size "sm" = daftar ringkas di dashboard, "md" = tabel booking, "tag" = tabel wahana.
const PILL_SIZE = {
  sm: "h-6 min-w-[70px] px-3 text-[9px]",
  md: "h-7 min-w-[82px] px-3 text-[10px]",
  tag: "h-6 min-w-[72px] px-3 text-[9px]", // kolom status tabel Wahana
};

export function StatusPill({ status, size = "sm" }) {
  return (
    <span className={`inline-flex items-center justify-center rounded-full text-center font-semibold leading-none ${PILL_SIZE[size]} ${PILL[status] ?? PILL.Selesai}`}>
      {status}
    </span>
  );
}

export function FilterPills({ options, value, onChange }) {
  return (
    <div className="flex flex-wrap gap-2.5" role="tablist">
      {options.map((o) => (
        <button key={o} type="button" role="tab" aria-selected={value === o} onClick={() => onChange(o)}
                className={`h-9 rounded-full pl-3.5 pr-5 text-[11px] transition ${value === o ? "bg-leaf font-semibold text-white" : "bg-leaf/15 text-ink hover:bg-leaf/25"}`}>
          {o}
        </button>
      ))}
    </div>
  );
}

export function PrimaryButton({ children, className = "", ...props }) {
  return (
    <button type="button" {...props}
            className={`h-8 min-w-[150px] rounded-md bg-leaf px-5 text-[11px] font-semibold text-white transition hover:brightness-110 disabled:opacity-50 ${className}`}>
      {children}
    </button>
  );
}

export function IconButton({ tone = "leaf", label, children, ...props }) {
  const tones = { leaf: "bg-leaf/12 text-leaf hover:bg-leaf/25", coral: "bg-coral/12 text-coral hover:bg-coral/25" };
  return (
    <button type="button" aria-label={label} title={label} {...props}
            className={`grid size-7 place-items-center rounded-full transition ${tones[tone]}`}>
      {children}
    </button>
  );
}

// Jendela dialog sederhana untuk form Tambah/Edit.
export function Modal({ title, onClose, children }) {
  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-ink/40 p-4" role="dialog" aria-modal="true" aria-label={title}
         onClick={onClose}>
      <div className="w-full max-w-md rounded-xl bg-white p-5 shadow-xl animate-fade-up" onClick={(e) => e.stopPropagation()}>
        <h2 className="font-display text-[15px] font-semibold text-ink">{title}</h2>
        <div className="mt-4">{children}</div>
      </div>
    </div>
  );
}

export const inputClass = "h-9 w-full rounded-lg border border-black/10 bg-white px-3.5 text-[11px] text-ink outline-none focus:border-leaf focus:ring-2 focus:ring-leaf/20";
