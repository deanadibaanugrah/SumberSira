// Komponen kecil yang dipakai berulang di halaman admin.
// Gaya mengikuti desain admin terbaru di Figma: kartu putih membulat (24 px), tombol dan status berbentuk pill,
// ikon di dalam lingkaran, dan hanya dua hijau (forest untuk menu aktif dan tombol, leaf untuk aksen).
import { Bell, Search } from "lucide-react";

// Judul halaman (Fraunces) + subjudul, lalu tombol aksi, kotak cari, dan lonceng di kanan.
// search: { value, onChange, placeholder } bila halaman ingin memakai kotak cari untuk menyaring data.
export function AdminHeader({ title, subtitle, action, search }) {
  const searchProps = search?.onChange ? { value: search.value, onChange: (e) => search.onChange(e.target.value) } : {};
  return (
    <header className="flex flex-wrap items-start justify-between gap-x-6 gap-y-4 pl-14 lg:pl-0">
      <div className="min-w-0">
        <h1 className="font-display text-[28px] font-semibold leading-[1.15] text-ink sm:text-[32px]">{title}</h1>
        {subtitle && <p className="mt-1.5 text-sm text-ink/60">{subtitle}</p>}
      </div>
      <div className="flex items-center gap-3 sm:gap-4">
        {action}
        <label className="hidden h-12 w-[300px] items-center gap-3 rounded-full bg-white px-4 md:flex">
          <Search size={18} className="shrink-0 text-ink/70" aria-hidden="true" />
          <span className="sr-only">Cari</span>
          <input {...searchProps} placeholder={search?.placeholder ?? "Cari booking, wahana, ulasan..."}
                 className="w-full bg-transparent text-sm text-ink outline-none placeholder:text-ink/55" />
        </label>
        <button type="button" aria-label="Notifikasi (ada yang baru)" className="relative grid size-12 place-items-center rounded-full bg-white text-ink">
          <Bell size={20} />
          <span className="absolute right-3 top-2.5 size-2 rounded-full bg-coral ring-2 ring-white" />
        </button>
      </div>
    </header>
  );
}

export function Card({ as: Tag = "section", className = "", children }) {
  return <Tag className={`rounded-3xl bg-white p-6 ${className}`}>{children}</Tag>;
}

// Judul kartu (Inter tebal 18 px) dengan subjudul opsional dan isi tambahan di kanan.
export function CardTitle({ children, sub, right, className = "" }) {
  return (
    <div className={`flex flex-wrap items-start justify-between gap-3 ${className}`}>
      <div>
        <h2 className="text-lg font-semibold leading-tight text-ink">{children}</h2>
        {sub && <p className="mt-1.5 text-[13px] text-ink/60">{sub}</p>}
      </div>
      {right}
    </div>
  );
}

// Ikon di dalam lingkaran: solid (forest, ikon putih) untuk kartu pertama, soft (hijau muda) untuk sisanya.
export function IconCircle({ icon: Icon, solid = false, size = 44, iconSize = 20, className = "" }) {
  return (
    <span style={{ width: size, height: size }}
          className={`grid shrink-0 place-items-center rounded-full ${solid ? "bg-forest text-white" : "bg-leaf/12 text-forest"} ${className}`}>
      <Icon size={iconSize} aria-hidden="true" />
    </span>
  );
}

// Kartu angka. "tall" = dashboard (ikon di atas, angka besar, label + catatan).
// "compact" = halaman lain (ikon di kiri, angka dan label di kanan).
export function StatCard({ icon, value, label, note, trend, trendIcon: TrendIcon, solid = false, variant = "compact" }) {
  if (variant === "tall") {
    return (
      <section className="rounded-3xl bg-white p-5 animate-fade-up">
        <div className="flex items-start justify-between">
          <IconCircle icon={icon} solid={solid} />
          {trend && (
            <span className="flex h-8 items-center gap-1.5 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest">
              {TrendIcon && <TrendIcon size={15} aria-hidden="true" />} {trend}
            </span>
          )}
        </div>
        <p className="mt-3 text-[32px] font-semibold leading-none tracking-tight text-ink">{value}</p>
        <p className="mt-1.5 text-sm text-ink">{label}</p>
        {note && <p className="mt-0.5 text-xs text-ink/60">{note}</p>}
      </section>
    );
  }
  return (
    <section className="flex h-24 items-center gap-4 rounded-3xl bg-white px-5 animate-fade-up">
      <IconCircle icon={icon} solid={solid} />
      <div className="min-w-0">
        <p className="text-[28px] font-semibold leading-none tracking-tight text-ink">{value}</p>
        <p className="mt-2 truncate text-sm text-ink/70">{label}</p>
      </div>
    </section>
  );
}

const PILL = {
  Baru: "bg-leaf/15 text-forest",
  Diproses: "bg-forest/10 text-forest",
  Selesai: "bg-ink/[0.07] text-ink/75",
  Ditolak: "bg-coral/12 text-coral",
  Ditampilkan: "bg-leaf/12 text-forest",
  Aktif: "bg-leaf/12 text-forest",
  Nonaktif: "bg-coral/12 text-coral",
};
const DOT = {
  Baru: "bg-leaf",
  Diproses: "bg-forest",
  Selesai: "bg-ink/50",
  Ditolak: "bg-coral",
  Ditampilkan: "bg-leaf",
  Aktif: "bg-leaf",
  Nonaktif: "bg-coral",
};

// Status berbentuk pill dengan titik warna di depannya.
export function StatusPill({ status, className = "" }) {
  return (
    <span className={`inline-flex h-7 items-center gap-1.5 whitespace-nowrap rounded-full px-3 text-xs font-semibold leading-none ${PILL[status] ?? PILL.Selesai} ${className}`}>
      <span className={`size-1.5 rounded-full ${DOT[status] ?? DOT.Selesai}`} aria-hidden="true" />
      {status}
    </span>
  );
}

// Tab filter: yang aktif Hijau Tua, sisanya abu muda.
export function FilterPills({ options, value, onChange, label = "Filter" }) {
  return (
    <div className="flex flex-wrap gap-2.5" role="tablist" aria-label={label}>
      {options.map((o) => (
        <button key={o} type="button" role="tab" aria-selected={value === o} onClick={() => onChange(o)}
                className={`h-10 rounded-full px-5 text-sm transition ${value === o ? "bg-forest font-semibold text-white" : "bg-ink/[0.05] text-ink hover:bg-ink/10"}`}>
          {o}
        </button>
      ))}
    </div>
  );
}

// Tombol utama: pill Hijau Tua seperti "Unduh Laporan", "Tambah FAQ", "Konfirmasi Booking".
export function PrimaryButton({ icon: Icon, children, className = "", ...props }) {
  return (
    <button type="button" {...props}
            className={`flex h-12 items-center justify-center gap-2.5 whitespace-nowrap rounded-full bg-forest px-6 text-sm font-semibold text-white transition hover:brightness-125 disabled:opacity-50 ${className}`}>
      {Icon && <Icon size={18} aria-hidden="true" />}
      {children}
    </button>
  );
}

// Tombol ikon bulat: abu/hijau untuk setujui atau edit, coral untuk tolak atau hapus.
export function IconButton({ tone = "leaf", label, children, className = "", ...props }) {
  const tones = {
    leaf: "bg-leaf/12 text-forest hover:bg-leaf/25",
    gray: "bg-ink/[0.07] text-ink hover:bg-ink/15",
    coral: "bg-coral/12 text-coral hover:bg-coral/25",
  };
  return (
    <button type="button" aria-label={label} title={label} {...props}
            className={`grid size-9 shrink-0 place-items-center rounded-full transition ${tones[tone]} ${className}`}>
      {children}
    </button>
  );
}

// Inisial nama untuk avatar: "Bu Rani S." -> "RS", "Kel. Ahmad" -> "A".
const TITLES = new Set(["bu", "ibu", "bpk", "bpk.", "pak", "kel", "kel."]);
export function initials(name) {
  const words = name.replace(/\./g, " ").split(/\s+/).filter((w) => w && !TITLES.has(w.toLowerCase()));
  return words.slice(0, 2).map((w) => w[0].toUpperCase()).join("");
}

export function Avatar({ name, size = 32, solid = false, className = "" }) {
  return (
    <span style={{ width: size, height: size, fontSize: Math.round(size * 0.36) }} aria-hidden="true"
          className={`grid shrink-0 place-items-center rounded-full font-semibold ${solid ? "bg-forest text-white" : "bg-ink/[0.07] text-ink"} ${className}`}>
      {initials(name)}
    </span>
  );
}

// Jendela dialog sederhana untuk form Tambah/Edit.
export function Modal({ title, onClose, children }) {
  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-ink/40 p-4" role="dialog" aria-modal="true" aria-label={title}
         onClick={onClose}>
      <div className="w-full max-w-md rounded-3xl bg-white p-6 shadow-xl animate-fade-up" onClick={(e) => e.stopPropagation()}>
        <h2 className="text-lg font-semibold text-ink">{title}</h2>
        <div className="mt-4">{children}</div>
      </div>
    </div>
  );
}

export function SecondaryButton({ children, className = "", ...props }) {
  return (
    <button type="button" {...props}
            className={`h-11 rounded-full px-5 text-sm font-semibold text-ink/70 transition hover:bg-paper ${className}`}>
      {children}
    </button>
  );
}

export const inputClass = "h-11 w-full rounded-xl border border-black/10 bg-white px-4 text-sm text-ink outline-none focus:border-leaf focus:ring-2 focus:ring-leaf/20";
export const labelClass = "block text-[13px] text-ink/70";
