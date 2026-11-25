"use client";

import { ChevronLeft, ChevronRight } from "lucide-react";
import { useRouter } from "next/navigation";
import { useTransition } from "react";

type PagerProps = {
  page: number;
  total: number;
  limit: number;
  // Halaman tujuan, mis. "/admin/galeri" atau "/admin/ulasan".
  basePath: string;
  // Query lain yang harus dipertahankan saat pindah halaman (mis. status filter).
  params?: Record<string, string | undefined>;
};

// Navigasi halaman untuk tabel/daftar besar. Halaman disimpan di query string
// (?page=2) supaya data diambil ulang dari server, bukan dipotong di browser.
export default function Pager({ page, total, limit, basePath, params = {} }: PagerProps) {
  const router = useRouter();
  const [pending, startTransition] = useTransition();

  const pages = Math.max(1, Math.ceil(total / limit));
  const current = Math.min(Math.max(1, page), pages);
  const from = total === 0 ? 0 : (current - 1) * limit + 1;
  const to = Math.min(current * limit, total);

  const pindah = (next: number) => {
    if (next < 1 || next > pages || next === current || pending) return;

    const query = new URLSearchParams();
    for (const [key, value] of Object.entries(params)) {
      if (value) query.set(key, value);
    }
    if (next > 1) query.set("page", String(next));

    const qs = query.toString();
    startTransition(() => router.push(qs ? `${basePath}?${qs}` : basePath));
  };

  // Satu halaman penuh: kontrol tidak perlu ditampilkan.
  if (total <= limit) return null;

  return (
    <div className="mt-4 flex flex-wrap items-center justify-between gap-3">
      <p className="text-sm text-abu">
        Menampilkan {from}–{to} dari {total}
      </p>
      <div className="flex items-center gap-2 text-sm">
        <button
          type="button"
          onClick={() => pindah(current - 1)}
          disabled={current <= 1 || pending}
          aria-label="Halaman sebelumnya"
          className="grid size-9 place-items-center rounded-full bg-paper text-ink transition hover:bg-leaf/12 disabled:opacity-40"
        >
          <ChevronLeft size={17} />
        </button>
        <span className="px-1 font-semibold text-ink" aria-live="polite">
          Halaman {current} / {pages}
        </span>
        <button
          type="button"
          onClick={() => pindah(current + 1)}
          disabled={current >= pages || pending}
          aria-label="Halaman berikutnya"
          className="grid size-9 place-items-center rounded-full bg-paper text-ink transition hover:bg-leaf/12 disabled:opacity-40"
        >
          <ChevronRight size={17} />
        </button>
      </div>
    </div>
  );
}
