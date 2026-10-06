"use client";

import { useMemo, useState } from "react";

import { AdminHeader, Card, FilterPills, StatusPill, inputClass } from "@/components/admin/ui";
import { BOOKINGS } from "@/data/dummy";

// Admin 2/6: Booking Management — filter status, cari pemesan, detail, konfirmasi/tolak.
const FILTERS = ["Semua", "Baru", "Diproses", "Selesai"];
const NEXT_STATUS = { Baru: "Diproses", Diproses: "Selesai" };
// Lebar kolom tabel mengikuti desain (216 / 236 / 112 / sisa dari 816 px).
const COLUMNS = [
  { label: "Nama Pemesan", width: "26.5%" },
  { label: "Item Disewa", width: "28.9%" },
  { label: "Jam", width: "13.7%" },
  { label: "Status" },
];

export default function BookingManagementPage() {
  const [rows, setRows] = useState(BOOKINGS);
  const [filter, setFilter] = useState("Semua");
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState(3);

  const visible = useMemo(() => rows.filter((r) =>
    (filter === "Semua" || r.status === filter) && r.name.toLowerCase().includes(query.trim().toLowerCase())), [rows, filter, query]);
  const selected = rows.find((r) => r.id === selectedId) ?? null;

  const setStatus = (id, status) => setRows((all) => all.map((r) => (r.id === id ? { ...r, status } : r)));

  return (
    <>
      <AdminHeader title="Booking Management" />
      <main className="p-6 lg:p-8">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <FilterPills options={FILTERS} value={filter} onChange={setFilter} />
          <label className="w-full sm:w-[220px]">
            <span className="sr-only">Cari pemesan</span>
            <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Cari pemesan..." className={inputClass} />
          </label>
        </div>

        <div className="mt-5 grid gap-5 xl:grid-cols-[1fr_320px]">
          <Card className="overflow-x-auto p-0!">
            <table className="w-full min-w-[620px] table-fixed text-left text-[11px]">
              <colgroup>
                {COLUMNS.map((c) => <col key={c.label} style={c.width ? { width: c.width } : undefined} />)}
              </colgroup>
              <thead className="bg-mint text-ink/80">
                <tr>
                  {COLUMNS.map((c) => <th key={c.label} className="h-10 pl-5 font-semibold">{c.label}</th>)}
                </tr>
              </thead>
              <tbody>
                {visible.map((r) => (
                  <tr key={r.id} onClick={() => setSelectedId(r.id)} tabIndex={0}
                      onKeyDown={(e) => e.key === "Enter" && setSelectedId(r.id)}
                      className={`h-[52px] cursor-pointer border-t border-black/5 transition hover:bg-mint/50 ${r.id === selectedId ? "bg-mist" : ""}`}>
                    <td className="pl-5 font-medium text-ink">{r.name}</td>
                    <td className="pl-5 text-ink/70">{r.items}</td>
                    <td className="pl-5 font-mono text-[10.5px] text-ink">{r.time}</td>
                    <td className="pl-5"><StatusPill status={r.status} size="md" /></td>
                  </tr>
                ))}
                {visible.length === 0 && (
                  <tr><td colSpan={4} className="px-5 py-10 text-center text-ink/60">Tidak ada booking yang cocok.</td></tr>
                )}
              </tbody>
            </table>
          </Card>

          <Card className="flex flex-col pt-[18px]!">
            <h2 className="border-b border-black/10 pb-3.5 font-display text-[15px] font-semibold leading-tight">Detail Booking</h2>
            {selected ? (
              <>
                <dl className="mt-4 space-y-[9px]">
                  {[["Nama Pemesan", selected.name], ["Item Disewa", selected.items], ["Jumlah", selected.qty],
                    ["Jam Booking", selected.time], ["Status", selected.status]].map(([k, v]) => (
                    <div key={k}><dt className="text-[9px] text-ink/70">{k}</dt><dd className="text-[11.5px] text-ink">{v}</dd></div>
                  ))}
                </dl>
                <div className="mt-auto grid grid-cols-2 gap-3 pt-6">
                  <button type="button" disabled={!NEXT_STATUS[selected.status]}
                          onClick={() => setStatus(selected.id, NEXT_STATUS[selected.status])}
                          className="h-9 rounded-md bg-leaf text-[11px] font-semibold text-white transition enabled:hover:brightness-110 disabled:opacity-60">
                    Konfirmasi
                  </button>
                  <button type="button" disabled={selected.status === "Selesai" || selected.status === "Ditolak"}
                          onClick={() => setStatus(selected.id, "Ditolak")}
                          className="h-9 rounded-md border border-black/15 bg-white text-[11px] font-semibold text-ink transition enabled:hover:bg-coral-soft enabled:hover:text-coral disabled:opacity-60">
                    Tolak
                  </button>
                </div>
              </>
            ) : <p className="mt-4 text-[11px] text-ink/60">Pilih booking di tabel.</p>}
          </Card>
        </div>
      </main>
    </>
  );
}
