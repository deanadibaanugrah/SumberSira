"use client";

import { CalendarCheck, Clock, Image as ImageIcon, LayoutGrid, Menu, MessageCircle, Sparkles, Tag, X } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

import LogoMark from "@/components/Logo";

export const ADMIN_MENU = [
  { href: "/admin", label: "Dashboard", icon: LayoutGrid },
  { href: "/admin/booking", label: "Booking Sewa & Wahana", icon: CalendarCheck },
  { href: "/admin/insight", label: "AI Insight", icon: Sparkles },
  { href: "/admin/galeri", label: "Galeri & Konten", icon: ImageIcon },
  { href: "/admin/faq", label: "Chatbot & FAQ", icon: MessageCircle },
  { href: "/admin/wahana", label: "Wahana & Harga", icon: Tag },
];

// Sidebar berbentuk kartu putih yang melayang (desain admin terbaru). Menu aktif = pill Hijau Tua.
// Di layar kecil disembunyikan dan dibuka lewat tombol menu.
export default function Sidebar() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  return (
    <>
      <button type="button" onClick={() => setOpen(true)} aria-label="Buka menu"
              className="fixed left-4 top-4 z-40 grid size-12 place-items-center rounded-full bg-forest text-white shadow-md lg:hidden">
        <Menu size={20} />
      </button>
      {open && <div className="fixed inset-0 z-40 bg-ink/40 lg:hidden" onClick={() => setOpen(false)} aria-hidden="true" />}

      <aside className={`fixed inset-y-4 left-4 z-50 flex w-[240px] flex-col rounded-3xl bg-white px-3 pb-4 pt-[26px] text-ink shadow-[0_8px_30px_rgba(23,35,33,0.06)] transition-transform
                         lg:sticky lg:inset-auto lg:top-4 lg:h-[calc(100dvh-2rem)] lg:shrink-0 lg:translate-x-0 ${open ? "translate-x-0" : "-translate-x-[calc(100%+1rem)]"}`}>
        <div className="flex items-start justify-between px-2">
          <Link href="/" title="Ke halaman utama" className="flex items-center gap-3">
            <LogoMark size={40} label="" />
            <span>
              <span className="block font-display text-[21px] font-semibold leading-tight text-forest">Sumber Sira</span>
              <span className="block text-xs text-ink/60">Admin Panel</span>
            </span>
          </Link>
          <button type="button" onClick={() => setOpen(false)} aria-label="Tutup menu" className="mt-2 lg:hidden"><X size={20} /></button>
        </div>

        <p className="mt-[34px] px-3 font-mono text-[10px] uppercase tracking-[0.18em] text-ink/60">Menu utama</p>
        <nav aria-label="Menu admin" className="mt-2">
          <ul className="space-y-2">
            {ADMIN_MENU.map(({ href, label, icon: Icon }) => {
              const active = href === "/admin" ? pathname === "/admin" : pathname.startsWith(href);
              return (
                <li key={href}>
                  <Link href={href} onClick={() => setOpen(false)} aria-current={active ? "page" : undefined}
                        className={`flex h-12 items-center gap-3 rounded-full pl-2 pr-0.5 text-sm tracking-[-0.015em] transition ${
                          active ? "bg-forest font-semibold text-white" : "text-ink hover:bg-paper"}`}>
                    <span className={`grid size-8 shrink-0 place-items-center rounded-full ${active ? "bg-white text-forest" : "bg-leaf/12 text-forest"}`}>
                      <Icon size={16} aria-hidden="true" />
                    </span>
                    <span className="truncate">{label}</span>
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>

        <div className="mt-auto space-y-4">
          <div className="flex h-[76px] items-center gap-3 rounded-[20px] bg-leaf/[0.08] px-4">
            <span className="grid size-10 shrink-0 place-items-center rounded-full bg-white text-ink"><Clock size={18} aria-hidden="true" /></span>
            <span>
              <span className="block text-xs text-ink/60">Buka hari ini</span>
              <span className="block text-[15px] font-semibold text-ink">08.00 - 17.00</span>
            </span>
          </div>
          <div className="flex h-[68px] items-center gap-3 rounded-[20px] bg-leaf/[0.08] px-3">
            <span className="relative grid size-11 shrink-0 place-items-center rounded-full bg-forest text-base font-semibold text-white">
              PY
              <span className="absolute -right-1 -top-1 grid size-[18px] place-items-center rounded-full bg-coral text-[10px] font-semibold ring-2 ring-white"
                    aria-label="3 notifikasi">3</span>
            </span>
            <span>
              <span className="block text-[15px] font-semibold text-ink">Pak Yono</span>
              <span className="block text-xs text-ink/60">Pengelola · BUMDes</span>
            </span>
          </div>
        </div>
      </aside>
    </>
  );
}
