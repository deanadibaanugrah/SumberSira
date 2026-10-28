import { Check } from "lucide-react";

import { Avatar, Card, CardTitle, FilterPills, StatusPill } from "@/components/admin/ui";
import { BOOKINGS, BOOKING_TOTALS } from "@/data/dummy";

// Pilihan filter status booking.
const FILTERS = ["Semua", "Baru", "Diproses", "Selesai"];

type DaftarBookingProps = {
  visible: typeof BOOKINGS;
  selectedId: number;
  onSelect: (id: number) => void;
  filter: string;
  onFilter: (value: string) => void;
  query: string;
  onQuery: (value: string) => void;
};

// Daftar booking: filter status, kotak cari (layar kecil), tabel, dan nomor halaman.
export default function DaftarBooking({ visible, selectedId, onSelect, filter, onFilter, query, onQuery }: DaftarBookingProps) {
  return (
    <Card className="flex flex-col px-4! pt-5!">
      <div className="px-2">
        <CardTitle>Daftar Booking</CardTitle>
        <div className="mt-4"><FilterPills options={FILTERS} value={filter} onChange={onFilter} label="Filter status booking" /></div>
        {/* Kotak cari di header hanya muncul di layar lebar; di layar kecil pakai kotak ini. */}
        <input value={query} onChange={(e) => onQuery(e.target.value)} placeholder="Cari nama pemesan..." aria-label="Cari nama pemesan"
               className="mt-3 h-10 w-full rounded-full bg-paper px-4 text-sm outline-none focus:ring-2 focus:ring-leaf/30 md:hidden" />
      </div>

      <div className="mt-4 overflow-x-auto">
        {/* Tabel booking, klik satu baris untuk melihat detailnya */}
        <table className="w-full min-w-[600px] border-separate border-spacing-y-2.5 text-left text-sm">
          <thead className="text-[13px] text-abu">
            <tr>
              <th className="pl-[44px] font-normal">Pemesan</th>
              <th className="font-normal">Item</th>
              <th className="font-normal">Jam</th>
              <th className="font-normal">Status</th>
            </tr>
          </thead>
          <tbody>
            {visible.map((r) => {
              const active = r.id === selectedId;
              return (
                <tr key={r.id} onClick={() => onSelect(r.id)} tabIndex={0} aria-label={`Lihat detail booking ${r.name}`}
                    onKeyDown={(e) => e.key === "Enter" && onSelect(r.id)}
                    className={`cursor-pointer outline-none transition [&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl [&>td]:border-y-[1.5px] [&>td:first-child]:border-l-[1.5px] [&>td:last-child]:border-r-[1.5px] focus-visible:[&>td]:border-leaf ${
                      active ? "bg-leaf/12 [&>td]:border-leaf" : "bg-paper hover:bg-leaf/12 [&>td]:border-transparent"}`}>
                  <td className="h-[60px] pl-4">
                    <span className="flex items-center gap-3">
                      <span aria-hidden="true" className={`grid size-4 shrink-0 place-items-center rounded-[5px] border-[1.5px] ${active ? "border-forest bg-forest text-white" : "border-ink/30 bg-white"}`}>
                        {active && <Check size={11} strokeWidth={3} />}
                      </span>
                      <Avatar name={r.name} size={32} />
                      <span>
                        <span className="block font-semibold leading-tight text-ink">{r.name}</span>
                        <span className="block text-xs text-abu">{r.qty}</span>
                      </span>
                    </span>
                  </td>
                  <td className="text-ink">{r.items}</td>
                  <td className="font-mono text-ink">{r.time}</td>
                  <td className="pr-4"><StatusPill status={r.status} /></td>
                </tr>
              );
            })}
            {visible.length === 0 && (
              <tr><td colSpan={4} className="rounded-2xl bg-paper px-5 py-10 text-center text-abu">Tidak ada booking yang cocok.</td></tr>
            )}
          </tbody>
        </table>
      </div>

      <div className="mt-auto flex flex-wrap items-center justify-between gap-3 px-2 pt-6">
        <p className="text-sm text-abu">Menampilkan {visible.length} dari {BOOKING_TOTALS.hariIni} booking</p>
        {/* Data contoh hanya satu halaman; nomor halaman lain ditampilkan sebagai gambaran. */}
        <div className="flex gap-2 text-sm font-semibold" aria-label="Halaman">
          {[1, 2, 3, 4].map((n) => (
            <span key={n} aria-current={n === 1 ? "page" : undefined}
                  className={`grid size-10 place-items-center rounded-full ${n === 1 ? "bg-forest text-white" : "bg-paper text-ink"}`}>{n}</span>
          ))}
        </div>
      </div>
    </Card>
  );
}
