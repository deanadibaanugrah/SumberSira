import { Pencil, Trash2 } from "lucide-react";

import { Card, CardTitle, IconButton } from "@/components/admin/ui";
import type { FAQ } from "@/data/dummy";

type DaftarFaqProps = {
  faqs: typeof FAQ;
  onEdit: (faq: (typeof FAQ)[number]) => void;
  onRemove: (id: number) => void;
};

// Daftar FAQ yang dipakai chatbot, dengan tombol edit dan hapus.
export default function DaftarFaq({ faqs, onEdit, onRemove }: DaftarFaqProps) {
  return (
    <Card className="px-4! pt-5!">
      <CardTitle className="px-2" sub="Dipakai Tanya Sira untuk menjawab pengunjung">Daftar FAQ</CardTitle>
      {/* Daftar FAQ yang dipakai chatbot */}
      <ol className="mt-5 space-y-3">
        {faqs.map((f, i) => (
          <li key={f.id} className="flex min-h-20 items-center gap-4 rounded-2xl bg-paper py-3 pl-4 pr-3 animate-fade-up">
            <span className="grid size-8 shrink-0 place-items-center rounded-full bg-leaf/12 text-sm font-semibold text-forest">{i + 1}</span>
            <div className="min-w-0 flex-1">
              <p className="text-[15px] font-semibold leading-snug text-ink">{f.q}</p>
              <p className="mt-1 text-sm text-ink/70">{f.a}</p>
            </div>
            {/* Tombol edit dan hapus FAQ */}
            <IconButton label={`Edit FAQ: ${f.q}`} onClick={() => onEdit(f)}><Pencil size={16} /></IconButton>
            <IconButton label={`Hapus FAQ: ${f.q}`} tone="coral" onClick={() => onRemove(f.id)}>
              <Trash2 size={16} />
            </IconButton>
          </li>
        ))}
      </ol>
      {faqs.length === 0 && <p className="mt-4 px-2 text-sm text-ink/60">Belum ada FAQ. Tambahkan lewat tombol Tambah FAQ.</p>}
    </Card>
  );
}
