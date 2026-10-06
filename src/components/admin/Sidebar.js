"use client";

import { Calendar, ChartColumn, ImageIcon, LayoutGrid, Menu, MessageSquare, Tag, X } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

export const ADMIN_MENU = [
  { href: "/admin", label: "Dashboard", icon: LayoutGrid },
  { href: "/admin/booking", label: "Booking Sewa & Wahana", icon: Calendar },
  { href: "/admin/insight", label: "AI Insight", icon: ChartColumn },
  { href: "/admin/galeri", label: "Galeri & Konten", icon: ImageIcon },
  { href: "/admin/faq", label: "Chatbot / FAQ", icon: MessageSquare },
  { href: "/admin/wahana", label: "Wahana & Harga", icon: Tag },
];

// Sidebar hijau tua seperti di desain. Di layar kecil disembunyikan dan dibuka lewat tombol menu.
export default function Sidebar() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  return (
    <>
      <button type="button" onClick={() => setOpen(true)} aria-label="Buka menu"
              className="fixed left-4 top-4 z-40 grid size-10 place-items-center rounded-xl bg-forest text-white shadow-md lg:hidden">
        <Menu size={20} />
      </button>
      {open && <div className="fixed inset-0 z-40 bg-ink/40 lg:hidden" onClick={() => setOpen(false)} aria-hidden="true" />}

      <aside className={`fixed inset-y-0 left-0 z-50 flex w-[220px] flex-col bg-forest px-3 pb-6 text-white transition-transform lg:sticky lg:top-0 lg:h-dvh lg:translate-x-0 ${
               open ? "translate-x-0" : "-translate-x-full"}`}>
        <div className="mx-2 flex items-start justify-between border-b border-white/15 px-[5px] pb-3 pt-[27px]">
          <div>
            <p className="font-display text-base font-semibold">Sumber Sira</p>
            <p className="text-[9px] text-white/75">Admin Panel</p>
          </div>
          <button type="button" onClick={() => setOpen(false)} aria-label="Tutup menu" className="lg:hidden"><X size={20} /></button>
        </div>
        <nav aria-label="Menu admin" className="mt-3">
          <ul className="space-y-3">
            {ADMIN_MENU.map(({ href, label, icon: Icon }) => {
              const active = href === "/admin" ? pathname === "/admin" : pathname.startsWith(href);
              return (
                <li key={href}>
                  <Link href={href} onClick={() => setOpen(false)} aria-current={active ? "page" : undefined}
                        className={`flex h-10 items-center gap-[15px] rounded-lg px-[13px] text-xs leading-tight transition ${
                          active ? "bg-leaf font-semibold" : "text-white/85 hover:bg-white/10"}`}>
                    <Icon size={14} className="shrink-0" />
                    {label}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>
        <Link href="/" className="mt-auto px-[13px] text-[10px] text-white/60 hover:text-white">← Halaman utama</Link>
      </aside>
    </>
  );
}
