import { attemptLogin } from "@/lib/auth/login";
import { ROLE_LABEL } from "@/lib/auth/roles";
import { issueSession } from "@/lib/auth/session";

// POST /api/auth/login: login admin lewat API untuk klien selain browser (mis. Postman).
// Body JSON: { "email": "...", "password": "...", "remember": false }.
// Berhasil: 200 + token sesi. Token dipakai di header "Authorization: Bearer <token>" untuk API admin, mis. GET /api/admin/me.
// Gagal: 400 isian tidak valid (termasuk format email), 401 email/password salah, 415 body bukan JSON, 429 terlalu banyak percobaan.
// Validasi dan batas percobaan sama persis dengan form login karena keduanya memanggil attemptLogin.
export async function POST(req: Request) {
  if (!req.headers.get("content-type")?.includes("application/json")) {
    return Response.json({ ok: false, error: "UNSUPPORTED_MEDIA_TYPE", message: "Kirim body sebagai JSON (Content-Type: application/json)." }, { status: 415 });
  }

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return Response.json({ ok: false, error: "INVALID_JSON", message: "Body JSON tidak bisa dibaca." }, { status: 400 });
  }

  const { email, password, remember } = (body ?? {}) as Record<string, unknown>;
  if (typeof email !== "string" || typeof password !== "string") {
    return Response.json({ ok: false, error: "INVALID_INPUT", message: "Isi email dan password terlebih dahulu." }, { status: 400 });
  }

  const result = await attemptLogin(email, password);
  if ("error" in result) {
    const headers = result.retryAfter ? { "Retry-After": String(result.retryAfter) } : undefined;
    return Response.json({ ok: false, error: result.error, message: result.message }, { status: result.status, headers });
  }

  const { token, expiresAt } = await issueSession(result.user.id, remember === true);
  const { id, name, role } = result.user;
  return Response.json(
    {
      ok: true,
      tokenType: "Bearer",
      token,
      expiresAt: new Date(expiresAt).toISOString(),
      admin: { id, name, email: result.user.email, role, roleLabel: ROLE_LABEL[role] },
    },
    { headers: { "Cache-Control": "no-store" } },
  );
}
