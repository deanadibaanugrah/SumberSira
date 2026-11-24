import Link from "@/components/HardLink";
import { Compass } from "lucide-react";

// Halaman 404 untuk semua route yang tidak ada, termasuk hasil notFound().
// Server Component: tidak butuh interaksi, cukup tautan kembali.
export default function NotFound() {
  return (
    <div className="grid min-h-[70dvh] place-items-center px-4 py-10">
      <div className="w-full max-w-md rounded-3xl bg-white p-8 text-center shadow-[0_8px_30px_rgba(23,35,33,0.06)]">
        <span className="mx-auto grid size-14 place-items-center rounded-full bg-leaf/12 text-leaf">
          <Compass size={26} />
        </span>
        <p className="mt-4 font-mono text-xs uppercase tracking-[0.18em] text-abu">404 Not Found</p>
        <h1 className="mt-1 font-display text-2xl font-semibold text-ink">Halaman tidak ditemukan</h1>
        <p className="mt-2 text-sm text-abu">
          Alamat yang kamu buka tidak ada atau sudah dipindahkan. Periksa kembali tautannya.
        </p>

        <div className="mt-6 flex flex-col items-center justify-center gap-3 sm:flex-row">
          <Link
            href="/admin"
            className="inline-flex h-11 items-center rounded-full bg-forest px-5 text-sm font-semibold text-white transition hover:bg-forest/90"
          >
            Buka dashboard
          </Link>
        </div>
      </div>
    </div>
  );
}
