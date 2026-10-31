"use server";

import { revalidatePath } from "next/cache";

import { checkPermission } from "@/lib/auth/dal";
import { apiFetch } from "@/lib/server/api";
import { parseWahanaInput, type WahanaItem } from "@/lib/server/wahana-store";

// Server Action khusus admin untuk Wahana & Harga.
// Setiap action tetap mengecek peran di sini, dan backend mengecek ulang (batas keamanan sebenarnya ada di backend).

export type WahanaActionResult =
  | { ok: true; items: WahanaItem[] }
  | { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" | "INVALID" | "NOT_FOUND" };

function failFrom(status: number): WahanaActionResult {
  if (status === 401) return { ok: false, error: "UNAUTHORIZED" };
  if (status === 403) return { ok: false, error: "FORBIDDEN" };
  if (status === 404) return { ok: false, error: "NOT_FOUND" };
  return { ok: false, error: "INVALID" };
}

async function fetchItems(): Promise<WahanaItem[]> {
  const res = await apiFetch("/admin/rides");
  return res.ok ? await res.json() : [];
}

// Tambah atau edit wahana. Hanya peran dengan izin "wahana:ubah" (admin).
export async function simpanWahana(raw: unknown): Promise<WahanaActionResult> {
  const auth = await checkPermission("wahana:ubah");
  if ("error" in auth) return auth;

  const input = parseWahanaInput(raw);
  if (!input) return { ok: false, error: "INVALID" };

  const { id, ...fields } = input;
  const res = id
    ? await apiFetch(`/admin/rides/${encodeURIComponent(id)}`, {
        method: "PATCH",
        body: JSON.stringify(fields),
      })
    : await apiFetch("/admin/rides", {
        method: "POST",
        body: JSON.stringify({ ...fields, icon: fields.category === "Sewa Alat" ? "ring" : "carousel" }),
      });

  if (!res.ok) return failFrom(res.status);

  revalidatePath("/admin/wahana");
  return { ok: true, items: await fetchItems() };
}

// Hapus wahana. Hanya peran dengan izin "wahana:ubah" (admin).
export async function hapusWahana(id: unknown): Promise<WahanaActionResult> {
  const auth = await checkPermission("wahana:ubah");
  if ("error" in auth) return auth;
  if (typeof id !== "string") return { ok: false, error: "NOT_FOUND" };

  const res = await apiFetch(`/admin/rides/${encodeURIComponent(id)}`, { method: "DELETE" });
  if (!res.ok) return failFrom(res.status);

  revalidatePath("/admin/wahana");
  return { ok: true, items: await fetchItems() };
}