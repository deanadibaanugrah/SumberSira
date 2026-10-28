import { KeyRound, ShieldCheck } from "lucide-react";

import { Card, CardTitle } from "@/components/admin/ui";
import type { AdminProfile } from "@/lib/auth/dal";

// Kartu Profil: nama, email, peran, dan hak akses admin yang sedang login.
export default function Profil({ admin }: { admin: AdminProfile }) {
  const access = admin.role === "admin"
    ? "Semua menu, termasuk mengubah wahana dan harga."
    : "Dashboard, Booking, Tiket & Check-in, dan melihat Wahana & Harga (tanpa mengubah).";

  return (
    <Card>
      <CardTitle>Profil</CardTitle>
      <dl className="mt-4 space-y-3 text-sm">
        {[["Nama", admin.name], ["Email", admin.email], ["Peran", admin.roleLabel]].map(([label, value]) => (
          <div key={label} className="flex justify-between gap-4 rounded-2xl bg-paper px-4 py-3">
            <dt className="text-abu">{label}</dt>
            <dd className="text-right font-semibold text-ink">{value}</dd>
          </div>
        ))}
      </dl>
      <p className="mt-4 flex items-start gap-2 rounded-2xl bg-leaf/12 px-4 py-3 text-sm text-forest">
        <ShieldCheck size={16} className="mt-0.5 shrink-0" /> Hak akses: {access}
      </p>
      <p className="mt-3 flex items-start gap-2 text-xs text-abu">
        <KeyRound size={14} className="mt-0.5 shrink-0" />
        Password disimpan sebagai hash scrypt. Cookie sesi bertanda HttpOnly, Secure, dan SameSite=Lax.
      </p>
    </Card>
  );
}
