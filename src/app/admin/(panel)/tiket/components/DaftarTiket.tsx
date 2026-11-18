import { Banknote, LogIn, LogOut } from "lucide-react";

import { Card, CardTitle, FilterPills, StatusPill } from "@/components/admin/ui";
import { rupiah } from "@/lib/format";
import { PARKIR_LABEL, checkIn, checkOut, jumlahOrang, konfirmasiTunai, type Ticket, type useTiket } from "@/lib/tiket-store";

// Pilihan filter status tiket.
const FILTERS = ["Semua", "Belum masuk", "Di dalam", "Keluar"];


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
  // Tombol aksi yang sama dipakai di tabel (layar lebar) dan kartu (HP).
  const aksi = (t: Ticket) => (
    <>
      {/* Tiket tunai yang belum lunas: konfirmasi pembayaran dulu (check-in ditolak backend selama belum lunas) */}
      {t.payment === "cash" && t.paymentStatus === "pending" ? (
        <button type="button" onClick={async () => onHasil(await konfirmasiTunai(t.code))}
                className="inline-flex h-8 items-center gap-1.5 rounded-full bg-forest px-3 text-xs font-semibold text-white hover:brightness-125">
          <Banknote size={14} /> Konfirmasi Tunai
        </button>
      ) : t.status === "Belum masuk" ? (
        /* Tiket belum masuk: tombol Check-in */
        <button type="button" onClick={async () => onHasil(await checkIn(t.code))}
                className="inline-flex h-8 items-center gap-1.5 rounded-full bg-forest px-3 text-xs font-semibold text-white hover:brightness-125">
          <LogIn size={14} /> Check-in
        </button>
      ) : null}
      {/* Pengunjung di dalam: tombol Keluar */}
      {t.status === "Di dalam" && (
        <button type="button" onClick={async () => onHasil(await checkOut(t.code))}
                className="inline-flex h-8 items-center gap-1.5 rounded-full bg-white px-3 text-xs font-semibold text-ink hover:bg-ink/10">
          <LogOut size={14} /> Keluar
        </button>
      )}
      {t.status === "Keluar" && <span className="text-xs text-abu">{t.checkOutAt}</span>}
    </>
  );

  const kosong = tiket.ready
    ? (tiket.sold === 0 ? "Belum ada tiket untuk hari ini. Tiket yang dibeli di aplikasi akan muncul di sini." : "Tidak ada tiket yang cocok.")
    : tiket.error ? "Tidak bisa terhubung ke server." : "Memuat tiket...";

  return (
    <Card className="mt-5 px-4! pt-5!">
      <div className="px-2">
        <CardTitle>Daftar Tiket Hari Ini</CardTitle>
        <div className="mt-4"><FilterPills options={FILTERS} value={filter} onChange={onFilter} label="Filter status tiket" /></div>
        <input value={query} onChange={(e) => onQuery(e.target.value)} placeholder="Cari nama atau kode tiket..." aria-label="Cari tiket"
               className="mt-3 h-10 w-full rounded-full bg-paper px-4 text-sm outline-none focus:ring-2 focus:ring-leaf/30 md:hidden" />
      </div>

      {/* Di HP tabel diganti kartu agar kode, pemesan, status, dan tombol aksi tetap terbaca. */}
      <ul className="mt-4 space-y-2 md:hidden">
        {visible.map((t) => (
          <li key={t.id} className={`rounded-2xl p-3 ${t.fromApp ? "bg-leaf/12" : "bg-paper"}`}>
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <p className="font-mono text-sm font-semibold text-ink">{t.code}</p>
                <p className="mt-0.5 truncate text-sm font-semibold text-ink">
                  {t.name}
                  <span className="ml-2 rounded-full bg-white px-2 py-0.5 text-[11px] font-medium text-forest">{t.fromApp ? "dari aplikasi" : "loket"}</span>
                </p>
              </div>
              <StatusPill status={t.status} />
            </div>
            <dl className="mt-2 grid grid-cols-2 gap-x-3 gap-y-1 text-xs">
              <div><dt className="inline text-abu">Orang: </dt><dd className="inline text-ink">{jumlahOrang(t)}{t.kids > 0 && <span className="text-abu"> ({t.kids} balita)</span>}</dd></div>
              <div><dt className="inline text-abu">Parkir: </dt><dd className="inline text-ink">{PARKIR_LABEL[t.parking]}</dd></div>
              <div><dt className="inline text-abu">Dibeli: </dt><dd className="inline font-mono text-ink">{t.boughtAt}</dd></div>
              <div><dt className="inline text-abu">Masuk: </dt><dd className="inline font-mono text-ink">{t.checkInAt ?? "-"}</dd></div>
            </dl>
            <div className="mt-3 flex justify-end">{aksi(t)}</div>
          </li>
        ))}
        {visible.length === 0 && <li className="rounded-2xl bg-paper px-5 py-10 text-center text-sm text-abu">{kosong}</li>}
      </ul>

      <div className="mt-4 hidden overflow-x-auto md:block">
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
              <tr key={t.id} className={`[&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl ${t.fromApp ? "bg-leaf/12" : "bg-paper"}`}>
                <td className="h-12 pl-4 font-mono font-medium">{t.code}</td>
                <td>
                  <span className="font-semibold">{t.name}</span>
                  <span className="ml-2 rounded-full bg-white px-2 py-0.5 text-[11px] text-forest">{t.fromApp ? "dari aplikasi" : "loket"}</span>
                </td>
                <td>{jumlahOrang(t)}{t.kids > 0 && <span className="text-abu"> ({t.kids} balita)</span>}</td>
                <td>{PARKIR_LABEL[t.parking]}</td>
                <td className="font-mono">{t.boughtAt}</td>
                <td className="font-mono">{t.checkInAt ?? "-"}</td>
                <td><StatusPill status={t.status} /></td>
                <td className="pr-3 text-right">{aksi(t)}</td>
              </tr>
            ))}
            {visible.length === 0 && (
              <tr><td colSpan={8} className="rounded-2xl bg-paper px-5 py-10 text-center text-abu">{kosong}</td></tr>
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
