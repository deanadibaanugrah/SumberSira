import "server-only";

import { cookies, headers } from "next/headers";

import { SESSION_COOKIE } from "@/lib/auth/constants";

export const API_URL = process.env.API_URL ?? "http://localhost:4000";

// Nama cookie yang dipakai backend (harus sama dengan COOKIE di backend)
export const BACKEND_COOKIE = "ss_admin_session";

// Token dari header "Authorization: Bearer" (Postman) atau dari cookie browser
async function currentToken(): Promise<string | undefined> {
  const auth = (await headers()).get("authorization");
  if (auth?.startsWith("Bearer ")) return auth.slice(7).trim() || undefined;
  return (await cookies()).get(SESSION_COOKIE)?.value;
}

// Memanggil backend dari server Next.js, sambil meneruskan sesi dan User-Agent peramban.
// Body bisa berupa JSON (string) atau FormData (multipart); content-type application/json hanya diset
// untuk body string, karena FormData harus menyusun header-nya sendiri (beserta boundary).
export async function apiFetch(path: string, init: RequestInit = {}): Promise<Response> {
  const out = new Headers(init.headers);
  const token = await currentToken();
  if (token) out.set("cookie", `${BACKEND_COOKIE}=${token}`);
  const ua = (await headers()).get("user-agent");
  if (ua) out.set("user-agent", ua);
  if (typeof init.body === "string" && !out.has("content-type")) out.set("content-type", "application/json");
  return fetch(`${API_URL}${path}`, { ...init, headers: out, cache: "no-store" });
}

// Hasil panggilan backend berbentuk tipe: data saat berhasil, status + kode galat saat gagal.
export type ApiResult<T> = { ok: true; data: T } | { ok: false; status: number; code: string };

// Pembungkus apiFetch yang menerjemahkan respons galat backend ({ error, issues }) menjadi hasil bertipe.
// Dipakai DAL dan Server Action; pesan ramah untuk pengguna tetap dipetakan di lapisan tampilan.
export async function apiJson<T>(path: string, init: RequestInit = {}): Promise<ApiResult<T>> {
  let res: Response;
  try {
    res = await apiFetch(path, init);
  } catch {
    // Backend mati atau tidak terjangkau
    return { ok: false, status: 0, code: "BACKEND_UNREACHABLE" };
  }
  const text = await res.text();
  let data: unknown = null;
  if (text) {
    try {
      data = JSON.parse(text);
    } catch {
      // jawaban kosong atau bukan JSON
    }
  }
  if (!res.ok) {
    const code = (data as { error?: string } | null)?.error ?? (res.status === 429 ? "RATE_LIMITED" : `HTTP_${res.status}`);
    return { ok: false, status: res.status, code };
  }
  return { ok: true, data: data as T };
}