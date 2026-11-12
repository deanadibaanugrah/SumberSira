import "server-only";

import { validateEmail } from "@/lib/validation/email";

import { verifyCredentials, type AdminUser } from "./users";

// Satu alur login untuk form admin (Server Action) dan API token (mis. dicoba lewat Postman):
// 1. validasi isian, 2. cek batas percobaan, 3. cocokkan hash password.
// Batas percobaan: 5 kali salah dalam 10 menit = dikunci 1 menit (menahan tebak-tebakan password).
const MAX_FAILS = 5;
const WINDOW_MS = 10 * 60 * 1000;
const LOCK_MS = 60 * 1000;
const globalStore = globalThis as unknown as { __sumberSiraLoginFails?: Map<string, { count: number; first: number; lockedUntil: number }> };
const fails = (globalStore.__sumberSiraLoginFails ??= new Map());

export type LoginResult =
  | { ok: true; user: AdminUser }
  | { ok: false; status: 400 | 401 | 429; error: "INVALID_INPUT" | "INVALID_CREDENTIALS" | "TOO_MANY_ATTEMPTS"; message: string; retryAfter?: number };

export async function attemptLogin(rawEmail: string, password: string): Promise<LoginResult> {
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

  const user = await verifyCredentials(email, password);
  if (!user) {
    const fresh = !record || now - record.first > WINDOW_MS;
    const count = fresh ? 1 : record.count + 1;
    fails.set(email, { count, first: fresh ? now : record.first, lockedUntil: count >= MAX_FAILS ? now + LOCK_MS : 0 });
    // Pesan sama untuk email salah maupun password salah, supaya tidak bisa menebak email mana yang terdaftar.
    return { ok: false, status: 401, error: "INVALID_CREDENTIALS", message: "Email atau password salah. Coba lagi." };
  }

  fails.delete(email);
  return { ok: true, user };
}
