import { deleteCurrentSession, readSession } from "@/lib/auth/session";

// POST /api/auth/logout: mencabut token yang dikirim di header "Authorization: Bearer <token>" (atau cookie sesi).
// Setelah ini token yang sama ditolak (401) oleh API admin.
export async function POST() {
  const session = await readSession();
  if (!session) return Response.json({ ok: false, error: "UNAUTHORIZED", message: "Token tidak ada atau sudah tidak berlaku." }, { status: 401 });
  await deleteCurrentSession();
  return Response.json({ ok: true, message: "Berhasil keluar. Token ini sudah tidak bisa dipakai." });
}
