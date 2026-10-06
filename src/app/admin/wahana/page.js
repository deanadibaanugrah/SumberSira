"use client";

import { Pencil, Trash2 } from "lucide-react";
import { useState } from "react";

import { AdminHeader, Card, IconButton, Modal, PrimaryButton, StatusPill, inputClass } from "@/components/admin/ui";
import { WAHANA } from "@/data/wahana";
import { rupiah } from "@/lib/format";

// Admin 6/6: Wahana & Harga — daftar sewa alat/wahana, tambah, edit, hapus.
const EMPTY = { name: "", category: "Wahana", price: "", unit: "", status: "Aktif" };
// Lebar kolom mengikuti desain (360 / 220 / 260 / 140 / sisa dari 1156 px).
const COLUMNS = [
  { label: "Nama Wahana", width: "31.1%" },
  { label: "Kategori", width: "19%" },
  { label: "Harga", width: "22.5%" },
  { label: "Status", width: "12.1%" },
  { label: "Aksi" },
];
const labelClass = "block text-[11px] text-ink/70";

export default function WahanaPage() {
  const [items, setItems] = useState(WAHANA);
  const [form, setForm] = useState(null);

  const save = (e) => {
    e.preventDefault();
    const price = Number(form.price);
    if (!form.name.trim() || !(price > 0)) return;
    const clean = { ...form, name: form.name.trim(), unit: form.unit.trim(), price };
    setItems((all) => (form.id
      ? all.map((w) => (w.id === form.id ? { ...w, ...clean } : w))
      : [...all, { ...clean, id: `wahana-${Date.now()}`, icon: "ring" }]));
    setForm(null);
  };

  return (
    <>
      <AdminHeader title="Wahana & Harga"
                   action={<PrimaryButton onClick={() => setForm(EMPTY)}>+ Tambah Wahana</PrimaryButton>} />
      <main className="p-6 lg:p-8">
        <Card className="overflow-x-auto p-0!">
          <table className="w-full min-w-[720px] table-fixed text-left">
            <colgroup>
              {COLUMNS.map((c) => <col key={c.label} style={c.width ? { width: c.width } : undefined} />)}
            </colgroup>
            <thead className="bg-leaf/15 text-[11px] text-ink/80">
              <tr>
                {COLUMNS.map((c) => <th key={c.label} className="h-10 pl-5 font-semibold">{c.label}</th>)}
              </tr>
            </thead>
            <tbody>
              {items.map((w) => (
                <tr key={w.id} className="h-[52px] border-t border-black/5">
                  <td className="pl-5 text-xs text-ink">{w.name}</td>
                  <td className="pl-5 text-[11px] text-ink/70">{w.category}</td>
                  <td className="pl-5 font-mono text-[11px] text-ink">{rupiah(w.price)}{w.unit ? ` / ${w.unit}` : ""}</td>
                  <td className="pl-5"><StatusPill status={w.status} size="tag" /></td>
                  <td className="pl-5">
                    <div className="flex gap-2">
                      <IconButton label={`Edit ${w.name}`} onClick={() => setForm({ ...w, price: String(w.price) })}><Pencil size={13} /></IconButton>
                      <IconButton label={`Hapus ${w.name}`} tone="coral" onClick={() => setItems((all) => all.filter((x) => x.id !== w.id))}>
                        <Trash2 size={13} />
                      </IconButton>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      </main>

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
              <button type="button" onClick={() => setForm(null)} className="h-8 rounded-md px-4 text-[11px] font-semibold text-ink/70 hover:bg-paper">Batal</button>
              <PrimaryButton type="submit" className="min-w-0!">Simpan</PrimaryButton>
            </div>
          </form>
        </Modal>
      )}
    </>
  );
}
