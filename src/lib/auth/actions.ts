"use server";

import { revalidatePath } from "next/cache";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import { apiFetch, apiJson } from "@/lib/server/api";

import { SESSION_COOKIE } from "./constants";
import { checkPermission } from "./dal";
import { attemptLogin } from "./login";
import { safeAdminPath } from "./redirect";
import { validatePassword } from "@/lib/validation/password";

export type LoginState = { error?: string; email?: string } | undefined;

// Login: validasi email, batas percobaan, dan pengecekan password ke backend ada di attemptLogin
// (alur yang sama dengan API token untuk Postman). Token sesi dari backend disimpan ke cookie HttpOnly.
export async function loginAction(_prev: LoginState, formData: FormData): Promise<LoginState> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");
  const remember = formData.get("remember") === "on";
  const next = safeAdminPath(formData.get("next"));

  const result = await attemptLogin(email, password, remember);
  if ("error" in result) return { error: result.message, email };

  (await cookies()).set(SESSION_COOKIE, result.token, {
    httpOnly: true,
    secure: true,
    sameSite: "lax",
    path: "/",
    ...(remember ? { expires: new Date(result.expiresAt) } : {}),
  });

  redirect(next);
}

// Logout: hapus sesi di backend lalu hapus cookie di browser
export async function logoutAction(): Promise<void> {
  try {
    await apiFetch("/auth/logout", { method: "POST" });
  } catch {
    // backend tidak terjangkau: cookie tetap dihapus di bawah
  }
  (await cookies()).delete(SESSION_COOKIE);
  redirect("/admin/login");
}

// Mencabut satu sesi milik sendiri
export async function revokeSessionAction(sessionId: unknown) {
  const auth = await checkPermission("akun");
  if ("error" in auth) return auth;
  if (typeof sessionId !== "string") return { ok: false as const, error: "NOT_FOUND" as const };

  const res = await apiFetch(`/auth/sessions/${encodeURIComponent(sessionId)}`, { method: "DELETE" });
  if (!res.ok) return { ok: false as const, error: "NOT_FOUND" as const };

  revalidatePath("/admin/akun");
  return { ok: true as const };
}

export type ChangePasswordResult = { ok: true; message: string } | { ok: false; error: string };

// Ganti password sendiri (POST /auth/change-password). Sesi lain dicabut backend, sesi ini tetap aktif.
export async function changePasswordAction(currentPassword: unknown, newPassword: unknown): Promise<ChangePasswordResult> {
  const auth = await checkPermission("akun");
  if ("error" in auth) return auth;
  if (
    typeof currentPassword !== "string" ||
    currentPassword.length === 0 ||
    typeof newPassword !== "string" ||
    validatePassword(newPassword) !== null
  ) {
    return { ok: false, error: "VALIDATION" };
  }

  const res = await apiJson("/auth/change-password", {
    method: "POST",
    body: JSON.stringify({ currentPassword, newPassword }),
  });
  if (!("data" in res)) return { ok: false, error: res.code === "BACKEND_UNREACHABLE" ? "BACKEND_UNREACHABLE" : res.code };

  revalidatePath("/admin/akun");
  return { ok: true, message: "Password diganti. Sesi di perangkat lain sudah dicabut." };
}

// Keluar dari semua perangkat lain
export async function revokeOtherSessionsAction() {
  const auth = await checkPermission("akun");
  if ("error" in auth) return auth;

  const res = await apiFetch("/auth/sessions/revoke-others", { method: "POST" });
  const data = res.ok ? await res.json() : { count: 0 };

  revalidatePath("/admin/akun");
  return { ok: true as const, count: data.count as number };
}