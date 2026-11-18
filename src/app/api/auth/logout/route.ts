import { cookies } from "next/headers";

import { SESSION_COOKIE } from "@/lib/auth/constants";
import { apiFetch } from "@/lib/server/api";

// POST /api/auth/logout: mencabut token yang dikirim di header "Authorization: Bearer <token>" (atau cookie sesi).
// Pencabutan dilakukan di backend (POST /auth/logout), jadi token yang sama langsung ditolak (401) oleh API admin.
export async function POST() {
  let res: Response;
  try {
    res = await apiFetch("/auth/logout", { method: "POST" });
  } catch {
    return Response.json({ ok: false, error: "BACKEND_UNAVAILABLE", message: "Server tidak dapat dihubungi. Coba lagi sebentar lagi." }, { status: 502 });
  }
  if (res.status === 401) return Response.json({ ok: false, error: "UNAUTHORIZED", message: "Token tidak ada atau sudah tidak berlaku." }, { status: 401 });
  if (!res.ok) return Response.json({ ok: false, error: "BACKEND_UNAVAILABLE", message: "Logout gagal di server. Coba lagi sebentar lagi." }, { status: 502 });

  (await cookies()).delete(SESSION_COOKIE);
  return Response.json({ ok: true, message: "Berhasil keluar. Token ini sudah tidak bisa dipakai." });
}
