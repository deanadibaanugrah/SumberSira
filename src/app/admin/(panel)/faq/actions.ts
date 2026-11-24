"use server";

import { revalidatePath } from "next/cache";

import { checkPermission } from "@/repositories/admin-repository";
import { apiJson } from "@/repositories/api-server";

// Server Action untuk Chatbot & FAQ. Hanya admin (izin "faq"); backend juga mengecek ulang sesi dan peran.
// Backend hanya punya CRUD FAQ dan daftar pertanyaan belum terjawab, jadi "menjawab" pertanyaan dilakukan
// dengan membuat FAQ baru lalu menghapus pertanyaan itu dari daftar (pilihan ini dilaporkan di laporan fase).

export type FaqActionResult = { ok: true } | { ok: false; error: string };

export type FaqInput = {
  id?: string;
  keys?: unknown;
  answer?: unknown;
  sortOrder?: unknown;
  active?: unknown;
};

// Tambah (tanpa id) atau ubah satu FAQ (PATCH /admin/faq/:id).
export async function simpanFaq(input: FaqInput): Promise<FaqActionResult> {
  const auth = await checkPermission("faq");
  if ("error" in auth) return auth;

  // keys minimal satu kata kunci; kata kosong dan duplikat dibuang.
  const keys = Array.isArray(input.keys)
    ? [...new Set(input.keys.filter((k): k is string => typeof k === "string").map((k) => k.trim()).filter(Boolean))]
    : [];
  const answer = typeof input.answer === "string" ? input.answer.trim() : "";
  if (keys.length === 0 || !answer) return { ok: false, error: "VALIDATION" };

  const body: Record<string, unknown> = { keys, answer, active: input.active !== false };
  if (typeof input.sortOrder === "number" && Number.isFinite(input.sortOrder)) body.sortOrder = input.sortOrder;

  const id = typeof input.id === "string" && input.id ? input.id : null;
  const res = await apiJson(id ? `/admin/faq/${encodeURIComponent(id)}` : "/admin/faq", {
    method: id ? "PATCH" : "POST",
    body: JSON.stringify(body),
  });
  if (!("data" in res)) return { ok: false, error: res.code };

  revalidatePath("/admin/faq");
  return { ok: true };
}

// Hapus satu FAQ (DELETE /admin/faq/:id).
export async function hapusFaq(id: unknown): Promise<FaqActionResult> {
  const auth = await checkPermission("faq");
  if ("error" in auth) return auth;
  if (typeof id !== "string" || !id) return { ok: false, error: "VALIDATION" };

  const res = await apiJson(`/admin/faq/${encodeURIComponent(id)}`, { method: "DELETE" });
  if (!("data" in res)) return { ok: false, error: res.code };

  revalidatePath("/admin/faq");
  return { ok: true };
}

// Tandai selesai satu pertanyaan belum terjawab (DELETE /admin/faq/unanswered/:id).
export async function hapusPertanyaan(id: unknown): Promise<FaqActionResult> {
  const auth = await checkPermission("faq");
  if ("error" in auth) return auth;
  if (typeof id !== "string" || !id) return { ok: false, error: "VALIDATION" };

  const res = await apiJson(`/admin/faq/unanswered/${encodeURIComponent(id)}`, { method: "DELETE" });
  if (!("data" in res)) return { ok: false, error: res.code };

  revalidatePath("/admin/faq");
  return { ok: true };
}

export type TombolResult = { ok: true; questions: string[] } | { ok: false; error: string };

// Simpan tombol jawaban cepat yang tampil di kotak chat aplikasi (PUT /admin/faq/quick-questions, 1 sampai 6 tombol).
export async function simpanTombolCepat(questions: unknown): Promise<TombolResult> {
  const auth = await checkPermission("faq");
  if ("error" in auth) return { ok: false, error: auth.error };
  if (!Array.isArray(questions)) return { ok: false, error: "VALIDATION" };
  const bersih = questions.filter((q): q is string => typeof q === "string").map((q) => q.trim()).filter(Boolean);
  if (bersih.length === 0 || bersih.length > 6) return { ok: false, error: "VALIDATION" };

  const res = await apiJson<{ questions: string[] }>("/admin/faq/quick-questions", {
    method: "PUT",
    body: JSON.stringify({ questions: bersih }),
  });
  if (!("data" in res)) return { ok: false, error: res.code };

  revalidatePath("/admin/faq");
  return { ok: true, questions: res.data.questions };
}
