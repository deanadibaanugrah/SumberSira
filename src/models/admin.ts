// Model: bentuk data yang dipakai View dan ViewModel.
import type { Role } from "@/lib/auth/roles";

export type AdminProfile = {
  id: string;
  name: string;
  email: string;
  role: Role;
  roleLabel: string;
  sessionId: string;
};

export type AuthFailure = { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" };

// Satu ulasan pengunjung untuk halaman Ulasan & Rating (khusus admin).
export type AdminReview = { id: string; name: string; stars: number; text: string; createdAt: string };

// Satu halaman daftar ulasan. average dihitung backend dari seluruh ulasan.
export type AdminReviewPage = {
  items: AdminReview[];
  total: number;
  page: number;
  limit: number;
  average: number;
};

// Satu foto galeri untuk halaman Galeri & Konten, termasuk status moderasinya.
export type AdminGalleryPhoto = {
  id: string;
  url: string;
  title: string;
  owner: string;
  caption?: string;
  ai: boolean;
  status: "pending" | "approved" | "rejected";
  storageKey?: string;
  reviewedAt?: string | null;
  createdAt: string;
};

// Rekap jumlah foto per status untuk kartu ringkasan (dihitung backend dari seluruh data).
export type AdminGalleryCounts = { all: number; pending: number; approved: number; rejected: number };

// Satu halaman daftar foto galeri.
export type AdminGalleryPage = {
  items: AdminGalleryPhoto[];
  total: number;
  page: number;
  limit: number;
  counts: AdminGalleryCounts;
};

// Satu FAQ pengelola. keys = kata kunci pencocokan; kata pertama dipakai sebagai judul di admin.
export type AdminFaq = { id: string; keys: string[]; answer: string; sortOrder: number; active: boolean };

// Status chatbot AI dari backend: aktif atau belum (butuh kunci di server), model, dan jatah harian.
export type AdminAiStatus = { enabled: boolean; model: string; dailyLimit: number; usedToday: number };

// Pertanyaan pengunjung yang tidak cocok dengan FAQ mana pun.
export type AdminUnanswered = { id: string; question: string; createdAt: string };



// Harga tiket, kapasitas, dan tarif parkir. Bentuk ini sama dengan yang dipakai PUT /admin/pricing.
export type AdminPricing = {
  ticketPricePerPerson: number;
  capacity: number;
  parking: { none: number; motor: number; mobil: number; bus: number };
};

// Satu akun petugas/admin untuk halaman Akun Petugas (khusus admin).
export type AdminStaff = {
  id: string;
  name: string;
  email: string;
  role: Role;
  active: boolean;
  createdAt: string;
};
