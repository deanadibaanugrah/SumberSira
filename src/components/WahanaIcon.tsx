import { Cable, FerrisWheel, LifeBuoy, TrainFront } from "lucide-react";
import type { LucideIcon } from "lucide-react";

// Ikon wahana/sewa. Untuk loker, ATV, dan bebek gayung dibuat SVG custom agar
// bentuknya sama seperti ikon mobile (bukan kunci/motor/dayung generik).
type Props = { name: string; size?: number; variant?: "mobile" | "admin"; className?: string };

const LUCIDE_ICONS: Record<string, LucideIcon> = {
  ring: LifeBuoy,
  "ring-big": LifeBuoy,
  train: TrainFront,
  flyingfox: Cable,
  carousel: FerrisWheel,
};

function SvgBase({ size, className, children }: { size: number; className: string; children: React.ReactNode }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.65"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden="true"
    >
      {children}
    </svg>
  );
}

function LokerIcon({ size, className }: { size: number; className: string }) {
  return (
    <SvgBase size={size} className={className}>
      <rect x="5" y="2.5" width="14" height="19" rx="2.4" />
      <path d="M5 8.8H19M5 14.9H19M10.3 5.7H13.7M10.3 11.8H13.7M10.3 18H13.7" />
    </SvgBase>
  );
}

function AtvIcon({ size, className }: { size: number; className: string }) {
  return (
    <SvgBase size={size} className={className}>
      <circle cx="6.1" cy="17.2" r="3.35" />
      <circle cx="17.9" cy="17.2" r="3.35" />
      <circle cx="6.1" cy="17.2" r="1.05" />
      <circle cx="17.9" cy="17.2" r="1.05" />
      <path d="M4.2 12.3H9.6L11.6 14.1H14.2L16.1 12.3H19.7" />
      <path d="M15.6 13.9L16.7 8.7M15.3 8.2H18.7" />
      <path d="M7.4 10.6H10.9M3.6 10.6H5.6" />
      <path d="M1.75 17.2A4.35 4.35 0 0 1 10.45 17.2" />
      <path d="M13.55 17.2A4.35 4.35 0 0 1 22.25 17.2" />
    </SvgBase>
  );
}

function DuckIcon({ size, className }: { size: number; className: string }) {
  return (
    <SvgBase size={size} className={className}>
      <ellipse cx="9.2" cy="13.9" rx="6.4" ry="4.1" />
      <path d="M3.2 11.6L1.3 9.9L4.1 10.4" />
      <circle cx="16.1" cy="8.1" r="3.05" />
      <path d="M18.8 7.7L21.6 9L18.6 10.2" />
      <circle cx="16.8" cy="7.5" r="0.55" fill="currentColor" stroke="none" />
      <path d="M5.45 13.9A3.4 3.4 0 0 1 11.75 15.55" />
      <path d="M2.2 20.2H11.8M13.4 20.2H21.8" />
    </SvgBase>
  );
}

// Menerima id/icon dari data mobile ("loker","bebek-gayung") maupun admin ("locker","duck").
export default function WahanaIcon({ name, size = 26, className = "" }: Props) {
  const key = (name || "").toLowerCase();
  if (key === "locker" || key === "loker") return <LokerIcon size={size} className={className} />;
  if (key === "atv") return <AtvIcon size={size} className={className} />;
  if (key === "duck" || key === "bebek-gayung" || key === "bebek") return <DuckIcon size={size} className={className} />;

  const Icon = LUCIDE_ICONS[key] ?? LifeBuoy;
  return <Icon size={size} strokeWidth={2.2} className={className} aria-hidden="true" />;
}
