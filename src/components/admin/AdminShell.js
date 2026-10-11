"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect } from "react";

import LogoMark from "@/components/Logo";
import Sidebar from "@/components/admin/Sidebar";
import { useAdminSession } from "@/lib/admin-auth";

// Kerangka panel admin: halaman /admin/login tampil sendiri, halaman lain wajib login
// lalu tampil dengan sidebar. Belum login = diarahkan ke halaman login.
export default function AdminShell({ children }) {
  const pathname = usePathname();
  const router = useRouter();
  const session = useAdminSession();
  const onLogin = pathname === "/admin/login";

  useEffect(() => {
    if (!onLogin && session === null) router.replace(`/admin/login?next=${encodeURIComponent(pathname)}`);
  }, [onLogin, session, pathname, router]);

  if (onLogin) return children;

  if (!session || session === "loading") {
    return (
      <div className="grid min-h-dvh place-items-center bg-paper text-ink" role="status">
        <div className="flex flex-col items-center gap-3">
          <LogoMark size={52} className="animate-pop" />
          <p className="text-sm text-ink/60">Memeriksa sesi admin...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-dvh bg-paper text-ink lg:flex lg:gap-6 lg:p-4">
      <Sidebar session={session} />
      <div className="min-w-0 flex-1 px-4 pb-8 pt-4 lg:px-0 lg:pb-4 lg:pr-2 lg:pt-3">{children}</div>
    </div>
  );
}
