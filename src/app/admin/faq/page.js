"use client";

import { Clock, MessageCircle, Pencil, Plus, Sparkles, Trash2 } from "lucide-react";
import { useState } from "react";

import { AdminHeader, Card, CardTitle, IconButton, Modal, PrimaryButton, SecondaryButton, StatCard, inputClass, labelClass } from "@/components/admin/ui";
import { FAQ, FAQ_AUTO_RATE, UNANSWERED } from "@/data/dummy";

// Admin 5/6: Chatbot & FAQ. Jawaban yang tersimpan dipakai otomatis oleh chatbot Tanya Sira.
export default function FaqPage() {
  const [faqs, setFaqs] = useState(FAQ);
  const [pending, setPending] = useState(UNANSWERED);
  const [form, setForm] = useState(null); // { id?, q, a, fromPending? }

  const save = (e) => {
    e.preventDefault();
    if (!form.q.trim() || !form.a.trim()) return;
    if (form.id && !form.fromPending) {
      setFaqs((all) => all.map((f) => (f.id === form.id ? { ...f, q: form.q.trim(), a: form.a.trim() } : f)));
    } else {
      setFaqs((all) => [...all, { id: Date.now(), q: form.q.trim(), a: form.a.trim() }]);
      if (form.fromPending) setPending((all) => all.filter((p) => p.id !== form.id));
    }
    setForm(null);
  };

  return (
    <>
      <AdminHeader title="Chatbot & FAQ" subtitle="Atur jawaban Tanya Sira dan pertanyaan pengunjung"
                   action={<PrimaryButton icon={Plus} onClick={() => setForm({ q: "", a: "" })}>Tambah FAQ</PrimaryButton>} />

      <div className="mt-6 grid gap-5 sm:grid-cols-3">
        <StatCard icon={MessageCircle} solid value={faqs.length} label="FAQ aktif" />
        <StatCard icon={Clock} value={pending.length} label="Belum terjawab" />
        <StatCard icon={Sparkles} value={`${FAQ_AUTO_RATE}%`} label="Dijawab otomatis oleh AI" />
      </div>

      <div className="mt-5 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <Card className="px-4! pt-5!">
          <CardTitle className="px-2" sub="Dipakai Tanya Sira untuk menjawab pengunjung">Daftar FAQ</CardTitle>
          <ol className="mt-5 space-y-3">
            {faqs.map((f, i) => (
              <li key={f.id} className="flex min-h-20 items-center gap-4 rounded-2xl bg-paper py-3 pl-4 pr-3 animate-fade-up">
                <span className="grid size-8 shrink-0 place-items-center rounded-full bg-leaf/12 text-sm font-semibold text-forest">{i + 1}</span>
                <div className="min-w-0 flex-1">
                  <p className="text-[15px] font-semibold leading-snug text-ink">{f.q}</p>
                  <p className="mt-1 text-sm text-ink/70">{f.a}</p>
                </div>
                <IconButton label={`Edit FAQ: ${f.q}`} onClick={() => setForm({ ...f })}><Pencil size={16} /></IconButton>
                <IconButton label={`Hapus FAQ: ${f.q}`} tone="coral" onClick={() => setFaqs((all) => all.filter((x) => x.id !== f.id))}>
                  <Trash2 size={16} />
                </IconButton>
              </li>
            ))}
          </ol>
          {faqs.length === 0 && <p className="mt-4 px-2 text-sm text-ink/60">Belum ada FAQ. Tambahkan lewat tombol Tambah FAQ.</p>}
        </Card>

        <section className="flex flex-col rounded-3xl bg-forest p-5 text-white">
          <div className="flex items-start justify-between gap-3 px-1">
            <div>
              <h2 className="text-lg font-semibold leading-tight">Belum Terjawab</h2>
              <p className="mt-1.5 text-[13px] text-white/70">Pertanyaan yang belum bisa dijawab Tanya Sira</p>
            </div>
            {pending.length > 0 && (
              <span className="shrink-0 rounded-full bg-coral px-3 py-1.5 text-xs font-semibold leading-none">{pending.length} pertanyaan</span>
            )}
          </div>
          <ul className="mt-5 space-y-3">
            {pending.map((p) => (
              <li key={p.id} className="flex items-center gap-3 rounded-2xl bg-white/[0.08] p-4 animate-fade-up">
                <div className="min-w-0 flex-1">
                  <p className="text-[15px] font-semibold leading-snug">{p.q}</p>
                  <p className="mt-2 text-[13px] text-white/60">Ditanyakan {p.asked}x minggu ini</p>
                </div>
                <button type="button" onClick={() => setForm({ id: p.id, q: p.q, a: "", fromPending: true })}
                        className="h-10 shrink-0 rounded-full bg-white px-4 text-[13px] font-semibold text-forest transition hover:bg-white/90">
                  Jawab
                </button>
              </li>
            ))}
            {pending.length === 0 && <li className="rounded-2xl bg-white/[0.08] p-4 text-sm text-white/80">Semua pertanyaan sudah dijawab. 🎉</li>}
          </ul>
          <p className="mt-auto px-1 pt-6 text-[13px] text-white/60">Jawaban baru langsung dipakai Tanya Sira di aplikasi pengunjung.</p>
        </section>
      </div>

      {form && (
        <Modal title={form.fromPending ? "Jawab Pertanyaan" : form.id ? "Edit FAQ" : "Tambah FAQ"} onClose={() => setForm(null)}>
          <form onSubmit={save} className="space-y-3">
            <label className={labelClass}>Pertanyaan
              <input value={form.q} onChange={(e) => setForm({ ...form, q: e.target.value })} className={`${inputClass} mt-1`} required />
            </label>
            <label className={labelClass}>Jawaban
              <textarea value={form.a} onChange={(e) => setForm({ ...form, a: e.target.value })} rows={4}
                        className={`${inputClass} mt-1 h-auto! resize-none py-2.5`} required autoFocus />
            </label>
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
