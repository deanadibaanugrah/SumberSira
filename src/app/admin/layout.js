import AdminShell from "@/components/admin/AdminShell";

export const metadata = {
  title: "Admin Panel · Sumber Sira",
};

// Kerangka semua halaman admin (URL /admin/...): wajib login, lalu sidebar kartu di kiri + isi halaman.
export default function AdminLayout({ children }) {
  return <AdminShell>{children}</AdminShell>;
}
