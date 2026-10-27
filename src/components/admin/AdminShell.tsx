import Sidebar from "@/components/admin/Sidebar";
import type { AdminProfile } from "@/lib/auth/dal";

// Kerangka panel admin: sidebar di kiri dan isi halaman di kanan.
// Data admin (nama, peran) sudah dicek di server lalu dikirim lewat props.
export default function AdminShell({ admin, children }: { admin: AdminProfile; children: React.ReactNode }) {
  return (
    <div className="min-h-dvh bg-paper text-ink lg:flex lg:gap-6 lg:p-4">
      <Sidebar admin={admin} />
      <div className="min-w-0 flex-1 px-4 pb-8 pt-4 lg:px-0 lg:pb-4 lg:pr-2 lg:pt-3">{children}</div>
    </div>
  );
}
