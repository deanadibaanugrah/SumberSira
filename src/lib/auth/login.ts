import "server-only";

import { BACKEND_COOKIE, apiFetch } from "@/repositories/api-server";
import { validateEmail } from "@/lib/validation/email";

import type { Role } from "./roles";

// Satu alur login untuk form admin (Server Action) dan API token (mis. dicoba lewat Postman):
// 1. validasi isian, 2. cek batas percobaan, 3. minta backend mencocokkan password dan membuat sesi.
// Password dan sesi disimpan di backend (database). Next.js hanya meneruskan, lalu memegang token sesi dari backend.
// Backend belum membatasi percobaan login, jadi batasnya dipasang di sini:
// 5 kali salah dalam 10 menit = dikunci 1 menit (menahan tebak-tebakan password).
const MAX_FAILS = 5;
const WINDOW_MS = 10 * 60 * 1000;
const LOCK_MS = 60 * 1000;
// Lama sesi mengikuti aturan backend (routes/auth.ts): "Ingat saya" 7 hari, tanpa itu 8 jam.
const SHORT_SESSION_MS = 8 * 60 * 60 * 1000;
const LONG_SESSION_MS = 7 * 24 * 60 * 60 * 1000;
const globalStore = globalThis as unknown as { __sumberSiraLoginFails?: Map<string, { count: number; first: number; lockedUntil: number }> };
const fails = (globalStore.__sumberSiraLoginFails ??= new Map());

export type BackendUser = { id: string; name: string; email: string; role: Role };

export type LoginResult =
  | { ok: true; token: string; expiresAt: number; user: BackendUser }
  | {
      ok: false;
      status: 400 | 401 | 429 | 502;
      error: "INVALID_INPUT" | "INVALID_CREDENTIALS" | "TOO_MANY_ATTEMPTS" | "BACKEND_UNAVAILABLE";
      message: string;
      retryAfter?: number;
    };

export async function attemptLogin(rawEmail: string, password: string, remember = false): Promise<LoginResult> {
  const email = rawEmail.trim().toLowerCase();
  if (!email || !password) return { ok: false, status: 400, error: "INVALID_INPUT", message: "Isi email dan password terlebih dahulu." };
  const emailError = validateEmail(email);
  if (emailError) return { ok: false, status: 400, error: "INVALID_INPUT", message: emailError };
  if (password.length > 200) return { ok: false, status: 400, error: "INVALID_INPUT", message: "Password terlalu panjang." };

  const now = Date.now();
  const record = fails.get(email);
  if (record && record.lockedUntil > now) {
    const retryAfter = Math.ceil((record.lockedUntil - now) / 1000);
    return { ok: false, status: 429, error: "TOO_MANY_ATTEMPTS", message: `Terlalu banyak percobaan. Coba lagi dalam ${retryAfter} detik.`, retryAfter };
  }

  let res: Response;
  try {
    res = await apiFetch("/auth/login", { method: "POST", body: JSON.stringify({ email, password, remember }) });
  } catch {
    return { ok: false, status: 502, error: "BACKEND_UNAVAILABLE", message: "Server tidak dapat dihubungi. Coba lagi sebentar lagi." };
  }

  if (res.status === 401) {
    const fresh = !record || now - record.first > WINDOW_MS;
    const count = fresh ? 1 : record.count + 1;
    fails.set(email, { count, first: fresh ? now : record.first, lockedUntil: count >= MAX_FAILS ? now + LOCK_MS : 0 });
    // Pesan sama untuk email salah maupun password salah, supaya tidak bisa menebak email mana yang terdaftar.
    return { ok: false, status: 401, error: "INVALID_CREDENTIALS", message: "Email atau password salah. Coba lagi." };
  }
  if (res.status === 400) return { ok: false, status: 400, error: "INVALID_INPUT", message: "Isian belum benar. Periksa email dan password." };
  if (!res.ok) return { ok: false, status: 502, error: "BACKEND_UNAVAILABLE", message: "Login gagal di server. Coba lagi sebentar lagi." };

  // Token sesi dikirim backend lewat header Set-Cookie (bukan di body).
  const raw = res.headers.getSetCookie().find((c) => c.startsWith(`${BACKEND_COOKIE}=`));
  const token = raw?.split(";")[0].slice(BACKEND_COOKIE.length + 1);
  if (!token) return { ok: false, status: 502, error: "BACKEND_UNAVAILABLE", message: "Login gagal. Coba lagi." };

  fails.delete(email);
  const u = await res.json();
  return {
    ok: true,
    token,
    expiresAt: now + (remember ? LONG_SESSION_MS : SHORT_SESSION_MS),
    user: { id: u.id, name: u.name, email: u.email, role: u.role as Role },
  };
}
