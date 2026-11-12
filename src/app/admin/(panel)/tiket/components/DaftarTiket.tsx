import { LogIn, LogOut } from "lucide-react";

import { Card, CardTitle, FilterPills, StatusPill } from "@/components/admin/ui";
import { rupiah } from "@/lib/format";
import { PARKIR, checkIn, checkOut, jumlahOrang, type Ticket, type useTiket } from "@/lib/tiket-store";

// Pilihan filter status tiket.
const FILTERS = ["Semua", "Belum masuk", "Di dalam", "Keluar"];
// Nama parkir untuk tabel (Tidak ditulis sebagai tanda -).
const PARKIR_LABEL = Object.fromEntries(PARKIR.map((p) => [p.id, p.id === "none" ? "-" : p.label]));

type DaftarTiketProps = {
  tiket: ReturnType<typeof useTiket>;
  visible: Ticket[];
  filter: string;
  onFilter: (value: string) => void;
  query: string;
  onQuery: (value: string) => void;
  onHasil: (hasil: { ok: boolean; message: string }) => void;
};

// Tabel semua tiket hari ini dengan filter, pencarian, dan tombol Check-in / Keluar per baris.
export default function DaftarTiket({ tiket, visible, filter, onFilter, query, onQuery, onHasil }: DaftarTiketProps) {
  return (
    <Card className="mt-5 px-4! pt-5!">
      <div className="px-2">
        <CardTitle>Daftar Tiket Hari Ini</CardTitle>
        <div className="mt-4"><FilterPills options={FILTERS} value={filter} onChange={onFilter} label="Filter status tiket" /></div>
        <input value={query} onChange={(e) => onQuery(e.target.value)} placeholder="Cari nama atau kode tiket..." aria-label="Cari tiket"
               className="mt-3 h-10 w-full rounded-full bg-paper px-4 text-sm outline-none focus:ring-2 focus:ring-leaf/30 md:hidden" />
      </div>
      <div className="mt-4 overflow-x-auto">
        <table className="w-full min-w-[820px] border-separate border-spacing-y-2 text-left text-sm">
          <thead className="text-[13px] text-abu">
            <tr>
              <th className="pl-4 font-normal">Kode</th>
              <th className="font-normal">Pemesan</th>
              <th className="font-normal">Orang</th>
              <th className="font-normal">Parkir</th>
              <th className="font-normal">Dibeli</th>
              <th className="font-normal">Masuk</th>
              <th className="font-normal">Status</th>
              <th className="pr-4 text-right font-normal">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {visible.map((t) => (
              <tr key={t.code} className={`[&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl ${t.mine ? "bg-leaf/12" : "bg-paper"}`}>
                <td className="h-12 pl-4 font-mono font-medium">{t.code}</td>
                <td>
                  <span className="font-semibold">{t.name}</span>
                  {t.mine && <span className="ml-2 rounded-full bg-white px-2 py-0.5 text-[11px] text-forest">dari aplikasi</span>}
                </td>
                <td>{jumlahOrang(t)}{t.kids > 0 && <span className="text-abu"> ({t.kids} balita)</span>}</td>
                <td>{PARKIR_LABEL[t.parking]}</td>
                <td className="font-mono">{t.boughtAt}</td>
                <td className="font-mono">{t.checkInAt ?? "-"}</td>
                <td><StatusPill status={t.status} /></td>
                <td className="pr-3 text-right">
                  {/* Tiket belum masuk: tombol Check-in */}
                  {t.status === "Belum masuk" && (
                    <button type="button" onClick={() => onHasil(checkIn(t.code))}
                            className="inline-flex h-8 items-center gap-1.5 rounded-full bg-forest px-3 text-xs font-semibold text-white hover:brightness-125">
                      <LogIn size={14} /> Check-in
                    </button>
                  )}
                  {/* Pengunjung di dalam: tombol Keluar */}
                  {t.status === "Di dalam" && (
                    <button type="button" onClick={() => onHasil(checkOut(t.code))}
                            className="inline-flex h-8 items-center gap-1.5 rounded-full bg-white px-3 text-xs font-semibold text-ink hover:bg-ink/10">
                      <LogOut size={14} /> Keluar
                    </button>
                  )}
                  {t.status === "Keluar" && <span className="text-xs text-abu">{t.checkOutAt}</span>}
                </td>
              </tr>
            ))}
            {visible.length === 0 && (
              <tr><td colSpan={8} className="rounded-2xl bg-paper px-5 py-10 text-center text-abu">Tidak ada tiket yang cocok.</td></tr>
            )}
          </tbody>
        </table>
      </div>
      <p className="px-2 pb-2 pt-3 text-xs text-abu">
        Total {tiket.sold} tiket · nilai penjualan {rupiah(tiket.tickets.reduce((sum, t) => sum + t.total, 0))}
      </p>
    </Card>
  );
}
