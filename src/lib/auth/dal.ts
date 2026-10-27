import "server-only";

import { forbidden, redirect } from "next/navigation";
import { cache } from "react";

import { listWahana } from "@/lib/server/wahana-store";

import { ROLE_LABEL, can, type Permission, type Role } from "./roles";
import { listSessionsOf, readSession } from "./session";
import { findUserById } from "./users";

// Data Access Layer (DAL): satu pintu untuk mengecek sesi dan peran sebelum data dibaca atau diubah.
// Halaman, Server Action, dan Route Handler admin semuanya memanggil fungsi di sini.
// proxy.ts hanya pengalihan cepat; batas keamanan yang sebenarnya ada di file ini.

// Data admin yang boleh dikirim ke tampilan (DTO). Hash password tidak pernah ikut.
export type AdminProfile = {
  id: string;
  name: string;
  email: string;
  role: Role;
  roleLabel: string;
  sessionId: string;
};

// Hasil bertipe untuk Server Action: tidak melempar error, cukup kembalikan alasan penolakan.
export type AuthFailure = { ok: false; error: "UNAUTHORIZED" | "FORBIDDEN" };

// Admin yang sedang login, atau null. cache() = sesi hanya dicari sekali per request.
export const getOptionalAdmin = cache(async (): Promise<AdminProfile | null> => {
  const session = await readSession();
  if (!session) return null;
  const user = findUserById(session.userId);
  if (!user) return null;
  return { id: user.id, name: user.name, email: user.email, role: user.role, roleLabel: ROLE_LABEL[user.role], sessionId: session.publicId };
});

// Autentikasi untuk halaman: belum login = dialihkan ke halaman login.
export async function getCurrentAdmin(): Promise<AdminProfile> {
  const admin = await getOptionalAdmin();
  if (!admin) redirect("/admin/login");
  return admin;
}

// Autentikasi lalu otorisasi untuk halaman: sudah login tapi perannya tidak punya izin = halaman 403.
export async function requirePermission(permission: Permission): Promise<AdminProfile> {
  const admin = await getCurrentAdmin();
  if (!can(admin.role, permission)) forbidden();
  return admin;
}

// Versi untuk Server Action: mengembalikan UNAUTHORIZED (belum login) atau FORBIDDEN (peran tidak cukup).
export async function checkPermission(permission: Permission): Promise<{ ok: true; admin: AdminProfile } | AuthFailure> {
  const admin = await getOptionalAdmin();
  if (!admin) return { ok: false, error: "UNAUTHORIZED" };
  if (!can(admin.role, permission)) return { ok: false, error: "FORBIDDEN" };
  return { ok: true, admin };
}

// Daftar wahana untuk halaman Wahana & Harga. Dibaca lewat DAL supaya izin "wahana:lihat" selalu dicek.
export async function getWahanaForAdmin() {
  const admin = await requirePermission("wahana:lihat");
  return { items: listWahana(), canEdit: can(admin.role, "wahana:ubah") };
}

// Sesi aktif milik admin yang sedang login saja (bukan milik admin lain).
export async function getMySessions() {
  const admin = await requirePermission("akun");
  return listSessionsOf(admin.id).map((s) => ({
    id: s.publicId,
    device: s.device,
    createdAt: s.createdAt,
    expiresAt: s.expiresAt,
    current: s.publicId === admin.sessionId,
  }));
}
