"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import { checkPermission } from "./dal";
import { safeAdminPath } from "./redirect";
import { createSession, deleteCurrentSession, revokeOtherSessionsOf, revokeSessionOf } from "./session";
import { verifyCredentials } from "./users";

// Server Action autentikasi admin: login, logout, dan mencabut sesi.
// Server Action terlindungi dari CSRF secara bawaan oleh Next.js (dicek Origin-nya).

export type LoginState = { error?: string; email?: string } | undefined;

const EMAIL_PATTERN = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
// Batas percobaan login: 5 kali salah dalam 10 menit = dikunci 1 menit (menahan tebak-tebakan password).
const MAX_FAILS = 5;
const WINDOW_MS = 10 * 60 * 1000;
const LOCK_MS = 60 * 1000;
const globalStore = globalThis as unknown as { __sumberSiraLoginFails?: Map<string, { count: number; first: number; lockedUntil: number }> };
const fails = (globalStore.__sumberSiraLoginFails ??= new Map());

// Login: 1. validasi isian, 2. cek batas percobaan, 3. cocokkan hash password, 4. buat sesi baru, 5. arahkan ke tujuan.
export async function loginAction(_prev: LoginState, formData: FormData): Promise<LoginState> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");
  const remember = formData.get("remember") === "on";
  const next = safeAdminPath(formData.get("next"));

  if (!email || !password) return { error: "Isi email dan password terlebih dahulu.", email };
  if (!EMAIL_PATTERN.test(email) || email.length > 100 || password.length > 200) return { error: "Format email belum benar.", email };

  const now = Date.now();
  const record = fails.get(email);
  if (record && record.lockedUntil > now) {
    return { error: `Terlalu banyak percobaan. Coba lagi dalam ${Math.ceil((record.lockedUntil - now) / 1000)} detik.`, email };
  }

  const user = await verifyCredentials(email, password);
  if (!user) {
    const fresh = !record || now - record.first > WINDOW_MS;
    const count = fresh ? 1 : record.count + 1;
    fails.set(email, { count, first: fresh ? now : record.first, lockedUntil: count >= MAX_FAILS ? now + LOCK_MS : 0 });
    // Pesan sama untuk email salah maupun password salah, supaya tidak bisa menebak email mana yang terdaftar.
    return { error: "Email atau password salah. Coba lagi.", email };
  }

  fails.delete(email);
  await createSession(user.id, remember);
  redirect(next);
}

// Logout: hapus sesi di server dan cookie di browser, lalu kembali ke halaman login.
export async function logoutAction(): Promise<void> {
  await deleteCurrentSession();
  redirect("/admin/login");
}

// Mencabut satu sesi milik sendiri (mis. login di HP yang hilang). Sesi milik admin lain tidak bisa disentuh.
export async function revokeSessionAction(sessionId: unknown) {
  const auth = await checkPermission("akun");
  if ("error" in auth) return auth;
  if (typeof sessionId !== "string" || !revokeSessionOf(auth.admin.id, sessionId)) return { ok: false as const, error: "NOT_FOUND" as const };
  revalidatePath("/admin/akun");
  return { ok: true as const };
}

// Keluar dari semua perangkat lain (sesi yang sedang dipakai tetap aktif).
export async function revokeOtherSessionsAction() {
  const auth = await checkPermission("akun");
  if ("error" in auth) return auth;
  const count = revokeOtherSessionsOf(auth.admin.id, auth.admin.sessionId);
  revalidatePath("/admin/akun");
  return { ok: true as const, count };
}
