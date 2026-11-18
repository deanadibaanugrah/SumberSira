"use client";

import { Ellipsis } from "lucide-react";
import Link from "next/link";

import { Avatar, Card, CardTitle, StatusPill } from "@/components/admin/ui";
import { terbaru, useBooking } from "@/lib/booking-store";

// Tabel 3 booking sewa terbaru dari backend, dengan tautan ke halaman Booking.
export default function BookingMasuk() {
  const { rows, ready } = useBooking();
  const data = terbaru(rows).slice(0, 3);
  // Daftar item sewa satu booking, mis. "2x Ban Besar, 1x Loker".
  const items = (b: (typeof data)[number]) => b.lines.map((l) => `${l.qty}x ${l.name}`).join(", ") || "-";
  return (
    <Card className="px-4! pb-2! pt-5!">
      <CardTitle className="px-2"
                 right={<Link href="/admin/booking" className="text-sm font-semibold text-leaf hover:text-forest">Lihat semua</Link>}>
        Booking Sewa Masuk
      </CardTitle>
      {/* Di HP tabel diganti daftar kartu supaya tidak perlu digeser ke samping. */}
      <ul className="mt-3 space-y-2 md:hidden">
        {data.map((b) => (
          <li key={b.code} className="flex items-center gap-3 rounded-2xl bg-paper p-3">
            <Avatar name={b.name} size={32} />
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-semibold text-ink">{b.name}</p>
              <p className="truncate text-xs text-abu">{items(b)} · {b.slotLabel}</p>
            </div>
            <StatusPill status={b.status} />
          </li>
        ))}
        {!ready && <li className="rounded-2xl bg-paper px-5 py-8 text-center text-sm text-abu">Memuat booking...</li>}
        {ready && data.length === 0 && <li className="rounded-2xl bg-paper px-5 py-8 text-center text-sm text-abu">Belum ada booking.</li>}
      </ul>
      <div className="mt-2 hidden overflow-x-auto md:block">
        <table className="w-full min-w-[640px] border-separate border-spacing-y-2 text-left text-sm">
          <thead className="text-[13px] text-abu">
            <tr>
              <th className="pl-[52px] font-normal">Pemesan</th>
              <th className="font-normal">Item</th>
              <th className="font-normal">Jam</th>
              <th className="font-normal">Status</th>
              <th className="w-12"><span className="sr-only">Aksi</span></th>
            </tr>
          </thead>
          <tbody>
            {data.map((b) => (
              <tr key={b.code} className="bg-paper [&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl">
                <td className="h-10 py-1 pl-3">
                  <span className="flex items-center gap-3"><Avatar name={b.name} size={28} /><span className="font-semibold text-ink">{b.name}</span></span>
                </td>
                <td className="text-ink">{items(b)}</td>
                <td className="font-mono text-ink">{b.slotLabel}</td>
                <td><StatusPill status={b.status} /></td>
                <td className="pr-3 text-right">
                  <Link href="/admin/booking" aria-label={`Buka booking ${b.name}`} className="inline-grid size-8 place-items-center rounded-full text-abu hover:bg-white">
                    <Ellipsis size={18} />
                  </Link>
                </td>
              </tr>
            ))}
            {!ready && (
              <tr><td colSpan={5} className="rounded-2xl bg-paper px-5 py-8 text-center text-abu">Memuat booking...</td></tr>
            )}
            {ready && data.length === 0 && (
              <tr><td colSpan={5} className="rounded-2xl bg-paper px-5 py-8 text-center text-abu">Belum ada booking.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </Card>
  );
}
