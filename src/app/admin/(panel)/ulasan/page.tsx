import { MessageSquare, Star } from "lucide-react";

import { AdminHeader, Avatar, Card, CardTitle, StatCard } from "@/components/admin/ui";
import { getReviewsForAdmin, requirePermission } from "@/lib/auth/dal";

import HapusUlasan from "./components/HapusUlasan";

// Admin: Ulasan & Rating. Daftar semua ulasan dari aplikasi dan hapus ulasan (khusus admin).
// Rata-rata dan jumlah dihitung dari daftar backend; distribusi bintang ada di halaman Insight.
const tanggal = new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short", timeZone: "Asia/Jakarta" });

// Satu baris bintang: penuh sebanyak nilai, sisanya abu.
function Bintang({ nilai, size = 14 }: { nilai: number; size?: number }) {
  return (
    <span className="flex items-center gap-0.5" aria-label={`${nilai} dari 5 bintang`}>
      {[1, 2, 3, 4, 5].map((n) => (
        <Star key={n} size={size} aria-hidden="true"
              className={n <= nilai ? "fill-leaf text-leaf" : "text-ink/20"} />
      ))}
    </span>
  );
}

export default async function UlasanPage() {
  // Hanya admin (izin "ulasan"); petugas mendapat halaman 403.
  await requirePermission("ulasan");
  const { items, error } = await getReviewsForAdmin();

  const rata = items.length ? items.reduce((s, r) => s + r.stars, 0) / items.length : 0;
  const pesanGalat = error === "BACKEND_UNREACHABLE"
    ? "Tidak bisa terhubung ke server. Pastikan backend menyala, lalu muat ulang halaman."
    : "Ulasan belum bisa dimuat. Coba muat ulang halaman.";

  return (
    <>
      <AdminHeader title="Ulasan & Rating" subtitle="Ulasan pengunjung dari aplikasi, terbaru di atas" />

      <div className="mt-6 grid gap-5 sm:grid-cols-2">
        <StatCard icon={Star} solid value={rata ? rata.toFixed(1) : "–"} label="Rata-rata bintang" />
        <StatCard icon={MessageSquare} value={items.length} label="Jumlah ulasan" />
      </div>

      <Card className="mt-5 px-4! pt-5!">
        <div className="px-2">
          <CardTitle sub="Hapus ulasan yang tidak pantas; perubahan langsung terlihat di aplikasi">Daftar Ulasan</CardTitle>
        </div>

        {error && (
          <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">{pesanGalat}</p>
        )}

        <ul className="mt-4 space-y-2.5">
          {items.map((r) => (
            <li key={r.id} className="flex items-start gap-3 rounded-2xl bg-paper px-4 py-3.5 animate-fade-up">
              <Avatar name={r.name} size={36} />
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                  <span className="text-sm font-semibold text-ink">{r.name}</span>
                  <Bintang nilai={r.stars} />
                  <span className="text-xs text-abu">{r.createdAt ? tanggal.format(new Date(r.createdAt)) : "-"}</span>
                </div>
                <p className="mt-1.5 text-sm leading-relaxed text-ink">{r.text}</p>
              </div>
              <HapusUlasan id={r.id} name={r.name} />
            </li>
          ))}
          {!error && items.length === 0 && (
            <li className="rounded-2xl bg-paper px-5 py-10 text-center text-abu">
              Belum ada ulasan. Ulasan yang dikirim dari aplikasi akan muncul di sini.
            </li>
          )}
        </ul>
      </Card>
    </>
  );
}
