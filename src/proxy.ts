import { NextResponse, type NextRequest } from "next/server";

import { SESSION_COOKIE } from "@/lib/auth/constants";

// proxy.ts (dulu bernama middleware.ts): berjalan sebelum request sampai ke halaman admin.
// Hanya cek kasar dan cepat: ada cookie sesi atau tidak. Cookie ada belum tentu sesinya valid,
// jadi pengecekan sebenarnya tetap di DAL (src/lib/auth/dal.ts) pada setiap halaman dan Server Action.
export function proxy(req: NextRequest) {
  const { pathname } = req.nextUrl;
  const hasCookie = req.cookies.has(SESSION_COOKIE);

  // Belum ada cookie sesi dan membuka halaman admin selain login: arahkan ke login, bawa alamat asalnya.
  if (!hasCookie && pathname !== "/admin/login") {
    const url = new URL("/admin/login", req.url);
    url.searchParams.set("next", pathname);
    return NextResponse.redirect(url);
  }
  return NextResponse.next();
}

// Proxy hanya aktif untuk alamat /admin dan turunannya.
export const config = { matcher: ["/admin", "/admin/:path*"] };
