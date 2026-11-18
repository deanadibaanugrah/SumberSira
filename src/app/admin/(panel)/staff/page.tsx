import { getStaffForAdmin, requirePermission } from "@/lib/auth/dal";

import StaffView from "./components/StaffView";

// Halaman Akun Petugas (khusus admin): daftar, tambah, ubah peran/status, dan atur ulang password.
// Hanya peran dengan izin "staff" (admin). Petugas loket mendapat halaman 403.
export default async function StaffPage() {
  const admin = await requirePermission("staff");
  const { items, error } = await getStaffForAdmin();
  return <StaffView staff={items} error={error} currentId={admin.id} />;
}
