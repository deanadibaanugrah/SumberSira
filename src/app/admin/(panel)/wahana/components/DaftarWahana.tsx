import { Pencil, Trash2 } from "lucide-react";

import WahanaIcon from "@/components/WahanaIcon";
import { Card, CardTitle, FilterPills, IconButton, StatusPill } from "@/components/admin/ui";
import { rupiah } from "@/lib/format";
import type { WahanaItem } from "@/lib/server/wahana-store";

// Pilihan filter kategori.
const FILTERS = ["Semua", "Sewa Alat", "Wahana"];
// Warna label kategori di tabel.
const CATEGORY_TAG = { "Sewa Alat": "bg-paper text-abu", Wahana: "bg-leaf/12 text-forest" };

type DaftarWahanaProps = {
  visible: WahanaItem[];
  filter: string;
  onFilter: (value: string) => void;
  onEdit: (item: WahanaItem) => void;
  onRemove: (id: string) => void;
};

// Tabel daftar wahana dengan filter kategori serta tombol edit dan hapus.
export default function DaftarWahana({ visible, filter, onFilter, onEdit, onRemove }: DaftarWahanaProps) {
  return (
    <Card className="mt-5 px-4! pt-5!">
      <div className="px-2">
        <CardTitle>Daftar Wahana</CardTitle>
        <div className="mt-4"><FilterPills options={FILTERS} value={filter} onChange={onFilter} label="Filter kategori" /></div>
      </div>
      <div className="mt-4 overflow-x-auto">
        {/* Tabel daftar wahana */}
        <table className="w-full min-w-[760px] border-separate border-spacing-y-2.5 text-left text-sm">
          <thead className="text-[13px] text-abu">
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
                    <span className="grid size-9 shrink-0 place-items-center rounded-full bg-paper text-ink"><WahanaIcon name={w.icon} variant="admin" size={17} /></span>
                    <span className="text-[15px] font-semibold text-ink">{w.name}</span>
                  </span>
                </td>
                <td><span className={`inline-flex h-7 items-center rounded-full px-3 text-[13px] ${CATEGORY_TAG[w.category] ?? CATEGORY_TAG.Wahana}`}>{w.category}</span></td>
                <td>
                  <span className="font-mono text-[15px] text-ink">{rupiah(w.price)}</span>
                  {w.unit && <span className="ml-1.5 text-[13px] text-abu">/ {w.unit}</span>}
                </td>
                <td><StatusPill status={w.status} /></td>
                <td className="pr-3">
                  <div className="flex gap-2">
                    {/* Tombol edit (buka form berisi data wahana) dan hapus */}
                    <IconButton label={`Edit ${w.name}`} onClick={() => onEdit(w)}><Pencil size={16} /></IconButton>
                    <IconButton label={`Hapus ${w.name}`} tone="coral" onClick={() => onRemove(w.id)}>
                      <Trash2 size={16} />
                    </IconButton>
                  </div>
                </td>
              </tr>
            ))}
            {visible.length === 0 && (
              <tr><td colSpan={5} className="rounded-2xl bg-paper px-5 py-10 text-center text-abu">Belum ada item di kategori ini.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </Card>
  );
}
