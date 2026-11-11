"use client";

import { Plus } from "lucide-react";
import { useState } from "react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import { ApiError } from "@/lib/live/http";
import { answerQuestion, deleteFaq, deleteQuestion, saveFaq, useChat } from "@/lib/chat-store";

import AlurJawaban from "./AlurJawaban";
import BelumTerjawab from "./BelumTerjawab";
import DaftarFaq from "./DaftarFaq";
import FormFaq, { type FormState } from "./FormFaq";
import StatFaq from "./StatFaq";

// Pesan untuk pengelola dari kode kesalahan backend.
function pesan(e: unknown): string {
  const code = e instanceof ApiError ? e.code : "";
  if (code === "ALREADY_ANSWERED_OR_MISSING") return "Pertanyaan ini sudah dijawab atau dihapus. Daftar akan diperbarui.";
  if (code === "NETWORK" || code === "BACKEND_UNREACHABLE") return "Tidak bisa terhubung ke server. Coba lagi sebentar lagi.";
  if (code === "VALIDATION") return "Isian belum lengkap atau terlalu panjang.";
  return "Gagal menyimpan. Coba lagi.";
}

// Admin 6/7: Chatbot & FAQ. Tanya Sira menjawab pengunjung dengan tiga lapis: FAQ buatan pengelola (cepat, tanpa AI),
// AI yang berpikir dari data Sumber Sira, lalu pertanyaan yang dikirim langsung ke pengelola (lambat, ditulis manusia).
// File ini memegang data dan pilihan pengguna, lalu menyusun bagian-bagiannya.
export default function FaqView() {
  const { data, ready, error, refresh } = useChat();
  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);

  // Simpan form: tambah/ubah FAQ, atau menjawab pertanyaan pengunjung (opsional sekaligus jadi FAQ).
  const save = async (e) => {
    e.preventDefault();
    if (!form || !form.question.trim() || !form.answer.trim() || saving) return;
    setSaving(true);
    setNotice(null);
    try {
      if (form.mode === "jawab") await answerQuestion(form.id, form.answer.trim(), form.saveAsFaq);
      else await saveFaq({ question: form.question.trim(), answer: form.answer.trim(), keywords: form.keywords.trim() }, form.id);
      setForm(null);
    } catch (err) {
      setNotice(pesan(err));
      if (err instanceof ApiError && err.code === "ALREADY_ANSWERED_OR_MISSING") {
        setForm(null);
        void refresh();
      }
    } finally {
      setSaving(false);
    }
  };

  // Hapus dengan konfirmasi, karena jawaban FAQ langsung dipakai chatbot dan tidak bisa dikembalikan.
  const hapusFaq = async (id: string, q: string) => {
    if (!window.confirm(`Hapus FAQ ini?\n\n${q}`)) return;
    try { await deleteFaq(id); } catch (err) { setNotice(pesan(err)); }
  };
  const hapusPertanyaan = async (id: string, q: string) => {
    if (!window.confirm(`Hapus pertanyaan ini tanpa dijawab?\n\n${q}`)) return;
    try { await deleteQuestion(id); } catch (err) { setNotice(pesan(err)); }
  };

  const faqs = data?.faqs ?? [];
  const pending = data?.pending ?? [];

  return (
    <>
      <AdminHeader title="Chatbot & FAQ" subtitle="Atur jawaban cepat Tanya Sira dan balas pertanyaan pengunjung"
                   action={<PrimaryButton icon={Plus} onClick={() => { setNotice(null); setForm({ mode: "faq", question: "", answer: "", keywords: "" }); }}>Tambah FAQ</PrimaryButton>} />

      {(notice || (error && !data)) && (
        <p role="alert" className="mt-6 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">
          {notice ?? "Data chatbot belum bisa dimuat. Pastikan backend menyala, lalu muat ulang halaman."}
        </p>
      )}

      <StatFaq stats={data?.stats ?? null} faqCount={faqs.length} pendingCount={pending.length} />
      <AlurJawaban aiActive={data?.stats.aiActive ?? null} />

      <div className="mt-5 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <DaftarFaq faqs={faqs} ready={ready}
                   onEdit={(f) => { setNotice(null); setForm({ mode: "faq", id: f.id, question: f.question, answer: f.answer, keywords: f.keywords }); }}
                   onRemove={hapusFaq} />
        <BelumTerjawab pending={pending} answered={data?.answered ?? []} ready={ready}
                       onAnswer={(p) => { setNotice(null); setForm({ mode: "jawab", id: p.id, question: p.question, answer: "", saveAsFaq: true }); }}
                       onRemove={hapusPertanyaan} />
      </div>

      {form && <FormFaq form={form} saving={saving} notice={notice} onChange={setForm} onSave={save} onClose={() => setForm(null)} />}
    </>
  );
}
