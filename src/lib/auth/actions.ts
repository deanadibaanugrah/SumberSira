"use server";

import { revalidatePath } from "next/cache";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import { BACKEND_COOKIE, apiFetch } from "@/lib/server/api";

import { SESSION_COOKIE } from "./constants";
import { checkPermission } from "./dal";
import { safeAdminPath } from "./redirect";

export type LoginState = { error?: string; email?: string } | undefined;

const REMEMBER_MS = 7 * 24 * 60 * 60 * 1000;

// Login: Next.js memanggil backend, lalu menyimpan token sesi dari backend ke cookie HttpOnly
export async function loginAction(_prev: LoginState, formData: FormData): Promise<LoginState> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");
  const remember = formData.get("remember") === "on";
  const next = safeAdminPath(formData.get("next"));

  if (!email || !password) return { error: "Email dan password wajib diisi.", email };

  let res: Response;
  try {
    res = await apiFetch("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password, remember }),
    });
  } catch {
    return { error: "Server tidak dapat dihubungi. Coba lagi sebentar lagi.", email };
  }

  if (res.status === 401) return { error: "Email atau password salah.", email };
  if (!res.ok) return { error: "Login gagal. Periksa isian lalu coba lagi.", email };

  // Ambil token dari header Set-Cookie milik backend
  const raw = res.headers.getSetCookie().find((c) => c.startsWith(`${BACKEND_COOKIE}=`));
  const token = raw?.split(";")[0].slice(BACKEND_COOKIE.length + 1);
  if (!token) return { error: "Login gagal. Coba lagi.", email };

  (await cookies()).set(SESSION_COOKIE, token, {
    httpOnly: true,
    secure: true,
    sameSite: "lax",
    path: "/",
    ...(remember ? { expires: new Date(Date.now() + REMEMBER_MS) } : {}),
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

// Keluar dari semua perangkat lain
export async function revokeOtherSessionsAction() {
  const auth = await checkPermission("akun");
  if ("error" in auth) return auth;

  const res = await apiFetch("/auth/sessions/revoke-others", { method: "POST" });
  const data = res.ok ? await res.json() : { count: 0 };

  revalidatePath("/admin/akun");
  return { ok: true as const, count: data.count as number };
}