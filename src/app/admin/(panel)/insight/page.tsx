import { requirePermission } from "@/lib/auth/dal";

import InsightView from "./components/InsightView";

// Admin 4/7: Insight Keramaian. Grafik keramaian dihitung dari tiket yang dibeli lalu discan petugas:
// check-in menaikkan grafik, check-out/keluar menurunkannya, hanya untuk hari yang dipilih. Tidak memakai AI.
export default async function InsightPage() {
  // Hanya admin (izin "insight"); petugas loket mendapat halaman 403.
  await requirePermission("insight");
  return <InsightView />;
}
