"use server";

import { revalidatePath } from "next/cache";

import { checkPermission } from "@/repositories/admin-repository";
import { apiFetch } from "@/repositories/api-server";

// Server Action untuk menghapus ulasan. Hanya admin (izin "ulasan"); backend juga mengecek ulang.

export type HapusUlasanResult =
  | { ok: true }
  | { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" | "INVALID" | "NOT_FOUND" };

export async function hapusUlasan(id: unknown): Promise<HapusUlasanResult> {
  const auth = await checkPermission("ulasan");
  if ("error" in auth) return auth;
  if (typeof id !== "string" || !id) return { ok: false, error: "INVALID" };

  const res = await apiFetch(`/admin/reviews/${encodeURIComponent(id)}`, { method: "DELETE" });
  if (!res.ok) {
    if (res.status === 401) return { ok: false, error: "UNAUTHORIZED" };
    if (res.status === 403) return { ok: false, error: "FORBIDDEN" };
    if (res.status === 404) return { ok: false, error: "NOT_FOUND" };
    return { ok: false, error: "INVALID" };
  }

  revalidatePath("/admin/ulasan");
  revalidatePath("/admin");
  return { ok: true };
}
