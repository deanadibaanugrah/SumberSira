import { getInsightForAdmin, requirePermission } from "@/repositories/admin-repository";

import InsightView from "./components/InsightView";

// Admin: AI Insight. Analisis dibuat backend dari ulasan dan keramaian (aturan, bukan LLM).
// Hanya admin (izin "insight"); petugas loket mendapat halaman 403.
export default async function InsightPage() {
  await requirePermission("insight");
  const { data, error } = await getInsightForAdmin();
  return <InsightView data={data} error={error} />;
}
