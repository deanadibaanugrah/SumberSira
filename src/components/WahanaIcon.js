import { Bike, Cable, CarFront, FerrisWheel, LifeBuoy, Lock, Mountain, Sailboat, Ship, TrainFront } from "lucide-react";

// Ikon tiap sewa alat/wahana (kunci "icon" di src/data/wahana.js).
// variant "admin" mengikuti ikon di tabel Wahana & Harga pada desain admin (perahu, mobil, gunung).
const ICONS = {
  ring: LifeBuoy,
  "ring-big": LifeBuoy,
  locker: Lock,
  train: TrainFront,
  duck: Sailboat,
  atv: Bike,
  flyingfox: Cable,
  carousel: FerrisWheel,
};
const ADMIN_ICONS = { ...ICONS, duck: Ship, atv: CarFront, flyingfox: Mountain };

export default function WahanaIcon({ name, size = 26, variant = "mobile", className = "" }) {
  const Icon = (variant === "admin" ? ADMIN_ICONS : ICONS)[name] ?? LifeBuoy;
  return <Icon size={size} strokeWidth={2.2} className={className} aria-hidden="true" />;
}
