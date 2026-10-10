"use client";

import { Check, CalendarCheck, Clock, Download, TrendingUp, X } from "lucide-react";
import { useMemo, useState } from "react";

import WahanaIcon from "@/components/WahanaIcon";
import { AdminHeader, Avatar, Card, CardTitle, FilterPills, PrimaryButton, StatCard, StatusPill } from "@/components/admin/ui";
import { BOOKINGS, BOOKING_TOTALS } from "@/data/dummy";
import { WAHANA } from "@/data/wahana";
import { rupiah } from "@/lib/format";

// Admin 2/6: Booking Sewa & Wahana. Filter status, cari pemesan (kotak cari di header), detail, konfirmasi/tolak.
const FILTERS = ["Semua", "Baru", "Diproses", "Selesai"];
const NEXT_STATUS = { Baru: "Diproses", Diproses: "Selesai" };
const CONFIRM_LABEL = { Baru: "Konfirmasi Booking", Diproses: "Tandai Selesai" };
const CATALOG = Object.fromEntries(WAHANA.map((w) => [w.id, w]));

// Baris item + total dihitung dari katalog wahana, bukan diketik manual.
function lineItems(booking) {
  return booking.lines.map(({ id, qty }) => {
    const w = CATALOG[id];
    return { key: id, icon: w.icon, label: `${qty}x ${w.name}`, price: w.price * qty };
  });
}

export default function BookingManagementPage() {
  const [rows, setRows] = useState(BOOKINGS);
  const [filter, setFilter] = useState("Semua");
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState(1);

  const visible = useMemo(() => rows.filter((r) =>
    (filter === "Semua" || r.status === filter) && r.name.toLowerCase().includes(query.trim().toLowerCase())), [rows, filter, query]);
  const selected = rows.find((r) => r.id === selectedId) ?? null;
  const lines = selected ? lineItems(selected) : [];
  const total = lines.reduce((sum, l) => sum + l.price, 0);

  // Angka desain dipakai sebagai dasar; perubahan status di halaman ini ikut menggeser angkanya.
  const delta = (status) => rows.filter((r) => r.status === status).length - BOOKINGS.filter((r) => r.status === status).length;
  const setStatus = (id, status) => setRows((all) => all.map((r) => (r.id === id ? { ...r, status } : r)));

  return (
    <>
      <AdminHeader title="Booking Sewa & Wahana" subtitle="Kelola pesanan sewa alat dan wahana dari aplikasi"
                   action={<PrimaryButton icon={Download}>Export</PrimaryButton>}
                   search={{ value: query, onChange: setQuery, placeholder: "Cari nama pemesan..." }} />

      <div className="mt-6 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard icon={CalendarCheck} solid value={BOOKING_TOTALS.hariIni} label="Booking hari ini" />
        <StatCard icon={Clock} value={BOOKING_TOTALS.menunggu + delta("Baru")} label="Menunggu konfirmasi" />
        <StatCard icon={TrendingUp} value={BOOKING_TOTALS.diproses + delta("Diproses")} label="Sedang diproses" />
        <StatCard icon={Check} value={BOOKING_TOTALS.selesai + delta("Selesai")} label="Selesai" />
      </div>

      <div className="mt-5 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <Card className="flex flex-col px-4! pt-5!">
          <div className="px-2">
            <CardTitle>Daftar Booking</CardTitle>
            <div className="mt-4"><FilterPills options={FILTERS} value={filter} onChange={setFilter} label="Filter status booking" /></div>
            {/* Kotak cari di header hanya muncul di layar lebar; di layar kecil pakai kotak ini. */}
            <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Cari nama pemesan..." aria-label="Cari nama pemesan"
                   className="mt-3 h-10 w-full rounded-full bg-paper px-4 text-sm outline-none focus:ring-2 focus:ring-leaf/30 md:hidden" />
          </div>

          <div className="mt-4 overflow-x-auto">
            <table className="w-full min-w-[600px] border-separate border-spacing-y-2.5 text-left text-sm">
              <thead className="text-[13px] text-ink/60">
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
                    <tr key={r.id} onClick={() => setSelectedId(r.id)} tabIndex={0} aria-label={`Lihat detail booking ${r.name}`}
                        onKeyDown={(e) => e.key === "Enter" && setSelectedId(r.id)}
                        className={`cursor-pointer outline-none transition [&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl [&>td]:border-y-[1.5px] [&>td:first-child]:border-l-[1.5px] [&>td:last-child]:border-r-[1.5px] focus-visible:[&>td]:border-leaf ${
                          active ? "bg-leaf/[0.08] [&>td]:border-leaf" : "bg-paper hover:bg-leaf/[0.06] [&>td]:border-transparent"}`}>
                      <td className="h-[60px] pl-4">
                        <span className="flex items-center gap-3">
                          <span aria-hidden="true" className={`grid size-4 shrink-0 place-items-center rounded-[5px] border-[1.5px] ${active ? "border-forest bg-forest text-white" : "border-ink/30 bg-white"}`}>
                            {active && <Check size={11} strokeWidth={3} />}
                          </span>
                          <Avatar name={r.name} size={32} />
                          <span>
                            <span className="block font-semibold leading-tight text-ink">{r.name}</span>
                            <span className="block text-xs text-ink/60">{r.qty}</span>
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
                  <tr><td colSpan={4} className="rounded-2xl bg-paper px-5 py-10 text-center text-ink/60">Tidak ada booking yang cocok.</td></tr>
                )}
              </tbody>
            </table>
          </div>

          <div className="mt-auto flex flex-wrap items-center justify-between gap-3 px-2 pt-6">
            <p className="text-sm text-ink/60">Menampilkan {visible.length} dari {BOOKING_TOTALS.hariIni} booking</p>
            {/* Data contoh hanya satu halaman; nomor halaman lain ditampilkan sebagai gambaran. */}
            <div className="flex gap-2 text-sm font-semibold" aria-label="Halaman">
              {[1, 2, 3, 4].map((n) => (
                <span key={n} aria-current={n === 1 ? "page" : undefined}
                      className={`grid size-10 place-items-center rounded-full ${n === 1 ? "bg-forest text-white" : "bg-paper text-ink"}`}>{n}</span>
              ))}
            </div>
          </div>
        </Card>

        <Card className="flex flex-col pt-5!">
          <CardTitle right={selected && <span className="rounded-full bg-paper px-3 py-1.5 font-mono text-xs text-ink/80">{selected.code}</span>}>
            Detail Booking
          </CardTitle>
          {selected ? (
            <>
              <div className="mt-5 flex items-center gap-3 border-b border-ink/10 pb-5">
                <Avatar name={selected.name} size={52} solid />
                <div className="min-w-0 flex-1">
                  <p className="text-base font-semibold text-ink">{selected.name}</p>
                  <p className="text-[13px] text-ink/60">Pesan lewat aplikasi · {selected.orderedAt}</p>
                </div>
                <StatusPill status={selected.status} />
              </div>

              <dl className="mt-4 space-y-3">
                <div><dt className="text-[13px] text-ink/60">Waktu kunjungan</dt><dd className="mt-0.5 text-base font-semibold text-ink">{selected.visit}</dd></div>
                <div><dt className="text-[13px] text-ink/60">Kontak WhatsApp</dt><dd className="mt-0.5 text-base font-semibold text-ink">{selected.phone}</dd></div>
              </dl>

              <p className="mt-4 text-[13px] text-ink/60">Item disewa</p>
              <ul className="mt-2 space-y-2.5">
                {lines.map((l) => (
                  <li key={l.key} className="flex h-[52px] items-center gap-3 rounded-2xl bg-paper px-3">
                    <span className="grid size-8 shrink-0 place-items-center rounded-full bg-white text-forest"><WahanaIcon name={l.icon} variant="admin" size={15} /></span>
                    <span className="flex-1 text-sm font-semibold text-ink">{l.label}</span>
                    <span className="font-mono text-sm text-ink">{rupiah(l.price)}</span>
                  </li>
                ))}
              </ul>

              <div className="mt-5 flex items-end justify-between gap-3 border-t border-ink/10 pt-4">
                <div>
                  <p className="text-[13px] text-ink/60">Total pembayaran</p>
                  <p className="mt-1 font-mono text-[28px] font-medium leading-none text-ink">{rupiah(total)}</p>
                </div>
                <span className={`inline-flex h-7 items-center gap-1.5 rounded-full px-3 text-xs font-semibold ${selected.payment.includes("QRIS") ? "bg-leaf/15 text-forest" : "bg-ink/[0.07] text-ink/75"}`}>
                  <span className={`size-1.5 rounded-full ${selected.payment.includes("QRIS") ? "bg-leaf" : "bg-ink/50"}`} />{selected.payment}
                </span>
              </div>

              <div className="mt-auto space-y-3 pt-6">
                <PrimaryButton icon={Check} className="w-full" disabled={!NEXT_STATUS[selected.status]}
                               onClick={() => setStatus(selected.id, NEXT_STATUS[selected.status])}>
                  {CONFIRM_LABEL[selected.status] ?? "Sudah selesai"}
                </PrimaryButton>
                <button type="button" disabled={selected.status === "Selesai" || selected.status === "Ditolak"}
                        onClick={() => setStatus(selected.id, "Ditolak")}
                        className="flex h-11 w-full items-center justify-center gap-2 rounded-full border-[1.5px] border-coral text-sm font-semibold text-coral transition enabled:hover:bg-coral/10 disabled:opacity-40">
                  <X size={17} aria-hidden="true" /> Tolak
                </button>
              </div>
            </>
          ) : <p className="mt-4 text-sm text-ink/60">Pilih booking di tabel.</p>}
        </Card>
      </div>
    </>
  );
}
