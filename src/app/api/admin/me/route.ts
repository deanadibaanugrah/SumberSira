import { getOptionalAdmin } from "@/lib/auth/dal";

// GET /api/admin/me: data admin yang sedang login (contoh Route Handler yang dilindungi).
// Route Handler tidak dilewati proxy.ts dan tidak punya perlindungan otomatis, jadi sesi dicek sendiri di sini
// dan dibalas dengan status code yang benar: 401 bila belum login.
export async function GET() {
  const admin = await getOptionalAdmin();
  if (!admin) return Response.json({ ok: false, error: "UNAUTHORIZED" }, { status: 401 });
  const { id, name, email, role, roleLabel } = admin;
  return Response.json({ ok: true, admin: { id, name, email, role, roleLabel } }, { headers: { "Cache-Control": "no-store" } });
}
