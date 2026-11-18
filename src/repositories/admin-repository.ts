import "server-only";

import { forbidden, redirect } from "next/navigation";
import { cache } from "react";

import { apiFetch, apiJson } from "@/lib/server/api";
import type { WahanaItem } from "@/lib/server/wahana-store";

import { describeDevice } from "./device";
import { ROLE_LABEL, can, type Permission, type Role } from "./roles";

// Data Access Layer (DAL): satu pintu untuk mengecek sesi dan peran.
// Sesi sekarang dicek ke backend (GET /auth/me), bukan lagi dari memori server Next.js.

export type AdminProfile = {
  id: string;
  name: string;
  email: string;
  role: Role;
  roleLabel: string;
  sessionId: string;
};

export type AuthFailure = { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" };

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

// Satu ulasan pengunjung untuk halaman Ulasan & Rating (khusus admin).
export type AdminReview = { id: string; name: string; stars: number; text: string; createdAt: string };

// Daftar semua ulasan, terbaru di atas. Galat backend dikembalikan sebagai kode agar halaman bisa
// menampilkan pesan yang jelas, bukan daftar kosong yang membingungkan.
export async function getReviewsForAdmin() {
  await requirePermission("ulasan");
  const res = await apiJson<AdminReview[]>("/admin/reviews");
  // "data" in res dipakai agar TypeScript bisa membedakan hasil berhasil dan galat (strict dimatikan).
  if ("data" in res) return { items: res.data, error: null };
  return { items: [] as AdminReview[], error: res.code };
}

// Satu foto galeri untuk halaman Galeri & Konten, termasuk status moderasinya.
export type AdminGalleryPhoto = {
  id: string;
  url: string;
  title: string;
  owner: string;
  ai: boolean;
  status: "pending" | "approved" | "rejected";
  storageKey?: string;
  reviewedAt?: string | null;
  createdAt: string;
};

// Semua foto (pending, approved, rejected), terbaru di atas. Penyaringan status dilakukan di halaman.
// Galat backend dikembalikan sebagai kode agar halaman bisa menampilkan pesan yang jelas.
export async function getGalleryForAdmin() {
  await requirePermission("galeri");
  const res = await apiJson<AdminGalleryPhoto[]>("/admin/gallery");
  if ("data" in res) return { items: res.data, error: null };
  return { items: [] as AdminGalleryPhoto[], error: res.code };
}

// Satu FAQ pengelola. keys = kata kunci pencocokan; kata pertama dipakai sebagai judul di admin.
export type AdminFaq = { id: string; keys: string[]; answer: string; sortOrder: number; active: boolean };

// Pertanyaan pengunjung yang tidak cocok dengan FAQ mana pun.
export type AdminUnanswered = { id: string; question: string; createdAt: string };

// FAQ dan pertanyaan belum terjawab untuk halaman Chatbot & FAQ (khusus admin).
// Galat backend dikembalikan sebagai kode agar halaman bisa menampilkan pesan yang jelas.
export async function getFaqForAdmin() {
  await requirePermission("faq");
  const [faq, tanya] = await Promise.all([
    apiJson<AdminFaq[]>("/admin/faq"),
    apiJson<AdminUnanswered[]>("/admin/faq/unanswered"),
  ]);
  return {
    faqs: "data" in faq ? faq.data : [],
    unanswered: "data" in tanya ? tanya.data : [],
    error: "data" in faq ? ("data" in tanya ? null : tanya.code) : faq.code,
  };
}

// Ringkasan AI Insight dari backend: rating ulasan, keramaian saat ini, jam terpadat, dan saran aturan.
export type AdminInsight = {
  rating: number;
  reviewCount: number;
  distribution: Record<"1" | "2" | "3" | "4" | "5", number>;
  crowd: { inside: number; percent: number; label: string };
  peakHour: string;
  suggestions: string[];
};

// Analisis admin (khusus admin). Galat dikembalikan sebagai kode agar halaman bisa memberi pesan jelas.
export async function getInsightForAdmin() {
  await requirePermission("insight");
  const res = await apiJson<AdminInsight>("/admin/insight");
  if ("data" in res) return { data: res.data, error: null };
  return { data: null, error: res.code };
}

// Harga tiket, kapasitas, dan tarif parkir. Bentuk ini sama dengan yang dipakai PUT /admin/pricing.
export type AdminPricing = {
  ticketPricePerPerson: number;
  capacity: number;
  parking: { none: number; motor: number; mobil: number; bus: number };
};

// Harga untuk halaman Wahana & Harga: admin dan petugas boleh melihat, hanya admin boleh mengubah.
export async function getPricingForAdmin() {
  const admin = await requirePermission("wahana:lihat");
  const res = await apiJson<AdminPricing>("/admin/pricing");
  if ("data" in res) return { pricing: res.data, canEdit: can(admin.role, "wahana:ubah"), error: null };
  return { pricing: null, canEdit: can(admin.role, "wahana:ubah"), error: res.code };
}

// Satu akun petugas/admin untuk halaman Akun Petugas (khusus admin).
export type AdminStaff = {
  id: string;
  name: string;
  email: string;
  role: Role;
  active: boolean;
  createdAt: string;
};

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