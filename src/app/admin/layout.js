import Sidebar from "@/components/admin/Sidebar";

export const metadata = {
  title: "Admin Panel — Sumber Sira",
};

// Kerangka semua halaman admin (URL /admin/...): sidebar kiri + isi halaman.
export default function AdminLayout({ children }) {
  return (
    <div className="flex min-h-dvh bg-paper text-ink">
      <Sidebar />
      <div className="min-w-0 flex-1">{children}</div>
    </div>
  );
}
