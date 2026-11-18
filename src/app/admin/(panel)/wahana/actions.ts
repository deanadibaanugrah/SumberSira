"use server";

import { revalidatePath } from "next/cache";

import { checkPermission, type AdminPricing } from "@/lib/auth/dal";
import { apiFetch, apiJson } from "@/lib/server/api";
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

export type PricingActionResult =
  | { ok: true; pricing: AdminPricing }
  | { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" | "INVALID" | "BACKEND_UNREACHABLE" };

// Bilangan bulat dalam rentang; NaN = tidak valid.
function bulat(value: unknown, min: number, max: number): number {
  if (typeof value !== "number" || !Number.isInteger(value)) return NaN;
  return value < min || value > max ? NaN : value;
}

// Simpan harga tiket, kapasitas, dan tarif parkir (PUT /admin/pricing). Hanya admin.
// Rentang sama dengan backend: tiket 500..1.000.000, kapasitas 1..100.000, parkir 0..1.000.000.
export async function simpanPricing(raw: unknown): Promise<PricingActionResult> {
  const auth = await checkPermission("wahana:ubah");
  if ("error" in auth) return auth;

  const input = (raw ?? {}) as Record<string, unknown>;
  const parking = (input.parking ?? {}) as Record<string, unknown>;
  const ticketPricePerPerson = bulat(input.ticketPricePerPerson, 500, 1_000_000);
  const capacity = bulat(input.capacity, 1, 100_000);
  const motor = bulat(parking.motor, 0, 1_000_000);
  const mobil = bulat(parking.mobil, 0, 1_000_000);
  const bus = bulat(parking.bus, 0, 1_000_000);
  // "Jalan kaki" selalu 0 menurut backend.
  if ([ticketPricePerPerson, capacity, motor, mobil, bus].some(Number.isNaN)) {
    return { ok: false, error: "INVALID" };
  }

  const res = await apiJson<AdminPricing>("/admin/pricing", {
    method: "PUT",
    body: JSON.stringify({
      ticketPricePerPerson,
      capacity,
      parking: { none: 0, motor, mobil, bus },
    }),
  });
  if (!("data" in res)) {
    if (res.code === "BACKEND_UNREACHABLE") return { ok: false, error: "BACKEND_UNREACHABLE" };
    if (res.status === 401) return { ok: false, error: "UNAUTHORIZED" };
    if (res.status === 403) return { ok: false, error: "FORBIDDEN" };
    return { ok: false, error: "INVALID" };
  }

  revalidatePath("/admin/wahana");
  return { ok: true, pricing: res.data };
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