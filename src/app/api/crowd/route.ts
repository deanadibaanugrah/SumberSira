import { apiFetch } from "@/lib/server/api";

// GET /api/crowd: Live Crowd publik (tanpa login), dipakai widget di halaman login dan dashboard admin.
// Bentuk asli backend: jumlah orang di dalam, persen kapasitas, label, dan prakiraan puncak per jam.
// Tanpa data pengunjung.
export async function GET() {
  try {
    const res = await apiFetch("/crowd");
    if (!res.ok) return Response.json({ error: "UPSTREAM" }, { status: 502 });
    const c = await res.json();
    return Response.json(
      { inside: c.inside, percent: c.percent, label: c.label, capacity: c.capacity, updatedAt: c.updatedAt, forecast: c.forecast ?? [] },
      { headers: { "Cache-Control": "no-store" } },
    );
  } catch {
    return Response.json({ error: "BACKEND_UNREACHABLE" }, { status: 502 });
  }
}
