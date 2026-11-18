import { Pencil, Trash2 } from "lucide-react";

import { Card, CardTitle, IconButton, StatusPill } from "@/components/admin/ui";
import type { AdminFaq } from "@/lib/auth/dal";

type DaftarFaqProps = {
  faqs: AdminFaq[];
  ready: boolean;
  onEdit: (faq: AdminFaq) => void;
  onRemove: (id: string, question: string) => void;
};

// Daftar FAQ pengelola: dicek lebih dulu oleh Tanya Sira. Kata kunci pertama tampil sebagai pertanyaan.
export default function DaftarFaq({ faqs, ready, onEdit, onRemove }: DaftarFaqProps) {
  return (
    <Card className="px-4! pt-5!">
      <CardTitle className="px-2" sub="Dicek paling dulu oleh Tanya Sira, jawabannya cepat dan tanpa AI">Daftar FAQ</CardTitle>
      <ol className="mt-5 space-y-3">
        {faqs.map((f, i) => {
          const judul = f.keys[0] ?? "(tanpa kata kunci)";
          const kataLain = f.keys.slice(1);
          return (
            <li key={f.id} className="flex min-h-20 items-center gap-4 rounded-2xl bg-paper py-3 pl-4 pr-3 animate-fade-up">
              <span className="grid size-8 shrink-0 place-items-center rounded-full bg-leaf/12 text-sm font-semibold text-forest">{i + 1}</span>
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-2">
                  <p className="text-[15px] font-semibold leading-snug text-ink">{judul}</p>
                  <StatusPill status={f.active ? "Aktif" : "Nonaktif"} />
                </div>
                <p className="mt-1 text-sm text-abu">{f.answer}</p>
                {kataLain.length > 0 && <p className="mt-1.5 text-xs text-abu/80">Kata kunci: {kataLain.join(", ")}</p>}
              </div>
              <IconButton label={`Edit FAQ: ${judul}`} onClick={() => onEdit(f)}><Pencil size={16} /></IconButton>
              <IconButton label={`Hapus FAQ: ${judul}`} tone="coral" onClick={() => onRemove(f.id, judul)}>
                <Trash2 size={16} />
              </IconButton>
            </li>
          );
        })}
      </ol>
      {faqs.length === 0 && (
        <p className="mt-4 px-2 text-sm text-abu">{ready ? "Belum ada FAQ. Tambahkan lewat tombol Tambah FAQ." : "FAQ belum bisa dimuat."}</p>
      )}
    </Card>
  );
}
