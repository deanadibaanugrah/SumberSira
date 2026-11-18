import AdminShell from "@/components/admin/AdminShell";
import { getCurrentAdmin } from "@/repositories/admin-repository";

// Kerangka halaman admin yang wajib login: sidebar kartu di kiri + isi halaman.
// Layout mengambil data admin untuk sidebar. Layout tidak dirender ulang setiap pindah halaman,
// jadi setiap page.tsx tetap mengecek sesi dan izinnya sendiri lewat DAL.
export default async function PanelLayout({ children }) {
  const admin = await getCurrentAdmin();
  return (
    <AdminShell admin={admin}>
      {/* Peramban Chromium menyiapkan halaman tujuan di latar saat kursor menyentuh menu (atau jari menekan), jadi
          pindah halaman dengan hard refresh tetap terasa cepat. Peramban lain mengabaikannya. */}
      <script type="speculationrules" dangerouslySetInnerHTML={{ __html: JSON.stringify({ prerender: [{ where: { and: [{ href_matches: "/admin/*" }, { not: { href_matches: "/admin/login" } }] }, eagerness: "moderate" }] }) }} />
      {children}
    </AdminShell>
  );
}
