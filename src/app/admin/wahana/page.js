"use client";

import { LifeBuoy, Package, Pencil, Plus, Ticket, Trash2 } from "lucide-react";
import { useMemo, useState } from "react";

import WahanaIcon from "@/components/WahanaIcon";
import { AdminHeader, Card, CardTitle, FilterPills, IconButton, Modal, PrimaryButton, SecondaryButton, StatCard, StatusPill, inputClass, labelClass } from "@/components/admin/ui";
import { WAHANA } from "@/data/wahana";
import { rupiah } from "@/lib/format";

// Admin 6/6: Wahana & Harga. Daftar sewa alat/wahana, filter kategori, tambah, edit, hapus.
const FILTERS = ["Semua", "Sewa Alat", "Wahana"];
const EMPTY = { name: "", category: "Wahana", price: "", unit: "", status: "Aktif" };
const CATEGORY_TAG = { "Sewa Alat": "bg-ink/[0.07] text-ink/75", Wahana: "bg-leaf/12 text-forest" };

export default function WahanaPage() {
  const [items, setItems] = useState(WAHANA);
  const [filter, setFilter] = useState("Semua");
  const [form, setForm] = useState(null);

  const visible = useMemo(() => items.filter((w) => filter === "Semua" || w.category === filter), [items, filter]);
  const count = (category) => items.filter((w) => w.category === category).length;

  const save = (e) => {
    e.preventDefault();
    const price = Number(form.price);
    if (!form.name.trim() || !(price > 0)) return;
    const clean = { ...form, name: form.name.trim(), unit: form.unit.trim(), price };
    setItems((all) => (form.id
      ? all.map((w) => (w.id === form.id ? { ...w, ...clean } : w))
      : [...all, { ...clean, id: `wahana-${Date.now()}`, icon: clean.category === "Sewa Alat" ? "ring" : "carousel" }]));
    setForm(null);
  };

  return (
    <>
      <AdminHeader title="Wahana & Harga" subtitle="Daftar alat sewa dan wahana beserta tarifnya"
                   action={<PrimaryButton icon={Plus} onClick={() => setForm(EMPTY)}>Tambah Wahana</PrimaryButton>} />

      <div className="mt-6 grid gap-5 sm:grid-cols-3">
        <StatCard icon={Package} solid value={items.length} label="Total item" />
        <StatCard icon={LifeBuoy} value={count("Sewa Alat")} label="Sewa alat" />
        <StatCard icon={Ticket} value={count("Wahana")} label="Wahana" />
      </div>

      <Card className="mt-5 px-4! pt-5!">
        <div className="px-2">
          <CardTitle>Daftar Wahana</CardTitle>
          <div className="mt-4"><FilterPills options={FILTERS} value={filter} onChange={setFilter} label="Filter kategori" /></div>
        </div>
        <div className="mt-4 overflow-x-auto">
          <table className="w-full min-w-[760px] border-separate border-spacing-y-2.5 text-left text-sm">
            <thead className="text-[13px] text-ink/60">
              <tr>
                <th className="w-[35%] pl-[60px] font-normal">Nama</th>
                <th className="w-[18%] font-normal">Kategori</th>
                <th className="w-[22%] font-normal">Harga</th>
                <th className="w-[13%] font-normal">Status</th>
                <th className="font-normal">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {visible.map((w) => (
                <tr key={w.id} className="bg-paper [&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl">
                  <td className="h-[52px] pl-3">
                    <span className="flex items-center gap-3">
                      <span className="grid size-9 shrink-0 place-items-center rounded-full bg-ink/[0.06] text-ink"><WahanaIcon name={w.icon} variant="admin" size={17} /></span>
                      <span className="text-[15px] font-semibold text-ink">{w.name}</span>
                    </span>
                  </td>
                  <td><span className={`inline-flex h-7 items-center rounded-full px-3 text-[13px] ${CATEGORY_TAG[w.category] ?? CATEGORY_TAG.Wahana}`}>{w.category}</span></td>
                  <td>
                    <span className="font-mono text-[15px] text-ink">{rupiah(w.price)}</span>
                    {w.unit && <span className="ml-1.5 text-[13px] text-ink/60">/ {w.unit}</span>}
                  </td>
                  <td><StatusPill status={w.status} /></td>
                  <td className="pr-3">
                    <div className="flex gap-2">
                      <IconButton label={`Edit ${w.name}`} onClick={() => setForm({ ...w, price: String(w.price) })}><Pencil size={16} /></IconButton>
                      <IconButton label={`Hapus ${w.name}`} tone="coral" onClick={() => setItems((all) => all.filter((x) => x.id !== w.id))}>
                        <Trash2 size={16} />
                      </IconButton>
                    </div>
                  </td>
                </tr>
              ))}
              {visible.length === 0 && (
                <tr><td colSpan={5} className="rounded-2xl bg-paper px-5 py-10 text-center text-ink/60">Belum ada item di kategori ini.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>

      {form && (
        <Modal title={form.id ? "Edit Wahana" : "Tambah Wahana"} onClose={() => setForm(null)}>
          <form onSubmit={save} className="space-y-3">
            <label className={labelClass}>Nama wahana
              <input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} className={`${inputClass} mt-1`} required autoFocus />
            </label>
            <div className="grid grid-cols-2 gap-3">
              <label className={labelClass}>Kategori
                <select value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })} className={`${inputClass} mt-1`}>
                  <option>Wahana</option><option>Sewa Alat</option>
                </select>
              </label>
              <label className={labelClass}>Status
                <select value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value })} className={`${inputClass} mt-1`}>
                  <option>Aktif</option><option>Nonaktif</option>
                </select>
              </label>
              <label className={labelClass}>Harga (Rp)
                <input type="number" min="0" step="500" value={form.price} onChange={(e) => setForm({ ...form, price: e.target.value })}
                       className={`${inputClass} mt-1`} required />
              </label>
              <label className={labelClass}>Satuan (opsional)
                <input value={form.unit} onChange={(e) => setForm({ ...form, unit: e.target.value })} placeholder="kepala / 15 menit"
                       className={`${inputClass} mt-1`} />
              </label>
            </div>
            <div className="flex justify-end gap-3 pt-2">
              <SecondaryButton onClick={() => setForm(null)}>Batal</SecondaryButton>
              <PrimaryButton type="submit" className="h-11!">Simpan</PrimaryButton>
            </div>
          </form>
        </Modal>
      )}
    </>
  );
}
