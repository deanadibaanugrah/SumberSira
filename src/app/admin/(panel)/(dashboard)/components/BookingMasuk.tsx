import { Ellipsis } from "lucide-react";
import Link from "next/link";

import { Avatar, Card, CardTitle, StatusPill } from "@/components/admin/ui";
import { BOOKINGS } from "@/data/dummy";

// Tabel 3 booking sewa terbaru dengan tautan ke halaman Booking.
export default function BookingMasuk() {
  return (
    <Card className="px-4! pb-2! pt-5!">
      <CardTitle className="px-2"
                 right={<Link href="/admin/booking" className="text-sm font-semibold text-leaf hover:text-forest">Lihat semua</Link>}>
        Booking Sewa Masuk
      </CardTitle>
      <div className="mt-2 overflow-x-auto">
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
            {BOOKINGS.slice(0, 3).map((b) => (
              <tr key={b.id} className="bg-paper [&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl">
                <td className="h-10 py-1 pl-3">
                  <span className="flex items-center gap-3"><Avatar name={b.name} size={28} /><span className="font-semibold text-ink">{b.name}</span></span>
                </td>
                <td className="text-ink">{b.items}</td>
                <td className="font-mono text-ink">{b.time}</td>
                <td><StatusPill status={b.status} /></td>
                <td className="pr-3 text-right">
                  <Link href="/admin/booking" aria-label={`Buka booking ${b.name}`} className="inline-grid size-8 place-items-center rounded-full text-abu hover:bg-white">
                    <Ellipsis size={18} />
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
}
