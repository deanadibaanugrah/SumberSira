"use server";

import { revalidatePath } from "next/cache";

import { checkPermission } from "@/repositories/admin-repository";
import { apiFetch } from "@/repositories/api-server";

// Server Action untuk moderasi galeri (setujui, tolak, hapus). Hanya admin (izin "galeri");
// backend juga mengecek ulang sesi dan peran.

export type GaleriActionResult =
  | { ok: true }
  | { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" | "INVALID" | "NOT_FOUND" };

function gagalDari(status: number): GaleriActionResult {
  if (status === 401) return { ok: false, error: "UNAUTHORIZED" };
  if (status === 403) return { ok: false, error: "FORBIDDEN" };
  if (status === 404) return { ok: false, error: "NOT_FOUND" };
  return { ok: false, error: "INVALID" };
}

// Setujui atau tolak satu foto (PATCH /admin/gallery/:id).
export async function setStatusGaleri(id: unknown, status: unknown): Promise<GaleriActionResult> {
  const auth = await checkPermission("galeri");
  if ("error" in auth) return auth;
  if (typeof id !== "string" || !id) return { ok: false, error: "INVALID" };
  if (status !== "approved" && status !== "rejected") return { ok: false, error: "INVALID" };

  const res = await apiFetch(`/admin/gallery/${encodeURIComponent(id)}`, {
    method: "PATCH",
    body: JSON.stringify({ status }),
  });
  if (!res.ok) return gagalDari(res.status);

  revalidatePath("/admin/galeri");
  return { ok: true };
}

// Hapus satu foto beserta berkasnya (DELETE /admin/gallery/:id).
export async function hapusFotoGaleri(id: unknown): Promise<GaleriActionResult> {
  const auth = await checkPermission("galeri");
  if ("error" in auth) return auth;
  if (typeof id !== "string" || !id) return { ok: false, error: "INVALID" };

  const res = await apiFetch(`/admin/gallery/${encodeURIComponent(id)}`, { method: "DELETE" });
  if (!res.ok) return gagalDari(res.status);

  revalidatePath("/admin/galeri");
  return { ok: true };
}
