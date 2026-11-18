"use client";

import { useEffect } from "react";
import Link from "next/link";
import { RotateCcw, TriangleAlert } from "lucide-react";

// Error boundary per segmen (Next.js App Router). Menangkap galat saat render
// halaman di bawah root layout. Harus Client Component agar bisa memakai reset().
// Pesan internal (error.message/stack) TIDAK ditampilkan ke pengguna; hanya
// kode kejadian (digest) yang aman untuk dilaporkan ke pengelola.
export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Detail lengkap hanya untuk konsol developer, bukan untuk tampilan pengguna.
    console.error("Galat halaman:", error);
  }, [error]);

  return (
    <div className="grid min-h-[70dvh] place-items-center px-4 py-10">
      <div className="w-full max-w-md rounded-3xl bg-white p-8 text-center shadow-[0_8px_30px_rgba(23,35,33,0.06)]">
        <span className="mx-auto grid size-14 place-items-center rounded-full bg-coral/12 text-coral">
          <TriangleAlert size={26} />
        </span>
        <p className="mt-4 font-mono text-xs uppercase tracking-[0.18em] text-abu">Terjadi kesalahan</p>
        <h1 className="mt-1 font-display text-2xl font-semibold text-ink">Halaman gagal dimuat</h1>
        <p className="mt-2 text-sm text-abu">
          Data mungkin sedang tidak tersedia. Coba muat ulang halaman ini. Bila tetap gagal,
          hubungi pengelola dan sebutkan kode kejadian di bawah.
        </p>
        {error.digest ? (
          <p className="mt-3 font-mono text-[11px] text-abu">Kode kejadian: {error.digest}</p>
        ) : null}

        <div className="mt-6 flex flex-col items-center justify-center gap-3 sm:flex-row">
          <button
            type="button"
            onClick={() => reset()}
            className="inline-flex h-11 items-center gap-2 rounded-full bg-forest px-5 text-sm font-semibold text-white transition hover:bg-forest/90"
          >
            <RotateCcw size={16} />
            Coba lagi
          </button>
          <Link
            href="/"
            className="inline-flex h-11 items-center rounded-full bg-paper px-5 text-sm font-semibold text-ink transition hover:bg-leaf/12"
          >
            Kembali ke beranda
          </Link>
        </div>
      </div>
    </div>
  );
}
