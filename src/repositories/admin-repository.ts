import "server-only";

import { forbidden, redirect } from "next/navigation";
import { cache } from "react";

import { apiFetch, apiJson } from "@/repositories/api-server";
import type { WahanaItem } from "@/models/wahana";

import { describeDevice } from "../lib/auth/device";
import { ROLE_LABEL, can, type Permission, type Role } from "../lib/auth/roles";
import type { AdminProfile, AuthFailure, AdminReview, AdminReviewPage, AdminGalleryPhoto, AdminGalleryPage, AdminFaq, AdminUnanswered, AdminAiStatus, AdminPricing, AdminStaff } from "@/models/admin";

// Data Access Layer (DAL): satu pintu untuk mengecek sesi dan peran.
// Sesi sekarang dicek ke backend (GET /auth/me), bukan lagi dari memori server Next.js.





// Admin yang sedang login, atau null. cache() = hanya satu panggilan ke backend per request.
export const getOptionalAdmin = cache(async (): Promise<AdminProfile | null> => {
  try {
    const res = await apiFetch("/auth/me");
    if (!res.ok) return null;
    const u = await res.json();
    return {
      id: u.id,
      name: u.name,
      email: u.email,
      role: u.role as Role,
      roleLabel: ROLE_LABEL[u.role as Role],
      sessionId: u.sessionId,
    };
  } catch {
    return null; // backend tidak terjangkau: anggap belum login
  }
});

export async function getCurrentAdmin(): Promise<AdminProfile> {
  const admin = await getOptionalAdmin();
  if (!admin) redirect("/admin/login");
  return admin;
}

export async function requirePermission(permission: Permission): Promise<AdminProfile> {
  const admin = await getCurrentAdmin();
  if (!can(admin.role, permission)) forbidden();
  return admin;
}

export async function checkPermission(permission: Permission): Promise<{ ok: true; admin: AdminProfile } | AuthFailure> {
  const admin = await getOptionalAdmin();
  if (!admin) return { ok: false, error: "UNAUTHORIZED" };
  if (!can(admin.role, permission)) return { ok: false, error: "FORBIDDEN" };
  return { ok: true, admin };
}



// Satu halaman ulasan, terbaru di atas. Galat backend dikembalikan sebagai kode agar halaman bisa
// menampilkan pesan yang jelas, bukan daftar kosong yang membingungkan.
export async function getReviewsForAdmin(page = 1, limit = 20) {
  await requirePermission("ulasan");
  const res = await apiJson<AdminReviewPage>(`/admin/reviews?page=${page}&limit=${limit}`);
  // "data" in res dipakai agar TypeScript bisa membedakan hasil berhasil dan galat (strict dimatikan).
  if ("data" in res) return { ...res.data, error: null };
  return {
    items: [] as AdminReview[],
    total: 0,
    page,
    limit,
    average: 0,
    error: res.code,
  };
}



// Satu halaman foto (pending, approved, rejected), terbaru di atas. Penyaringan status
// dilakukan di backend agar pagination dan rekap jumlah tetap akurat.
// Galat backend dikembalikan sebagai kode agar halaman bisa menampilkan pesan yang jelas.
export async function getGalleryForAdmin(
  page = 1,
  status?: "pending" | "approved" | "rejected",
  limit = 20
) {
  await requirePermission("galeri");
  const query = new URLSearchParams({ page: String(page), limit: String(limit) });
  if (status) query.set("status", status);
  const res = await apiJson<AdminGalleryPage>(`/admin/gallery?${query.toString()}`);
  if ("data" in res) return { ...res.data, error: null };
  return {
    items: [] as AdminGalleryPhoto[],
    total: 0,
    page,
    limit,
    counts: { all: 0, pending: 0, approved: 0, rejected: 0 },
    error: res.code,
  };
}





// FAQ dan pertanyaan belum terjawab untuk halaman Chatbot & FAQ (khusus admin).
// Galat backend dikembalikan sebagai kode agar halaman bisa menampilkan pesan yang jelas.
export async function getFaqForAdmin() {
  await requirePermission("faq");
  const [faq, tanya, tombol, ai] = await Promise.all([
    apiJson<AdminFaq[]>("/admin/faq"),
    apiJson<AdminUnanswered[]>("/admin/faq/unanswered"),
    apiJson<{ questions: string[] }>("/admin/faq/quick-questions"),
    apiJson<AdminAiStatus>("/admin/faq/ai-status"),
  ]);
  return {
    faqs: "data" in faq ? faq.data : [],
    unanswered: "data" in tanya ? tanya.data : [],
    // Tombol jawaban cepat dan status AI hanya pelengkap: kalau gagal dimuat, halaman FAQ tetap tampil.
    tombol: "data" in tombol ? tombol.data.questions : [],
    ai: "data" in ai ? ai.data : null,
    error: "data" in faq ? ("data" in tanya ? null : tanya.code) : faq.code,
  };
}







// Harga untuk halaman Wahana & Harga: admin dan petugas boleh melihat, hanya admin boleh mengubah.
export async function getPricingForAdmin() {
  const admin = await requirePermission("wahana:lihat");
  const res = await apiJson<AdminPricing>("/admin/pricing");
  if ("data" in res) return { pricing: res.data, canEdit: can(admin.role, "wahana:ubah"), error: null };
  return { pricing: null, canEdit: can(admin.role, "wahana:ubah"), error: res.code };
}



// Daftar semua akun. Galat dikembalikan sebagai kode agar halaman bisa menampilkan pesan yang jelas.
export async function getStaffForAdmin() {
  await requirePermission("staff");
  const res = await apiJson<AdminStaff[]>("/admin/staff");
  if ("data" in res) return { items: res.data, error: null };
  return { items: [] as AdminStaff[], error: res.code };
}

// Daftar wahana untuk halaman Wahana & Harga, diambil dari backend
export async function getWahanaForAdmin() {
  const admin = await requirePermission("wahana:lihat");
  const res = await apiFetch("/admin/rides");
  const items: WahanaItem[] = res.ok ? await res.json() : [];
  return { items, canEdit: can(admin.role, "wahana:ubah") };
}

type SessionRow = { id: string; userAgent: string | null; createdAt: string; expiresAt: string; current: boolean };

// Sesi aktif milik admin yang sedang login saja
export async function getMySessions() {
  await requirePermission("akun");
  const res = await apiFetch("/auth/sessions");
  const rows: SessionRow[] = res.ok ? await res.json() : [];
  return rows.map((s) => ({
    id: s.id,
    device: describeDevice(s.userAgent ?? ""),
    createdAt: new Date(s.createdAt).getTime(),
    expiresAt: new Date(s.expiresAt).getTime(),
    current: s.current,
  }));
}