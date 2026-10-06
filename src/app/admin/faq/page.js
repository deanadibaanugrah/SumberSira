"use client";

import { Pencil, Trash2 } from "lucide-react";
import { useState } from "react";

import { AdminHeader, Card, CardTitle, IconButton, Modal, PrimaryButton, inputClass } from "@/components/admin/ui";
import { FAQ, UNANSWERED } from "@/data/dummy";

// Admin 5/6: Chatbot / FAQ — jawaban yang tersimpan tampil otomatis di chatbot Tanya Sira.
export default function FaqPage() {
  const [faqs, setFaqs] = useState(FAQ);
  const [pending, setPending] = useState(UNANSWERED);
  const [form, setForm] = useState(null); // { id?, q, a, fromPending? }

  const save = (e) => {
    e.preventDefault();
    if (!form.q.trim() || !form.a.trim()) return;
    if (form.id && !form.fromPending) {
      setFaqs((all) => all.map((f) => (f.id === form.id ? { ...f, q: form.q, a: form.a } : f)));
    } else {
      setFaqs((all) => [...all, { id: Date.now(), q: form.q.trim(), a: form.a.trim() }]);
      if (form.fromPending) setPending((all) => all.filter((p) => p.id !== form.id));
    }
    setForm(null);
  };

  return (
    <>
      <AdminHeader title="Chatbot / FAQ"
                   action={<PrimaryButton onClick={() => setForm({ q: "", a: "" })}>+ Tambah FAQ</PrimaryButton>} />
      <main className="grid gap-5 p-6 lg:p-8 xl:grid-cols-[700fr_436fr]">
        <Card className="pt-5! xl:min-h-[700px]">
          <CardTitle>Daftar FAQ</CardTitle>
          <ul className="mt-[18px] space-y-4">
            {faqs.map((f) => (
              <li key={f.id} className="flex min-h-[76px] items-center gap-2 rounded-[10px] bg-mist pl-4 pr-3">
                <div className="flex-1 self-start pb-3 pt-3">
                  <p className="text-xs font-semibold text-ink">{f.q}</p>
                  <p className="mt-1.5 text-[10px] text-ink/65">Jawaban tersimpan — tampil otomatis di chatbot Tanya Sira</p>
                </div>
                <IconButton label="Edit FAQ" onClick={() => setForm({ ...f })}><Pencil size={13} /></IconButton>
                <IconButton label="Hapus FAQ" tone="coral" onClick={() => setFaqs((all) => all.filter((x) => x.id !== f.id))}>
                  <Trash2 size={13} />
                </IconButton>
              </li>
            ))}
          </ul>
        </Card>

        <Card className="pt-5! xl:min-h-[700px]">
          <CardTitle>Belum Terjawab</CardTitle>
          <ul className="mt-[22px] space-y-4">
            {pending.map((p) => (
              <li key={p.id} className="min-h-[84px] rounded-lg border border-leaf/30 bg-mist px-3.5 pb-2 pt-3">
                <p className="text-[11px] text-ink">{p.q}</p>
                <button type="button" onClick={() => setForm({ id: p.id, q: p.q, a: "", fromPending: true })}
                        className="mt-[21px] h-[26px] w-20 rounded-full bg-leaf text-[9.5px] font-semibold text-white hover:brightness-110">
                  Jawab
                </button>
              </li>
            ))}
            {pending.length === 0 && <li className="text-[11px] text-ink/60">Semua pertanyaan sudah dijawab. 🎉</li>}
          </ul>
        </Card>
      </main>

      {form && (
        <Modal title={form.fromPending ? "Jawab Pertanyaan" : form.id ? "Edit FAQ" : "Tambah FAQ"} onClose={() => setForm(null)}>
          <form onSubmit={save} className="space-y-3">
            <label className="block text-[11px] text-ink/70">Pertanyaan
              <input value={form.q} onChange={(e) => setForm({ ...form, q: e.target.value })} className={`${inputClass} mt-1`} required />
            </label>
            <label className="block text-[11px] text-ink/70">Jawaban
              <textarea value={form.a} onChange={(e) => setForm({ ...form, a: e.target.value })} rows={4}
                        className={`${inputClass} mt-1 h-auto! resize-none py-2`} required autoFocus />
            </label>
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
