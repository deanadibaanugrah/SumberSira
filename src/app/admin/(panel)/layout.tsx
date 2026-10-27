import AdminShell from "@/components/admin/AdminShell";
import { getCurrentAdmin } from "@/lib/auth/dal";

// Kerangka halaman admin yang wajib login: sidebar kartu di kiri + isi halaman.
// Layout mengambil data admin untuk sidebar. Layout tidak dirender ulang setiap pindah halaman,
// jadi setiap page.tsx tetap mengecek sesi dan izinnya sendiri lewat DAL.
export default async function PanelLayout({ children }) {
  const admin = await getCurrentAdmin();
  return <AdminShell admin={admin}>{children}</AdminShell>;
}
