"use client";

import { Plus } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import type { FormEvent } from "react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import type { AdminFaq, AdminUnanswered } from "@/lib/auth/dal";

import { hapusFaq, hapusPertanyaan, simpanFaq } from "../actions";
import AlurJawaban from "./AlurJawaban";
import BelumTerjawab from "./BelumTerjawab";
import DaftarFaq from "./DaftarFaq";
import FormFaq, { type FormState } from "./FormFaq";
import { kunciFaq } from "./kunci";
import StatFaq from "./StatFaq";

// Pesan untuk pengelola dari kode kesalahan backend.
function pesan(kode: string): string {
  if (kode === "VALIDATION") return "Isian belum lengkap atau terlalu panjang.";
  if (kode === "NOT_FOUND") return "FAQ atau pertanyaan sudah tidak ada. Daftar akan diperbarui.";
  if (kode === "UNAUTHORIZED") return "Sesi berakhir. Silakan login lagi.";
  if (kode === "FORBIDDEN") return "Hanya admin yang boleh mengubah FAQ.";
  if (kode === "BACKEND_UNREACHABLE") return "Tidak bisa terhubung ke server. Coba lagi sebentar lagi.";
  return "Gagal menyimpan. Coba lagi.";
}

// Admin 6/7: Chatbot & FAQ. Tanya Sira menjawab dari FAQ pengelola; pertanyaan yang belum cocok dicatat
// di daftar Belum Terjawab. Semua data dari backend (GET /admin/faq dan /admin/faq/unanswered).
export default function FaqView({ faqs, pending, error }: { faqs: AdminFaq[]; pending: AdminUnanswered[]; error: string | null }) {
  const [form, setForm] = useState<FormState | null>(null);
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const router = useRouter();

  // Nomor urut berikutnya untuk FAQ baru (backend memakai sortOrder).
  const urutanBaru = faqs.reduce((maks, f) => Math.max(maks, f.sortOrder ?? 0), 0) + 1;
  const faqAktif = faqs.filter((f) => f.active).length;

  const tambah = () => {
    setNotice(null);
    setForm({ mode: "faq", question: "", answer: "", keywords: "", active: true, sortOrder: urutanBaru });
  };

  const edit = (f: AdminFaq) => {
    setNotice(null);
    setForm({
      mode: "faq",
      id: f.id,
      question: f.keys[0] ?? "",
      answer: f.answer,
      keywords: f.keys.slice(1).join(", "),
      active: f.active,
      sortOrder: f.sortOrder,
    });
  };

  const jawab = (p: AdminUnanswered) => {
    setNotice(null);
    setForm({ mode: "jawab", id: p.id, question: p.question, answer: "", keywords: "", active: true, sortOrder: urutanBaru });
  };

  // Simpan FAQ baru/perubahan; untuk mode "jawab", pertanyaan asal dihapus setelah FAQ dibuat.
  const simpan = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!form || saving) return;
    const pertanyaan = form.question.trim();
    const jawaban = form.answer.trim();
    if (!pertanyaan || !jawaban) {
      setNotice("Pertanyaan dan jawaban wajib diisi.");
      return;
    }
    // Kata kunci = kata kunci tambahan + pertanyaan. Pertanyaan panjang dipecah menjadi frasa pendek
    // karena backend hanya menerima kunci maksimal 30 karakter (lihat kunci.ts).
    const keys = kunciFaq(pertanyaan, form.keywords.split(","));
    if (keys.length === 0) {
      setNotice("Tambahkan kata kunci yang lebih pendek (maksimal 30 karakter).");
      return;
    }

    setSaving(true);
    setNotice(null);
    const hasil = await simpanFaq({
      id: form.mode === "faq" ? form.id : undefined,
      keys,
      answer: jawaban,
      sortOrder: form.sortOrder,
      active: form.active,
    });
    if ("error" in hasil) {
      setNotice(pesan(hasil.error));
      setSaving(false);
      return;
    }
    if (form.mode === "jawab" && form.id) {
      const hapus = await hapusPertanyaan(form.id);
      if ("error" in hapus) setNotice(pesan(hapus.error));
    }
    setSaving(false);
    setForm(null);
    router.refresh();
  };

  // Hapus dengan konfirmasi, karena jawaban FAQ langsung dipakai chatbot dan tidak bisa dikembalikan.
  const hapusSatuFaq = async (id: string, q: string) => {
    if (!window.confirm(`Hapus FAQ ini?\n\n${q}`)) return;
    const hasil = await hapusFaq(id);
    if ("error" in hasil) {
      setNotice(pesan(hasil.error));
      return;
    }
    setNotice(null);
    router.refresh();
  };

  const hapusSatuPertanyaan = async (id: string, q: string) => {
    if (!window.confirm(`Hapus pertanyaan ini tanpa dijawab?\n\n${q}`)) return;
    const hasil = await hapusPertanyaan(id);
    if ("error" in hasil) {
      setNotice(pesan(hasil.error));
      return;
    }
    setNotice(null);
    router.refresh();
  };

  const pesanMuat = error === "BACKEND_UNREACHABLE"
    ? "Data chatbot belum bisa dimuat. Pastikan backend menyala, lalu muat ulang halaman."
    : "Data chatbot belum bisa dimuat. Coba muat ulang halaman.";

  return (
    <>
      <AdminHeader
        title="Chatbot & FAQ"
        subtitle="Atur jawaban cepat Tanya Sira dan pantau pertanyaan yang belum terjawab"
        action={<PrimaryButton icon={Plus} onClick={tambah}>Tambah FAQ</PrimaryButton>}
      />

      {(notice || error) && (
        <p role="alert" className="mt-6 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">
          {notice ?? pesanMuat}
        </p>
      )}

      <StatFaq faqAktif={faqAktif} pendingCount={pending.length} />
      <AlurJawaban />

      <div className="mt-5 grid grid-cols-1 gap-5 xl:grid-cols-[736fr_380fr]">
        <DaftarFaq faqs={faqs} ready={!error} onEdit={edit} onRemove={hapusSatuFaq} />
        <BelumTerjawab pending={pending} ready={!error} onAnswer={jawab} onRemove={hapusSatuPertanyaan} />
      </div>

      {form && <FormFaq form={form} saving={saving} notice={notice} onChange={setForm} onSave={simpan} onClose={() => setForm(null)} />}
    </>
  );
}
