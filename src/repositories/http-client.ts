"use client";

// Pemanggil API dari browser ke Route Handler Next.js (/api/...). Route Handler meneruskannya ke backend dengan sesi login.
export class ApiError extends Error {
  constructor(public status: number, public code: string) {
    super(code);
  }
}

export async function api<T = unknown>(method: "GET" | "POST" | "PATCH" | "DELETE", url: string, body?: unknown): Promise<T> {
  let res: Response;
  try {
    res = await fetch(url, {
      method,
      headers: body !== undefined ? { "content-type": "application/json" } : undefined,
      body: body !== undefined ? JSON.stringify(body) : undefined,
      cache: "no-store",
    });
  } catch {
    throw new ApiError(0, "NETWORK");
  }
  let data: { error?: string } | null = null;
  try {
    data = await res.json();
  } catch {
    // jawaban kosong atau bukan JSON
  }
  // Sesi habis saat panel terbuka: kembali ke halaman login (alamat asal dibawa supaya bisa kembali).
  if (res.status === 401 && url.startsWith("/api/admin")) {
    // Pindah halaman penuh (bukan router) dengan sengaja: memuat ulang membersihkan data admin yang tersimpan di browser.
    // eslint-disable-next-line @next/next/no-location-assign-relative-destination
    window.location.href = `/admin/login?next=${encodeURIComponent(window.location.pathname)}`;
    throw new ApiError(401, "UNAUTHORIZED");
  }
  if (!res.ok) throw new ApiError(res.status, data?.error ?? "ERROR");
  return data as T;
}
