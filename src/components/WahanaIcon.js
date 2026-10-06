import { Bike, Cable, FerrisWheel, LifeBuoy, Lock, Sailboat, TrainFront } from "lucide-react";

// Ikon tiap sewa alat/wahana (kunci "icon" di src/data/wahana.js).
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

export default function WahanaIcon({ name, size = 26, className = "" }) {
  const Icon = ICONS[name] ?? LifeBuoy;
  return <Icon size={size} strokeWidth={2.2} className={className} aria-hidden="true" />;
}
