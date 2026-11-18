"use server";

import { revalidatePath } from "next/cache";

import { checkPermission, type AdminStaff } from "@/lib/auth/dal";
import { apiJson } from "@/lib/server/api";
import { validatePassword } from "@/lib/validation/password";

// Server Action untuk Akun Petugas. Hanya admin (izin "staff"); backend mengecek ulang sesi dan peran.
// Menonaktifkan akun atau mengatur ulang password mencabut semua sesi akun itu di backend.

export type StaffActionResult =
  | { ok: true; items: AdminStaff[] }
  | { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" | "INVALID" | "NOT_FOUND" | "DUPLICATE" | "INVALID_STATE" | "BACKEND_UNREACHABLE" };

// Kode galat backend yang diteruskan apa adanya; sisanya dianggap isian tidak valid.
const KODE = new Set(["DUPLICATE", "INVALID_STATE", "NOT_FOUND", "BACKEND_UNREACHABLE"]);

function gagal(code: string, status: number): StaffActionResult {
  if (KODE.has(code)) return { ok: false, error: code as "DUPLICATE" | "INVALID_STATE" | "NOT_FOUND" | "BACKEND_UNREACHABLE" };
  if (status === 401) return { ok: false, error: "UNAUTHORIZED" };
  if (status === 403) return { ok: false, error: "FORBIDDEN" };
  return { ok: false, error: "INVALID" };
}

async function fetchStaff(): Promise<AdminStaff[]> {
  const res = await apiJson<AdminStaff[]>("/admin/staff");
  return "data" in res ? res.data : [];
}

// Password mengikuti aturan backend: 8–72 karakter, ada huruf besar, huruf kecil, dan angka.
const passwordValid = (v: unknown): v is string => typeof v === "string" && validatePassword(v) === null;
const namaValid = (v: unknown): v is string => typeof v === "string" && v.trim().length >= 1 && v.trim().length <= 60;

// Tambah akun baru (tanpa id) atau ubah nama/peran/status (dengan id).
export async function simpanStaff(raw: unknown): Promise<StaffActionResult> {
  const auth = await checkPermission("staff");
  if ("error" in auth) return auth;

  const input = (raw ?? {}) as Record<string, unknown>;
  const id = typeof input.id === "string" && input.id ? input.id : null;

  if (id) {
    // PATCH boleh sebagian, tapi minimal satu field harus berubah (backend menolak body kosong).
    const body: Record<string, unknown> = {};
    if (input.name !== undefined) {
      if (!namaValid(input.name)) return { ok: false, error: "INVALID" };
      body.name = input.name.trim();
    }
    if (input.role !== undefined) {
      if (input.role !== "admin" && input.role !== "petugas") return { ok: false, error: "INVALID" };
      body.role = input.role;
    }
    if (input.active !== undefined) {
      if (typeof input.active !== "boolean") return { ok: false, error: "INVALID" };
      body.active = input.active;
    }
    if (Object.keys(body).length === 0) return { ok: false, error: "INVALID" };

    const res = await apiJson<AdminStaff>(`/admin/staff/${encodeURIComponent(id)}`, {
      method: "PATCH",
      body: JSON.stringify(body),
    });
    if (!("data" in res)) return gagal(res.code, res.status);
  } else {
    const name = input.name;
    const email = typeof input.email === "string" ? input.email.trim().toLowerCase() : "";
    const role = input.role;
    if (!namaValid(name) || !email.includes("@") || (role !== "admin" && role !== "petugas") || !passwordValid(input.password)) {
      return { ok: false, error: "INVALID" };
    }

    const res = await apiJson<AdminStaff>("/admin/staff", {
      method: "POST",
      body: JSON.stringify({ name: name.trim(), email, role, password: input.password }),
    });
    if (!("data" in res)) return gagal(res.code, res.status);
  }

  revalidatePath("/admin/staff");
  return { ok: true, items: await fetchStaff() };
}

// Atur ulang password akun lain (POST /admin/staff/:id/reset-password). Semua sesi akun itu dicabut.
export async function resetPasswordStaff(id: unknown, password: unknown): Promise<StaffActionResult> {
  const auth = await checkPermission("staff");
  if ("error" in auth) return auth;
  if (typeof id !== "string" || !id || !passwordValid(password)) return { ok: false, error: "INVALID" };

  const res = await apiJson(`/admin/staff/${encodeURIComponent(id)}/reset-password`, {
    method: "POST",
    body: JSON.stringify({ password }),
  });
  if (!("data" in res)) return gagal(res.code, res.status);

  revalidatePath("/admin/staff");
  return { ok: true, items: await fetchStaff() };
}
