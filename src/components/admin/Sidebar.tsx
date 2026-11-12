"use client";

import { CalendarCheck, Clock, Image as ImageIcon, LayoutGrid, LogOut, Menu, MessageCircle, PanelLeftClose, PanelLeftOpen, Sparkles, Tag, Ticket, X } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

import LogoMark from "@/components/Logo";
import { logoutAction } from "@/lib/auth/actions";
import type { AdminProfile } from "@/lib/auth/dal";
import { can, type Permission } from "@/lib/auth/roles";

// Daftar menu sidebar admin: alamat halaman, nama menu, ikon, dan izin yang dibutuhkan.
export const ADMIN_MENU: { href: string; label: string; icon: typeof LayoutGrid; permission: Permission }[] = [
  { href: "/admin", label: "Dashboard", icon: LayoutGrid, permission: "dashboard" },
  { href: "/admin/booking", label: "Booking Sewa & Wahana", icon: CalendarCheck, permission: "booking" },
  { href: "/admin/tiket", label: "Tiket & Check-in", icon: Ticket, permission: "tiket" },
  { href: "/admin/insight", label: "AI Insight", icon: Sparkles, permission: "insight" },
  { href: "/admin/galeri", label: "Galeri & Konten", icon: ImageIcon, permission: "galeri" },
  { href: "/admin/faq", label: "Chatbot & FAQ", icon: MessageCircle, permission: "faq" },
  { href: "/admin/wahana", label: "Wahana & Harga", icon: Tag, permission: "wahana:lihat" },
];

// Sidebar berupa panel kaca terang yang melayang (lapisan navigasi Liquid Glass, sama dengan tab bar aplikasi mobile).
// Ikon menu polos berwarna Abu; menu aktif = kapsul Hijau Daun 12% dengan ikon Hijau Daun dan teks Hijau Tua.
// Di layar kecil disembunyikan dan dibuka lewat tombol menu. admin = akun yang sedang login (dari server).
// Menu yang tidak diizinkan untuk perannya disembunyikan. Ini hanya tampilan: halamannya tetap dicek di server.
export default function Sidebar({ admin }: { admin: AdminProfile }) {
  const pathname = usePathname();
  // open = sidebar sedang terbuka di layar HP atau tidak.
  const [open, setOpen] = useState(false);
  // collapsed = sidebar desktop diperkecil; label menu tampil sebagai tooltip saat ikon diarahkan.
  const [collapsed, setCollapsed] = useState(false);
  const hideWhenCollapsed = collapsed ? "lg:hidden" : "";
  const alignWhenCollapsed = collapsed ? "lg:justify-center" : "";
  const menu = ADMIN_MENU.filter((item) => can(admin.role, item.permission));

  return (
    <>
      {/* Tombol menu untuk membuka sidebar di layar HP */}
      <button type="button" onClick={() => setOpen(true)} aria-label="Buka menu"
              className="glass-light fixed left-4 top-4 z-40 grid size-12 place-items-center rounded-full text-forest lg:hidden">
        <Menu size={20} />
      </button>
      {/* Latar gelap di belakang sidebar saat terbuka di HP, diklik untuk menutup */}
      {open && <div className="fixed inset-0 z-40 bg-ink/40 lg:hidden" onClick={() => setOpen(false)} aria-hidden="true" />}

      <aside id="admin-sidebar" className={`glass-light fixed inset-y-4 left-4 z-50 flex w-[240px] flex-col rounded-[28px] px-3 pb-4 pt-[26px] text-ink transition-[transform,width]
                         lg:sticky lg:inset-auto lg:top-4 lg:h-[calc(100dvh-2rem)] lg:shrink-0 lg:translate-x-0 ${collapsed ? "lg:w-[76px]" : "lg:w-[240px]"} ${open ? "translate-x-0" : "-translate-x-[calc(100%+1rem)]"}`}>
        <div className={`flex h-10 items-center px-1 ${collapsed ? "justify-between lg:justify-center" : "justify-between"}`}>
          <Link href="/admin" title="Ke dashboard admin" className={`flex min-w-0 items-center gap-2.5 ${collapsed ? "lg:hidden" : ""}`}>
            <span className="shrink-0">
              <LogoMark size={34} label="" />
            </span>
            <span className="min-w-0 overflow-hidden whitespace-nowrap">
              <span className="block truncate font-display text-[18px] font-semibold leading-tight text-forest">Sumber Sira</span>
              <span className="block text-[11px] text-abu">Admin Panel</span>
            </span>
          </Link>
          <button type="button" onClick={() => setCollapsed(false)} aria-label="Buka sidebar" aria-controls="admin-sidebar" aria-expanded="false" title="Buka sidebar"
                  className={`group/collapsed-toggle relative hidden size-10 shrink-0 place-items-center rounded-full transition hover:bg-paper ${collapsed ? "lg:grid" : "lg:hidden"}`}>
            <LogoMark size={34} label="" className="transition-opacity group-hover/collapsed-toggle:opacity-0 group-focus-visible/collapsed-toggle:opacity-0" />
            <PanelLeftOpen size={19} aria-hidden="true" className="absolute text-abu opacity-0 transition-opacity group-hover/collapsed-toggle:opacity-100 group-focus-visible/collapsed-toggle:opacity-100" />
          </button>
          <button type="button" onClick={() => setCollapsed(true)} aria-label="Tutup sidebar" aria-controls="admin-sidebar" aria-expanded="true" title="Tutup sidebar"
                  className={`hidden size-9 shrink-0 place-items-center rounded-full text-abu transition hover:bg-paper hover:text-forest ${collapsed ? "lg:hidden" : "lg:grid"}`}>
            <PanelLeftClose size={19} />
          </button>
          <button type="button" onClick={() => setOpen(false)} aria-label="Tutup menu" className="mt-2 lg:hidden"><X size={20} /></button>
        </div>

        <p className={`mt-[34px] overflow-hidden whitespace-nowrap px-3 font-mono text-[10px] uppercase tracking-[0.18em] text-abu ${hideWhenCollapsed}`}>Menu utama</p>
        <nav aria-label="Menu admin" className="mt-2">
          <ul className="space-y-1.5">
            {menu.map(({ href, label, icon: Icon }) => {
              // Menu aktif: Dashboard harus sama persis, menu lain cukup diawali alamatnya.
              const active = href === "/admin" ? pathname === "/admin" : pathname.startsWith(href);
              return (
                <li key={href}>
                  <Link href={href} onClick={() => setOpen(false)} aria-current={active ? "page" : undefined}
                        title={collapsed ? label : undefined}
                        className={`group/menu relative flex h-12 items-center gap-3 rounded-full text-sm tracking-[-0.015em] transition ${alignWhenCollapsed} ${
                          collapsed ? "lg:mx-auto lg:size-11 lg:p-0" : "pl-4 pr-1"} ${
                          active ? "bg-leaf/12 font-semibold text-forest" : "text-ink hover:bg-paper"}`}>
                    <Icon size={20} strokeWidth={active ? 2.25 : 1.75} aria-hidden="true" className={`shrink-0 ${active ? "text-leaf" : "text-abu"}`} />
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
          <div className={`flex h-[76px] items-center gap-3 rounded-[20px] bg-leaf/12 px-4 ${alignWhenCollapsed} ${collapsed ? "lg:hidden" : ""}`}>
            <span className="grid size-10 shrink-0 place-items-center rounded-full bg-white text-leaf"><Clock size={18} aria-hidden="true" /></span>
            <span className={`min-w-[116px] overflow-hidden whitespace-nowrap ${hideWhenCollapsed}`}>
              <span className="block text-xs text-abu">Buka hari ini</span>
              <span className="block text-[15px] font-semibold tabular-nums text-ink">08.00 - 17.00</span>
            </span>
          </div>
          <div className={`flex min-h-[68px] items-center gap-2.5 rounded-[20px] bg-leaf/12 py-2 pl-3 pr-1.5 ${alignWhenCollapsed}`}>
            {/* Kartu profil: klik nama untuk membuka Akun & Sesi */}
            <Link href="/admin/akun" onClick={() => setOpen(false)} title="Akun & Sesi" className={`flex min-w-0 flex-1 items-center gap-2.5 ${alignWhenCollapsed}`}>
            <span className="relative grid size-11 shrink-0 place-items-center rounded-full bg-forest text-base font-semibold text-white">
              {/* Inisial nama admin, misalnya Pak Yono jadi PY */}
              {admin.name.split(" ").map((w) => w[0]).join("").slice(0, 2).toUpperCase()}
              <span className="absolute -right-1 -top-1 grid size-[18px] place-items-center rounded-full bg-leaf text-[10px] font-semibold ring-2 ring-white"
                    aria-label="3 notifikasi">3</span>
            </span>
            <span className={`min-w-[108px] flex-1 overflow-hidden whitespace-nowrap ${hideWhenCollapsed}`}>
              <span className="block truncate text-[15px] font-semibold text-ink">{admin.name}</span>
              <span className="block text-[11px] leading-tight text-abu">{admin.roleLabel}</span>
            </span>
            </Link>
            {/* Tombol keluar: Server Action logoutAction menghapus sesi di server dan cookie di browser */}
            <form action={logoutAction} className={collapsed ? "lg:hidden" : ""}>
              <button type="submit" aria-label="Keluar dari admin" title="Keluar"
                      className="grid size-8 shrink-0 place-items-center rounded-full text-abu transition hover:bg-coral/12 hover:text-coral">
                <LogOut size={17} />
              </button>
            </form>
          </div>
        </div>
      </aside>
    </>
  );
}
