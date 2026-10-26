"use client";

import { CalendarCheck, ChevronLeft, ChevronRight, Clock, Image as ImageIcon, LayoutGrid, LogOut, Menu, MessageCircle, Sparkles, Tag, Ticket, X } from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState } from "react";

import LogoMark from "@/components/Logo";
import { logout } from "@/lib/admin-auth";

// Daftar menu sidebar admin: alamat halaman, nama menu, dan ikon.
export const ADMIN_MENU = [
  { href: "/admin", label: "Dashboard", icon: LayoutGrid },
  { href: "/admin/booking", label: "Booking Sewa & Wahana", icon: CalendarCheck },
  { href: "/admin/tiket", label: "Tiket & Check-in", icon: Ticket },
  { href: "/admin/insight", label: "AI Insight", icon: Sparkles },
  { href: "/admin/galeri", label: "Galeri & Konten", icon: ImageIcon },
  { href: "/admin/faq", label: "Chatbot & FAQ", icon: MessageCircle },
  { href: "/admin/wahana", label: "Wahana & Harga", icon: Tag },
];

// Sidebar berbentuk kartu putih yang melayang (desain admin terbaru). Menu aktif = pill Hijau Tua.
// Di layar kecil disembunyikan dan dibuka lewat tombol menu. session = admin yang sedang login.
export default function Sidebar({ session }) {
  const pathname = usePathname();
  const router = useRouter();
  // open = sidebar sedang terbuka di layar HP atau tidak.
  const [open, setOpen] = useState(false);
  // collapsed = sidebar desktop diperkecil; label menu tampil sebagai tooltip saat ikon diarahkan.
  const [collapsed, setCollapsed] = useState(false);
  const hideWhenCollapsed = collapsed ? "lg:hidden" : "";
  const alignWhenCollapsed = collapsed ? "lg:justify-center" : "";
  // Tombol keluar: hapus sesi login lalu kembali ke halaman login.
  const signOut = () => {
    logout();
    router.replace("/admin/login");
  };

  return (
    <>
      {/* Tombol menu untuk membuka sidebar di layar HP */}
      <button type="button" onClick={() => setOpen(true)} aria-label="Buka menu"
              className="fixed left-4 top-4 z-40 grid size-12 place-items-center rounded-full bg-forest text-white shadow-md lg:hidden">
        <Menu size={20} />
      </button>
      {/* Latar gelap di belakang sidebar saat terbuka di HP, diklik untuk menutup */}
      {open && <div className="fixed inset-0 z-40 bg-ink/40 lg:hidden" onClick={() => setOpen(false)} aria-hidden="true" />}

      <aside className={`fixed inset-y-4 left-4 z-50 flex w-[240px] flex-col rounded-3xl bg-white px-3 pb-4 pt-[26px] text-ink shadow-[0_8px_30px_rgba(23,35,33,0.06)] transition-[transform,width]
                         lg:sticky lg:inset-auto lg:top-4 lg:h-[calc(100dvh-2rem)] lg:shrink-0 lg:translate-x-0 ${collapsed ? "lg:w-[82px]" : "lg:w-[240px]"} ${open ? "translate-x-0" : "-translate-x-[calc(100%+1rem)]"}`}>
        <div className={`flex items-start justify-between px-2 ${alignWhenCollapsed}`}>
          <Link href="/admin" title="Ke dashboard admin" className={`flex min-w-0 flex-1 items-center gap-3 ${alignWhenCollapsed}`}>
            <span className="shrink-0">
              <LogoMark size={40} label="" />
            </span>
            <span className={`min-w-[136px] overflow-hidden whitespace-nowrap ${hideWhenCollapsed}`}>
              <span className="block font-display text-[21px] font-semibold leading-tight text-forest">Sumber Sira</span>
              <span className="block text-xs text-ink/60">Admin Panel</span>
            </span>
          </Link>
          <button type="button" onClick={() => setCollapsed((v) => !v)} aria-label={collapsed ? "Perbesar sidebar" : "Perkecil sidebar"} title={collapsed ? "Perbesar sidebar" : "Perkecil sidebar"}
                  className={`hidden size-8 shrink-0 place-items-center rounded-full text-ink/60 transition hover:bg-paper hover:text-forest lg:grid ${collapsed ? "absolute -right-4 top-8 bg-white shadow-md" : "mt-1 ml-2"}`}>
            {collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
          </button>
          <button type="button" onClick={() => setOpen(false)} aria-label="Tutup menu" className="mt-2 lg:hidden"><X size={20} /></button>
        </div>

        <p className={`mt-[34px] overflow-hidden whitespace-nowrap px-3 font-mono text-[10px] uppercase tracking-[0.18em] text-ink/60 ${hideWhenCollapsed}`}>Menu utama</p>
        <nav aria-label="Menu admin" className="mt-2">
          <ul className="space-y-2">
            {ADMIN_MENU.map(({ href, label, icon: Icon }) => {
              // Menu aktif: Dashboard harus sama persis, menu lain cukup diawali alamatnya.
              const active = href === "/admin" ? pathname === "/admin" : pathname.startsWith(href);
              return (
                <li key={href}>
                  <Link href={href} onClick={() => setOpen(false)} aria-current={active ? "page" : undefined}
                        title={collapsed ? label : undefined}
                        className={`group/menu relative flex h-12 items-center gap-3 rounded-full pl-2 pr-0.5 text-sm tracking-[-0.015em] transition ${alignWhenCollapsed} ${
                          active ? "bg-forest font-semibold text-white" : "text-ink hover:bg-paper"}`}>
                    <span className={`grid size-8 shrink-0 place-items-center rounded-full ${active ? "bg-white text-forest" : "bg-leaf/12 text-forest"}`}>
                      <Icon size={16} aria-hidden="true" />
                    </span>
                    <span className={`min-w-[150px] truncate ${hideWhenCollapsed}`}>{label}</span>
                    {collapsed && (
                      <span className="pointer-events-none absolute left-[calc(100%+0.75rem)] top-1/2 z-[60] hidden -translate-y-1/2 whitespace-nowrap rounded-full bg-forest px-3.5 py-2 text-xs font-semibold text-white opacity-0 shadow-lg shadow-ink/15 transition group-hover/menu:block group-hover/menu:opacity-100 group-focus-visible/menu:block group-focus-visible/menu:opacity-100 lg:block lg:opacity-0">
                        {label}
                      </span>
                    )}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>

        {/* Bagian bawah sidebar: jam buka dan profil admin yang login beserta tombol keluar */}
        <div className="mt-auto space-y-4">
          <div className={`flex h-[76px] items-center gap-3 rounded-[20px] bg-leaf/[0.08] px-4 ${alignWhenCollapsed} ${collapsed ? "lg:hidden" : ""}`}>
            <span className="grid size-10 shrink-0 place-items-center rounded-full bg-white text-ink"><Clock size={18} aria-hidden="true" /></span>
            <span className={`min-w-[116px] overflow-hidden whitespace-nowrap ${hideWhenCollapsed}`}>
              <span className="block text-xs text-ink/60">Buka hari ini</span>
              <span className="block text-[15px] font-semibold text-ink">08.00 - 17.00</span>
            </span>
          </div>
          <div className={`flex min-h-[68px] items-center gap-2.5 rounded-[20px] bg-leaf/[0.08] py-2 pl-3 pr-1.5 ${alignWhenCollapsed}`}>
            <span className="relative grid size-11 shrink-0 place-items-center rounded-full bg-forest text-base font-semibold text-white">
              {/* Inisial nama admin, misalnya Pak Yono jadi PY */}
              {session.name.split(" ").map((w) => w[0]).join("").slice(0, 2).toUpperCase()}
              <span className="absolute -right-1 -top-1 grid size-[18px] place-items-center rounded-full bg-coral text-[10px] font-semibold ring-2 ring-white"
                    aria-label="3 notifikasi">3</span>
            </span>
            <span className={`min-w-[108px] flex-1 overflow-hidden whitespace-nowrap ${hideWhenCollapsed}`}>
              <span className="block truncate text-[15px] font-semibold text-ink">{session.name}</span>
              <span className="block text-[11px] leading-tight text-ink/60">{session.role}</span>
            </span>
            <button type="button" onClick={signOut} aria-label="Keluar dari admin" title="Keluar"
                    className={`grid size-8 shrink-0 place-items-center rounded-full text-ink/70 transition hover:bg-coral/12 hover:text-coral ${collapsed ? "lg:hidden" : ""}`}>
              <LogOut size={17} />
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
