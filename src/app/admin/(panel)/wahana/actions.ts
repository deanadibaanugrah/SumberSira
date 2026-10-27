"use server";

import { revalidatePath } from "next/cache";

import { checkPermission } from "@/lib/auth/dal";
import { deleteWahana, listWahana, parseWahanaInput, upsertWahana, type WahanaItem } from "@/lib/server/wahana-store";

// Server Action khusus admin untuk Wahana & Harga.
// Server Action bisa dipanggil lewat POST langsung (tanpa membuka halamannya), jadi setiap action
// mengecek ulang sendiri: 1. autentikasi, 2. otorisasi (peran), 3. validasi input, 4. ubah data, 5. revalidasi.
// Penolakan dikembalikan sebagai error bertipe (tidak melempar error).

export type WahanaActionResult =
  | { ok: true; items: WahanaItem[] }
  | { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" | "INVALID" | "NOT_FOUND" };

// Tambah atau edit wahana. Hanya peran dengan izin "wahana:ubah" (admin).
export async function simpanWahana(raw: unknown): Promise<WahanaActionResult> {
  const auth = await checkPermission("wahana:ubah");
  if ("error" in auth) return auth;
  const input = parseWahanaInput(raw);
  if (!input) return { ok: false, error: "INVALID" };
  if (!upsertWahana(input)) return { ok: false, error: "NOT_FOUND" };
  revalidatePath("/admin/wahana");
  return { ok: true, items: listWahana() };
}

// Hapus wahana. Hanya peran dengan izin "wahana:ubah" (admin).
export async function hapusWahana(id: unknown): Promise<WahanaActionResult> {
  const auth = await checkPermission("wahana:ubah");
  if ("error" in auth) return auth;
  if (typeof id !== "string" || !deleteWahana(id)) return { ok: false, error: "NOT_FOUND" };
  revalidatePath("/admin/wahana");
  return { ok: true, items: listWahana() };
}
