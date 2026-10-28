"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import { checkPermission } from "./dal";
import { attemptLogin } from "./login";
import { safeAdminPath } from "./redirect";
import { createSession, deleteCurrentSession, revokeOtherSessionsOf, revokeSessionOf } from "./session";

// Server Action autentikasi admin: login, logout, dan mencabut sesi.
// Server Action terlindungi dari CSRF secara bawaan oleh Next.js (dicek Origin-nya).

export type LoginState = { error?: string; email?: string } | undefined;

// Login: validasi isian, batas percobaan, dan cek hash password ada di attemptLogin (sama dengan API token),
// lalu buat sesi baru di cookie dan arahkan ke tujuan.
export async function loginAction(_prev: LoginState, formData: FormData): Promise<LoginState> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");
  const remember = formData.get("remember") === "on";
  const next = safeAdminPath(formData.get("next"));

  const result = await attemptLogin(email, password);
  if ("error" in result) return { error: result.message, email };

  await createSession(result.user.id, remember);
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
