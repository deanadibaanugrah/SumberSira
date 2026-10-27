import { AdminHeader } from "@/components/admin/ui";
import { getMySessions, requirePermission } from "@/lib/auth/dal";

import Profil from "./components/Profil";
import SesiLogin from "./components/SesiLogin";

// Akun & Sesi: profil admin yang login, hak aksesnya, dan daftar sesi login aktif.
// Daftar sesi dibaca lewat DAL dan hanya berisi sesi milik akun ini (query dibatasi ke pemiliknya).
// Tiap bagian ada di folder components/.
export default async function AkunPage() {
  const admin = await requirePermission("akun");
  const sessions = await getMySessions();

  return (
    <>
      <AdminHeader title="Akun & Sesi" subtitle="Profil, hak akses, dan perangkat yang sedang login" />
      <div className="mt-6 grid gap-5 lg:grid-cols-[minmax(0,1fr)_minmax(0,1.4fr)]">
        <Profil admin={admin} />
        <SesiLogin sessions={sessions} />
      </div>
    </>
  );
}
