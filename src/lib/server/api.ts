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

// Memanggil backend dari server Next.js, sambil meneruskan sesi dan User-Agent peramban
export async function apiFetch(path: string, init: RequestInit = {}): Promise<Response> {
  const out = new Headers(init.headers);
  const token = await currentToken();
  if (token) out.set("cookie", `${BACKEND_COOKIE}=${token}`);
  const ua = (await headers()).get("user-agent");
  if (ua) out.set("user-agent", ua);
  if (init.body && !out.has("content-type")) out.set("content-type", "application/json");
  return fetch(`${API_URL}${path}`, { ...init, headers: out, cache: "no-store" });
}