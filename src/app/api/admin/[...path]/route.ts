import type { NextRequest } from "next/server";

import { apiFetch } from "@/lib/server/api";

// Penerus (BFF) dari browser ke backend untuk data admin: dashboard, tiket, booking, dan pembayaran.
// Browser memanggil /api/admin/tiket/... ; di sini sesi login ikut diteruskan ke backend, dan backend-lah yang
// memutuskan boleh atau tidaknya (401/403). Hanya bagian-bagian ini yang diteruskan, bukan seluruh /admin backend.
const TARGET: Record<string, string> = {
  dashboard: "/admin/dashboard",
  tiket: "/admin/tickets",
  booking: "/admin/bookings",
  payment: "/admin/payments",
};

async function forward(req: NextRequest, ctx: { params: Promise<{ path: string[] }> }) {
  const { path } = await ctx.params;
  const base = TARGET[path[0]];
  if (!base || path.some((p) => p === ".." || p === ".")) return Response.json({ error: "NOT_FOUND" }, { status: 404 });

  const rest = path.slice(1).map(encodeURIComponent).join("/");
  const url = `${base}${rest ? `/${rest}` : ""}${req.nextUrl.search}`;
  const hasBody = req.method !== "GET" && req.method !== "DELETE";

  try {
    const res = await apiFetch(url, { method: req.method, body: hasBody ? await req.text() : undefined });
    const text = await res.text();
    return new Response(text, {
      status: res.status,
      headers: { "content-type": res.headers.get("content-type") ?? "application/json", "Cache-Control": "no-store" },
    });
  } catch {
    // Backend mati atau tidak terjangkau
    return Response.json({ error: "BACKEND_UNREACHABLE" }, { status: 502 });
  }
}

export { forward as GET, forward as POST, forward as PATCH, forward as DELETE };
