import { StatCard } from "@/components/admin/ui";

import BookingStat from "./BookingStat";
import LiveCrowdStat from "./LiveCrowdStat";
import TiketTerjualStat from "./TiketTerjualStat";
import WahanaTerlarisStat from "./WahanaTerlarisStat";

// Baris 1: empat kartu ringkasan, angkanya live dari backend (dashboard, tiket, Live Crowd).
export default function StatRingkasan() {
  return (
    <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      <BookingStat />
      <WahanaTerlarisStat />
      <LiveCrowdStat />
      <TiketTerjualStat />
    </div>
  );
}
