"use client";

import { Plus } from "lucide-react";
import { useMemo, useState, useTransition } from "react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import type { WahanaItem } from "@/lib/server/wahana-store";

import { hapusWahana, simpanWahana, type WahanaActionResult } from "../actions";
import DaftarWahana from "./DaftarWahana";
import FormWahana from "./FormWahana";
import PesanAkses from "./PesanAkses";
import StatWahana from "./StatWahana";

// Admin 7/7: Wahana & Harga. Daftar sewa alat/wahana, filter kategori, tambah, edit, hapus.
// Data datang dari server (DAL). Tambah/edit/hapus memanggil Server Action yang dicek perannya di server.
// File ini memegang data dan pilihan pengguna, lalu menyusun bagian-bagiannya (PesanAkses, StatWahana, DaftarWahana, FormWahana).
// Isi awal form saat menambah wahana baru.
const EMPTY = { name: "", category: "Wahana", price: "", unit: "", status: "Aktif" };
// Pesan untuk setiap penolakan dari Server Action.
const ERROR_TEXT = {
  UNAUTHORIZED: "Sesi login habis (401). Silakan masuk lagi.",
  FORBIDDEN: "Ditolak server (403 FORBIDDEN): hanya Pengelola (admin) yang boleh mengubah wahana dan harga.",
  INVALID: "Isian belum benar: nama wajib diisi, harga Rp500 sampai Rp1.000.000 (bilangan bulat).",
  NOT_FOUND: "Data wahana tidak ditemukan. Muat ulang halaman.",
};

// initialItems = data dari server, canEdit = peran ini boleh mengubah data (hanya untuk tampilan).
export default function WahanaView({ initialItems, canEdit }: { initialItems: WahanaItem[]; canEdit: boolean }) {
  // Data wahana, filter kategori, isi form (null = form tertutup), dan pesan error dari server.
  const [items, setItems] = useState(initialItems);
  const [filter, setFilter] = useState("Semua");
  const [form, setForm] = useState(null);
  const [error, setError] = useState("");
  const [pending, startTransition] = useTransition();

  // Wahana yang tampil sesuai filter kategori.
  const visible = useMemo(() => items.filter((w) => filter === "Semua" || w.category === filter), [items, filter]);

  // Terapkan hasil Server Action: berhasil = pakai daftar terbaru dari server, gagal = tampilkan alasannya.
  const apply = (result: WahanaActionResult, onSuccess?: () => void) => {
    if ("error" in result) {
      setError(ERROR_TEXT[result.error]);
    } else {
      setItems(result.items);
      setError("");
      onSuccess?.();
    }
  };

  // Simpan form lewat Server Action. Validasi tetap diulang di server.
  const save = (e) => {
    e.preventDefault();
    const payload = { ...form, price: Number(form.price) };
    startTransition(async () => apply(await simpanWahana(payload), () => setForm(null)));
  };

  // Hapus satu wahana lewat Server Action.
  const remove = (id: string) => startTransition(async () => apply(await hapusWahana(id)));

  return (
    <>
      <AdminHeader title="Wahana & Harga" subtitle="Daftar alat sewa dan wahana beserta tarifnya"
                   action={<PrimaryButton icon={Plus} onClick={() => { setForm(EMPTY); setError(""); }}>Tambah Wahana</PrimaryButton>} />

      <PesanAkses canEdit={canEdit} error={error} />

      <StatWahana items={items} />

      <DaftarWahana visible={visible} filter={filter} onFilter={setFilter}
                    onEdit={(w) => { setForm({ ...w, price: String(w.price) }); setError(""); }} onRemove={remove} />

      {form && (
        <FormWahana form={form} onChange={setForm} error={error} pending={pending} onSave={save}
                    onClose={() => { setForm(null); setError(""); }} />
      )}
    </>
  );
}
