import { requirePermission } from "@/lib/auth/dal";

import FaqView from "./components/FaqView";

// Halaman server: hanya peran yang punya izin "faq" (admin). Petugas loket mendapat halaman 403.
export default async function FaqPage() {
  await requirePermission("faq");
  return <FaqView />;
}
