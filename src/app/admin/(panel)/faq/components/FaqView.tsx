"use client";

import { Plus } from "lucide-react";
import { useState } from "react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import { FAQ, UNANSWERED } from "@/data/dummy";

import BelumTerjawab from "./BelumTerjawab";
import DaftarFaq from "./DaftarFaq";
import FormFaq from "./FormFaq";
import StatFaq from "./StatFaq";

// Admin 6/7: Chatbot & FAQ. Jawaban yang tersimpan dipakai otomatis oleh chatbot Tanya Sira.
// File ini memegang data dan pilihan pengguna, lalu menyusun bagian-bagiannya (StatFaq, DaftarFaq, BelumTerjawab, FormFaq).
export default function FaqView() {
  // Daftar FAQ, pertanyaan yang belum terjawab, dan isi form (null = form tertutup).
  const [faqs, setFaqs] = useState(FAQ);
  const [pending, setPending] = useState(UNANSWERED);
  const [form, setForm] = useState(null); // { id?, q, a, fromPending? }

  // Simpan form: kalau edit, ganti FAQ lama. Kalau baru atau menjawab pertanyaan pengunjung, tambahkan FAQ baru dan hapus dari daftar belum terjawab.
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

      <StatFaq faqCount={faqs.length} pendingCount={pending.length} />

      <div className="mt-5 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <DaftarFaq faqs={faqs} onEdit={(f) => setForm({ ...f })} onRemove={(id) => setFaqs((all) => all.filter((x) => x.id !== id))} />
        <BelumTerjawab pending={pending} onAnswer={(p) => setForm({ id: p.id, q: p.q, a: "", fromPending: true })} />
      </div>

      {form && <FormFaq form={form} onChange={setForm} onSave={save} onClose={() => setForm(null)} />}
    </>
  );
}
