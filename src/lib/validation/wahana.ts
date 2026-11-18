import "server-only";
import type { WahanaInput } from "@/models/wahana";

// Tipe dan validasi form Wahana & Harga. Daftar wahana sendiri dibaca dari backend
// (`GET /admin/rides`); fungsi di sini hanya membersihkan isi form sebelum dikirim lewat Server Action.





const CATEGORIES = ["Wahana", "Sewa Alat"];
const STATUSES = ["Aktif", "Nonaktif"];

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
