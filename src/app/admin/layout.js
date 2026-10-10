import Sidebar from "@/components/admin/Sidebar";

export const metadata = {
  title: "Admin Panel · Sumber Sira",
};

// Kerangka semua halaman admin (URL /admin/...): sidebar kartu di kiri + isi halaman, di atas latar abu muda.
export default function AdminLayout({ children }) {
  return (
    <div className="min-h-dvh bg-paper text-ink lg:flex lg:gap-6 lg:p-4">
      <Sidebar />
      <div className="min-w-0 flex-1 px-4 pb-8 pt-4 lg:px-0 lg:pb-4 lg:pr-2 lg:pt-3">{children}</div>
    </div>
  );
}
