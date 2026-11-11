import { apiFetch } from "@/lib/server/api";

// GET /api/crowd: Live Crowd publik (tanpa login), dipakai widget di halaman login.
// Isinya hanya angka ringkas: jumlah orang di dalam, persen kapasitas, dan label. Tanpa data pengunjung.
export async function GET() {
  try {
    const res = await apiFetch("/crowd");
    if (!res.ok) return Response.json({ error: "UPSTREAM" }, { status: 502 });
    const c = await res.json();
    return Response.json(
      { inside: c.inside, percent: c.percent, label: c.label, waiting: c.waiting, out: c.out, sold: c.sold, capacity: c.capacity },
      { headers: { "Cache-Control": "no-store" } },
    );
  } catch {
    return Response.json({ error: "BACKEND_UNREACHABLE" }, { status: 502 });
  }
}
