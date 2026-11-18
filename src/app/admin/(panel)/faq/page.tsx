import { getFaqForAdmin, requirePermission } from "@/lib/auth/dal";

import FaqView from "./components/FaqView";

// Halaman server: hanya peran yang punya izin "faq" (admin). Petugas loket mendapat halaman 403.
// FAQ dan pertanyaan belum terjawab diambil langsung dari backend agar sama dengan yang dipakai Tanya Sira.
export default async function FaqPage() {
  await requirePermission("faq");
  const { faqs, unanswered, error } = await getFaqForAdmin();
  return <FaqView faqs={faqs} pending={unanswered} error={error} />;
}
