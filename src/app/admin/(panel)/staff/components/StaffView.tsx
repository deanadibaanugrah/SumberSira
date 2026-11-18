"use client";

import { KeyRound, Pencil, Plus } from "lucide-react";
import { useState } from "react";
import type { FormEvent } from "react";

import { AdminHeader, Avatar, Card, CardTitle, IconButton, Modal, PrimaryButton, SecondaryButton, StatusPill, inputClass, labelClass } from "@/components/admin/ui";
import type { AdminStaff } from "@/models/admin";
import { ROLE_LABEL } from "@/lib/auth/roles";

import { resetPasswordStaff, simpanStaff } from "../actions";
import FormStaffBaru, { type FormStaff as IsiForm } from "./FormStaff";

// Format tanggal akun dibuat dalam WIB, contoh: 10 Okt 2026.
const TANGGAL = new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "short", year: "numeric", timeZone: "Asia/Jakarta" });
const tanggal = (iso: string) => {
  const t = new Date(iso);
  return Number.isNaN(t.getTime()) ? "-" : TANGGAL.format(t).replace(".", "");
};

const KOSONG: IsiForm = { name: "", email: "", role: "petugas", active: true, password: "" };

// Pesan untuk setiap penolakan Server Action.
function pesanGalat(kode: string): string {
  if (kode === "INVALID_STATE") return "Tidak bisa menonaktifkan atau menurunkan peran akun sendiri, atau admin aktif terakhir.";
  if (kode === "DUPLICATE") return "Email sudah dipakai akun lain.";
  if (kode === "INVALID") return "Isian belum benar. Nama wajib 1–60 karakter, peran harus dipilih, password 8–72 karakter.";
  if (kode === "NOT_FOUND") return "Akun sudah tidak ada. Muat ulang halaman.";
  if (kode === "UNAUTHORIZED") return "Sesi berakhir. Silakan login lagi.";
  if (kode === "FORBIDDEN") return "Hanya admin yang boleh mengelola akun petugas.";
  return "Tidak bisa terhubung ke server. Coba lagi sebentar lagi.";
}

// Halaman Akun Petugas: daftar akun, tambah, ubah peran/status, dan atur ulang password.
export default function StaffView({ staff, error, currentId }: { staff: AdminStaff[]; error: string | null; currentId: string }) {
  const [items, setItems] = useState(staff);
  const [form, setForm] = useState<IsiForm | null>(null);
  const [reset, setReset] = useState<AdminStaff | null>(null);
  const [password, setPassword] = useState("");
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);

  const terapkan = (hasil: Awaited<ReturnType<typeof simpanStaff>>) => {
    if ("error" in hasil) {
      setNotice(pesanGalat(hasil.error));
      return false;
    }
    setItems(hasil.items);
    setNotice(null);
    return true;
  };

  const simpan = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!form || saving) return;
    setSaving(true);
    const hasil = await simpanStaff(form);
    setSaving(false);
    if (terapkan(hasil)) setForm(null);
  };

  const simpanPassword = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!reset || saving) return;
    setSaving(true);
    const hasil = await resetPasswordStaff(reset.id, password);
    setSaving(false);
    if (terapkan(hasil)) {
      setReset(null);
      setPassword("");
    }
  };

  const adminAktif = items.filter((s) => s.role === "admin" && s.active).length;

  // Tombol aksi yang sama dipakai di tabel (layar lebar) dan kartu (HP).
  const aksi = (s: AdminStaff) => (
    <div className="flex gap-2">
      <IconButton label={`Ubah akun ${s.name}`} onClick={() => { setForm({ id: s.id, name: s.name, email: s.email, role: s.role, active: s.active, password: "" }); setNotice(null); }}>
        <Pencil size={16} />
      </IconButton>
      <IconButton label={`Atur ulang password ${s.name}`} tone="gray" onClick={() => { setReset(s); setPassword(""); setNotice(null); }}>
        <KeyRound size={16} />
      </IconButton>
    </div>
  );

  return (
    <>
      <AdminHeader
        title="Akun Petugas"
        subtitle="Kelola akun pengelola dan petugas loket"
        action={<PrimaryButton icon={Plus} onClick={() => { setForm({ ...KOSONG }); setNotice(null); }}>Tambah Akun</PrimaryButton>}
      />

      {error && (
        <p role="alert" className="mt-6 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">
          Daftar akun belum bisa dimuat. Pastikan backend menyala, lalu muat ulang halaman.
        </p>
      )}
      {notice && <p role="alert" className="mt-5 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">{notice}</p>}

      <Card className="mt-6 px-4! pt-5!">
        <div className="px-2">
          <CardTitle sub={`${items.length} akun · ${adminAktif} admin aktif`}>Daftar Akun</CardTitle>
        </div>

        {/* Di HP tabel diganti kartu agar peran, status, dan tombol aksi tetap terlihat. */}
        <ul className="mt-4 space-y-2 md:hidden">
          {items.map((s) => (
            <li key={s.id} className="rounded-2xl bg-paper p-3 animate-fade-up">
              <div className="flex items-start gap-3">
                <Avatar name={s.name} solid={s.role === "admin"} />
                <div className="min-w-0 flex-1">
                  <p className="truncate font-semibold text-ink">
                    {s.name} {s.id === currentId && <span className="ml-1 rounded-full bg-leaf/12 px-2 py-0.5 text-[11px] font-semibold text-forest">Akun ini</span>}
                  </p>
                  <p className="truncate text-[13px] text-abu">{s.email}</p>
                </div>
                <StatusPill status={s.active ? "Aktif" : "Nonaktif"} />
              </div>
              <div className="mt-2 flex flex-wrap items-center justify-between gap-2">
                <p className="text-xs text-abu">{ROLE_LABEL[s.role]} · dibuat {tanggal(s.createdAt)}</p>
                {aksi(s)}
              </div>
            </li>
          ))}
          {items.length === 0 && <li className="rounded-2xl bg-paper px-5 py-8 text-center text-sm text-abu">{error ? "Daftar akun belum bisa dimuat." : "Belum ada akun."}</li>}
        </ul>

        <div className="mt-4 hidden overflow-x-auto md:block">
          <table className="w-full min-w-[720px] border-separate border-spacing-y-2.5 text-left text-sm">
            <thead className="text-[13px] text-abu">
              <tr>
                <th className="w-[42%] pl-4 font-normal">Nama</th>
                <th className="w-[18%] font-normal">Peran</th>
                <th className="w-[14%] font-normal">Status</th>
                <th className="w-[16%] font-normal">Dibuat</th>
                <th className="font-normal">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {items.map((s) => (
                <tr key={s.id} className="rounded-2xl bg-paper animate-fade-up">
                  <td className="rounded-l-2xl py-3 pl-4">
                    <div className="flex items-center gap-3">
                      <Avatar name={s.name} solid={s.role === "admin"} />
                      <div className="min-w-0">
                        <p className="truncate font-semibold text-ink">
                          {s.name} {s.id === currentId && <span className="ml-1 rounded-full bg-leaf/12 px-2 py-0.5 text-[11px] font-semibold text-forest">Akun ini</span>}
                        </p>
                        <p className="truncate text-[13px] text-abu">{s.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="py-3 text-ink">{ROLE_LABEL[s.role]}</td>
                  <td className="py-3"><StatusPill status={s.active ? "Aktif" : "Nonaktif"} /></td>
                  <td className="py-3 text-[13px] text-abu">{tanggal(s.createdAt)}</td>
                  <td className="rounded-r-2xl py-3 pr-4">{aksi(s)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {items.length === 0 && <p className="mt-4 hidden px-2 text-sm text-abu md:block">{error ? "Daftar akun belum bisa dimuat." : "Belum ada akun."}</p>}
      </Card>

      {form && <FormStaffBaru form={form} saving={saving} notice={notice} onChange={setForm} onSave={simpan} onClose={() => { setForm(null); setNotice(null); }} />}

      {reset && (
        <Modal title="Atur Ulang Password" onClose={() => { setReset(null); setPassword(""); }}>
          <form onSubmit={simpanPassword} className="space-y-3">
            <p className="text-sm text-abu">Password baru untuk <span className="font-semibold text-ink">{reset.name}</span>. Semua sesi akun itu akan dicabut.</p>
            <label className={labelClass}>Password baru (8–72 karakter)
              <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className={`${inputClass} mt-1`} minLength={8} maxLength={72} required autoFocus />
            </label>
            {notice && <p role="alert" className="rounded-xl bg-coral/12 px-4 py-2.5 text-sm text-coral">{notice}</p>}
            <div className="flex justify-end gap-3 pt-2">
              <SecondaryButton disabled={saving} onClick={() => { setReset(null); setPassword(""); }}>Batal</SecondaryButton>
              <PrimaryButton type="submit" className="h-11!" disabled={saving}>{saving ? "Menyimpan..." : "Simpan Password"}</PrimaryButton>
            </div>
          </form>
        </Modal>
      )}
    </>
  );
}
