import "server-only";

import { WAHANA } from "@/data/wahana";

// Daftar wahana yang diubah dari panel admin, disimpan di memori server (tahap tanpa database).
// Isi awalnya katalog src/data/wahana.ts. Tahap backend: ganti dengan tabel wahana di database.

export type WahanaItem = {
  id: string;
  name: string;
  category: string;
  price: number;
  unit: string;
  icon: string;
  status: string;
};

export type WahanaInput = { id?: string; name: string; category: string; price: number; unit: string; status: string };

const CATEGORIES = ["Wahana", "Sewa Alat"];
const STATUSES = ["Aktif", "Nonaktif"];

const globalStore = globalThis as unknown as { __sumberSiraWahana?: WahanaItem[] };

function items(): WahanaItem[] {
  globalStore.__sumberSiraWahana ??= WAHANA.map((w) => ({ ...w }));
  return globalStore.__sumberSiraWahana;
}

export function listWahana(): WahanaItem[] {
  return items().map((w) => ({ ...w }));
}

// Validasi isi form di server (data dari browser tidak boleh langsung dipercaya).
export function parseWahanaInput(raw: unknown): WahanaInput | null {
  if (!raw || typeof raw !== "object") return null;
  const r = raw as Record<string, unknown>;
  const name = typeof r.name === "string" ? r.name.trim() : "";
  const unit = typeof r.unit === "string" ? r.unit.trim() : "";
  const price = Number(r.price);
  if (!name || name.length > 60 || unit.length > 30) return null;
  if (!Number.isInteger(price) || price < 500 || price > 1_000_000) return null;
  if (typeof r.category !== "string" || !CATEGORIES.includes(r.category)) return null;
  if (typeof r.status !== "string" || !STATUSES.includes(r.status)) return null;
  const id = typeof r.id === "string" && r.id ? r.id : undefined;
  return { id, name, unit, price, category: r.category, status: r.status };
}

// Tambah item baru, atau ubah item lama bila id-nya ada. Mengembalikan false bila id tidak ditemukan.
export function upsertWahana(input: WahanaInput): boolean {
  const all = items();
  if (input.id) {
    const index = all.findIndex((w) => w.id === input.id);
    if (index < 0) return false;
    all[index] = { ...all[index], ...input, id: input.id };
    return true;
  }
  all.push({ ...input, id: `wahana-${Date.now()}`, icon: input.category === "Sewa Alat" ? "ring" : "carousel" });
  return true;
}

export function deleteWahana(id: string): boolean {
  const all = items();
  const index = all.findIndex((w) => w.id === id);
  if (index < 0) return false;
  all.splice(index, 1);
  return true;
}
