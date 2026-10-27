import { ShieldAlert } from "lucide-react";
import Link from "next/link";

// Tampilan saat forbidden() dipanggil di DAL: sudah login (autentikasi berhasil),
// tetapi perannya tidak punya izin (otorisasi gagal). Next.js mengirim status 403 Forbidden.
export default function Forbidden() {
  return (
    <div className="grid min-h-[70dvh] place-items-center">
      <div className="max-w-md rounded-3xl bg-white p-8 text-center shadow-[0_8px_30px_rgba(23,35,33,0.06)]">
        <span className="mx-auto grid size-14 place-items-center rounded-full bg-coral/12 text-coral"><ShieldAlert size={26} /></span>
        <p className="mt-4 font-mono text-xs uppercase tracking-[0.18em] text-ink/60">403 Forbidden</p>
        <h1 className="mt-1 font-display text-2xl font-semibold text-ink">Akses ditolak</h1>
        <p className="mt-2 text-sm text-ink/70">
          Kamu sudah masuk, tetapi peran akun ini tidak punya izin untuk membuka halaman ini.
          Hubungi Pengelola (admin) bila butuh akses.
        </p>
        <Link href="/admin" className="mt-6 inline-flex h-11 items-center rounded-full bg-forest px-5 text-sm font-semibold text-white">
          Kembali ke Dashboard
        </Link>
      </div>
    </div>
  );
}
