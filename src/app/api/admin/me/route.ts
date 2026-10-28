import { getOptionalAdmin } from "@/lib/auth/dal";

// GET /api/admin/me: data admin yang sedang login (contoh Route Handler yang dilindungi).
// Bisa dipanggil dari browser (cookie sesi) atau dari Postman dengan header "Authorization: Bearer <token>"
// hasil POST /api/auth/login. Route Handler tidak dilewati proxy.ts, jadi sesi dicek sendiri di sini
// dan dibalas dengan status code yang benar: 401 bila belum login atau token tidak berlaku.
export async function GET() {
  const admin = await getOptionalAdmin();
  if (!admin) return Response.json({ ok: false, error: "UNAUTHORIZED", message: "Token tidak ada atau sudah tidak berlaku." }, { status: 401 });
  const { id, name, email, role, roleLabel } = admin;
  return Response.json({ ok: true, admin: { id, name, email, role, roleLabel } }, { headers: { "Cache-Control": "no-store" } });
}
