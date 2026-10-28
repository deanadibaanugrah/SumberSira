// Komponen kecil yang dipakai berulang di halaman admin.
// Gaya diseragamkan dengan aplikasi mobile (Liquid Glass): lapisan navigasi (sidebar dan header) dari kaca terang,
// isi halaman berupa kartu putih solid membulat, angka besar memakai Fraunces, dan warna hanya dari palet
// (Hijau Tua, Hijau Daun, Ink, Abu, Abu Muda, Coral untuk ramai/tolak/keluhan).
import { Bell, Search } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import type { ButtonHTMLAttributes, ElementType, ReactNode } from "react";

// Header halaman berupa bar kaca yang menempel di atas saat digulir: judul (Fraunces) + subjudul,
// lalu tombol aksi, kotak cari, dan lonceng di kanan. Isi halaman lewat di bawahnya dan tampak buram.
// search: { value, onChange, placeholder } bila halaman ingin memakai kotak cari untuk menyaring data.
type SearchProps = { value: string; onChange: (value: string) => void; placeholder?: string };
export function AdminHeader({ title, subtitle, action, search }: { title: ReactNode; subtitle?: ReactNode; action?: ReactNode; search?: SearchProps }) {
  // Kalau halaman mengirim search, kotak cari dihubungkan ke state halaman itu.
  const searchProps = search?.onChange ? { value: search.value, onChange: (e) => search.onChange(e.target.value) } : {};
  return (
    <header className="glass-light sticky top-3 z-30 flex flex-wrap items-center justify-between gap-x-6 gap-y-3 rounded-[28px] py-3 pl-[72px] pr-3 lg:top-4 lg:pl-6">
      <div className="min-w-0">
        <h1 className="font-display text-[26px] font-semibold leading-[1.15] text-ink sm:text-[28px]">{title}</h1>
        {subtitle && <p className="mt-1 text-[13px] text-abu">{subtitle}</p>}
      </div>
      <div className="flex items-center gap-3">
        {action}
        <label className="hidden h-12 w-[280px] items-center gap-3 rounded-full border border-ink/10 bg-white px-4 md:flex">
          <Search size={18} className="shrink-0 text-abu" aria-hidden="true" />
          <span className="sr-only">Cari</span>
          <input {...searchProps} placeholder={search?.placeholder ?? "Cari booking, wahana, ulasan..."}
                 className="w-full bg-transparent text-sm text-ink outline-none placeholder:text-ink/55" />
        </label>
        <button type="button" aria-label="Notifikasi (ada yang baru)" className="relative grid size-12 place-items-center rounded-full border border-ink/10 bg-white text-ink">
          <Bell size={20} />
          <span className="absolute right-3 top-2.5 size-2.5 rounded-full bg-leaf ring-2 ring-white" />
        </button>
      </div>
    </header>
  );
}

// Kartu putih membulat, wadah dasar hampir semua bagian admin.
export function Card({ as: Tag = "section", className = "", children }: { as?: ElementType; className?: string; children: ReactNode }) {
  return <Tag className={`rounded-3xl bg-white p-6 ${className}`}>{children}</Tag>;
}

// Judul kartu (Inter tebal 18 px) dengan subjudul opsional dan isi tambahan di kanan.
export function CardTitle({ children, sub, right, className = "" }: { children: ReactNode; sub?: ReactNode; right?: ReactNode; className?: string }) {
  return (
    <div className={`flex flex-wrap items-start justify-between gap-3 ${className}`}>
      <div>
        <h2 className="text-lg font-semibold leading-tight text-ink">{children}</h2>
        {sub && <p className="mt-1.5 text-[13px] text-abu">{sub}</p>}
      </div>
      {right}
    </div>
  );
}

// Ikon di dalam lingkaran: solid (forest, ikon putih) untuk kartu pertama, soft (hijau muda) untuk sisanya.
export function IconCircle({ icon: Icon, solid = false, size = 44, iconSize = 20, className = "" }: { icon: LucideIcon; solid?: boolean; size?: number; iconSize?: number; className?: string }) {
  return (
    <span style={{ width: size, height: size }}
          className={`grid shrink-0 place-items-center rounded-full ${solid ? "bg-forest text-white" : "bg-leaf/12 text-forest"} ${className}`}>
      <Icon size={iconSize} aria-hidden="true" />
    </span>
  );
}

// Kartu angka. "tall" = dashboard (ikon di atas, angka besar, label + catatan).
// "compact" = halaman lain (ikon di kiri, angka dan label di kanan). Angka memakai Fraunces seperti angka hero di mobile.
type StatCardProps = { icon: LucideIcon; value: ReactNode; label: string; note?: string; trend?: string; trendIcon?: LucideIcon; solid?: boolean; variant?: "tall" | "compact" };
export function StatCard({ icon, value, label, note, trend, trendIcon: TrendIcon, solid = false, variant = "compact" }: StatCardProps) {
  // Varian tall dipakai di dashboard.
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
        <p className="mt-3 font-display text-[32px] font-semibold leading-none tabular-nums text-forest">{value}</p>
        <p className="mt-2 text-sm text-ink">{label}</p>
        {note && <p className="mt-0.5 text-xs text-abu">{note}</p>}
      </section>
    );
  }
  // Varian compact dipakai di halaman lain.
  return (
    <section className="flex h-24 items-center gap-4 rounded-3xl bg-white px-5 animate-fade-up">
      <IconCircle icon={icon} solid={solid} />
      <div className="min-w-0">
        <p className="font-display text-[28px] font-semibold leading-none tabular-nums text-forest">{value}</p>
        <p className="mt-2 truncate text-sm text-abu">{label}</p>
      </div>
    </section>
  );
}

// Chip status seperti di aplikasi mobile: latar putih bergaris Ink 10% dengan titik warna di depannya.
// Baru dan Di dalam memakai latar Hijau Daun 12% supaya menonjol; Coral hanya untuk Ditolak.
const PILL = {
  Baru: "border-transparent bg-leaf/12 text-forest",
  Diproses: "border-ink/10 bg-white text-ink",
  Selesai: "border-ink/10 bg-white text-abu",
  Ditolak: "border-ink/10 bg-white text-ink",
  Ditampilkan: "border-ink/10 bg-white text-ink",
  Aktif: "border-ink/10 bg-white text-ink",
  Nonaktif: "border-ink/10 bg-white text-abu",
  "Di dalam": "border-transparent bg-leaf/12 text-forest",
  "Belum masuk": "border-ink/10 bg-white text-ink",
  Keluar: "border-ink/10 bg-white text-abu",
};
// Warna titik kecil di depan teks status.
const DOT = {
  Baru: "bg-leaf",
  Diproses: "bg-forest",
  Selesai: "bg-abu",
  Ditolak: "bg-coral",
  Ditampilkan: "bg-leaf",
  Aktif: "bg-leaf",
  Nonaktif: "bg-abu",
  "Di dalam": "bg-leaf",
  "Belum masuk": "bg-leaf",
  Keluar: "bg-abu",
};

// Status berbentuk pill dengan titik warna di depannya.
export function StatusPill({ status, className = "" }: { status: string; className?: string }) {
  return (
    <span className={`inline-flex h-7 items-center gap-1.5 whitespace-nowrap rounded-full border px-3 text-xs font-semibold leading-none ${PILL[status] ?? PILL.Selesai} ${className}`}>
      <span className={`size-1.5 rounded-full ${DOT[status] ?? DOT.Selesai}`} aria-hidden="true" />
      {status}
    </span>
  );
}

// Tab filter seperti chip pilihan di mobile: yang aktif Hijau Tua, sisanya Abu Muda.
export function FilterPills({ options, value, onChange, label = "Filter" }: { options: string[]; value: string; onChange: (value: string) => void; label?: string }) {
  return (
    <div className="flex flex-wrap gap-2.5" role="tablist" aria-label={label}>
      {options.map((o) => (
        <button key={o} type="button" role="tab" aria-selected={value === o} onClick={() => onChange(o)}
                className={`h-10 rounded-full px-5 text-sm transition ${value === o ? "bg-forest font-semibold text-white" : "bg-paper text-ink hover:bg-leaf/12"}`}>
          {o}
        </button>
      ))}
    </div>
  );
}

// Tombol utama: pill Hijau Tua seperti "Unduh Laporan", "Tambah FAQ", "Konfirmasi Booking".
export function PrimaryButton({ icon: Icon, children, className = "", ...props }: ButtonHTMLAttributes<HTMLButtonElement> & { icon?: LucideIcon }) {
  return (
    <button type="button" {...props}
            className={`flex h-12 items-center justify-center gap-2.5 whitespace-nowrap rounded-full bg-forest px-6 text-sm font-semibold text-white transition hover:brightness-125 disabled:opacity-50 ${className}`}>
      {Icon && <Icon size={18} aria-hidden="true" />}
      {children}
    </button>
  );
}

// Tombol ikon bulat: abu/hijau untuk setujui atau edit, coral untuk tolak atau hapus.
export function IconButton({ tone = "leaf", label, children, className = "", ...props }: ButtonHTMLAttributes<HTMLButtonElement> & { tone?: "leaf" | "gray" | "coral"; label: string }) {
  // Pilihan warna tombol: leaf (hijau), gray (Abu Muda), coral (merah bata).
  const tones = {
    leaf: "bg-leaf/12 text-forest hover:bg-leaf/30",
    gray: "bg-paper text-ink hover:bg-ink/10",
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
// Gelar yang dilewati saat membuat inisial.
const TITLES = new Set(["bu", "ibu", "bpk", "bpk.", "pak", "kel", "kel."]);
export function initials(name: string): string {
  const words = name.replace(/\./g, " ").split(/\s+/).filter((w) => w && !TITLES.has(w.toLowerCase()));
  return words.slice(0, 2).map((w) => w[0].toUpperCase()).join("");
}

// Lingkaran berisi inisial nama.
export function Avatar({ name, size = 32, solid = false, className = "" }: { name: string; size?: number; solid?: boolean; className?: string }) {
  return (
    <span style={{ width: size, height: size, fontSize: Math.round(size * 0.36) }} aria-hidden="true"
          className={`grid shrink-0 place-items-center rounded-full font-semibold ${solid ? "bg-forest text-white" : "bg-leaf/12 text-forest"} ${className}`}>
      {initials(name)}
    </span>
  );
}

// Jendela dialog sederhana untuk form Tambah/Edit.
export function Modal({ title, onClose, children }: { title: string; onClose: () => void; children: ReactNode }) {
  // Klik di latar gelap menutup dialog, klik di dalam kotak putih tidak (stopPropagation).
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

// Tombol kedua (tanpa warna), misalnya Batal.
export function SecondaryButton({ children, className = "", ...props }: ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button type="button" {...props}
            className={`h-11 rounded-full px-5 text-sm font-semibold text-abu transition hover:bg-paper ${className}`}>
      {children}
    </button>
  );
}

// Gaya kolom isian dan label yang dipakai di form admin.
export const inputClass = "h-11 w-full rounded-xl border border-ink/10 bg-white px-4 text-sm text-ink outline-none focus:border-leaf focus:ring-2 focus:ring-leaf/30";
export const labelClass = "block text-[13px] text-abu";
