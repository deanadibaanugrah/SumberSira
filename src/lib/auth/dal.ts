import "server-only";

import { forbidden, redirect } from "next/navigation";
import { cache } from "react";

import { apiFetch } from "@/lib/server/api";
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