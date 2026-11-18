import type { AnchorHTMLAttributes } from "react";

// Pengganti next/link: tautan biasa, jadi setiap klik memuat halaman baru dari server (hard refresh).
// Peralihannya tetap halus karena animasi lintas-halaman di globals.css (@view-transition) dan prerender saat kursor menyentuh menu.
type Props = AnchorHTMLAttributes<HTMLAnchorElement> & { href: string; prefetch?: boolean; scroll?: boolean; replace?: boolean };

export default function HardLink({ prefetch: _prefetch, scroll: _scroll, replace: _replace, ...props }: Props) {
  return <a {...props} />;
}
