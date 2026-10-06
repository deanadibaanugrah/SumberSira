"use client";

import { Calendar, Camera, ChartColumn, House, User } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

// Navigasi bawah aplikasi (5 ikon seperti di desain). Area sentuh selebar kolom, lingkaran ikon 23 px.
// Catatan: halaman Profil belum ada di desain Figma, jadi ikon profil sementara menuju Ulasan & Rating.
const ITEMS = [
  { href: "/app/home", label: "Beranda", icon: House },
  { href: "/app/booking", label: "Sewa & Booking", icon: Calendar },
  { href: "/app/crowd", label: "Live Crowd", icon: ChartColumn },
  { href: "/app/ai-photo", label: "AI Photo Studio", icon: Camera },
  { href: "/app/ulasan", label: "Profil & Ulasan", icon: User },
];

export default function BottomNav() {
  const pathname = usePathname();
  return (
    <nav aria-label="Navigasi utama"
         className="fixed inset-x-0 bottom-0 z-30 mx-auto w-full max-w-[430px] px-5 pb-5">
      <ul className="glass grid h-14 grid-cols-5 rounded-full shadow-lg shadow-black/20">
        {ITEMS.map(({ href, label, icon: Icon }) => {
          const active = pathname === href;
          return (
            <li key={href}>
              <Link href={href} aria-label={label} aria-current={active ? "page" : undefined}
                    className="group grid h-full place-items-center">
                <span className={`grid size-[23px] place-items-center rounded-full transition ${
                  active ? "bg-leaf text-white" : "bg-white/15 text-white group-hover:bg-white/25"}`}>
                  <Icon size={13} strokeWidth={2.6} />
                </span>
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
