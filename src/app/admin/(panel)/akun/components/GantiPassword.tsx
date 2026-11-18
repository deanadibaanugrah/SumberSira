"use client";

import { useState } from "react";
import type { FormEvent } from "react";

import { Card, CardTitle, PrimaryButton, inputClass, labelClass } from "@/components/admin/ui";
import { changePasswordAction } from "@/lib/auth/actions";
import { PASSWORD_HINT, validatePassword } from "@/lib/validation/password";

// Pesan untuk kegagalan ganti password dari backend.
function pesanGalat(kode: string): string {
  if (kode === "INVALID_CREDENTIALS") return "Password lama salah.";
  if (kode === "VALIDATION") return "Password baru belum memenuhi syarat atau sama dengan email/password lama.";
  if (kode === "UNAUTHORIZED") return "Sesi berakhir. Silakan login lagi.";
  return "Tidak bisa terhubung ke server. Coba lagi sebentar lagi.";
}

// Form ganti password sendiri. Sesi di perangkat lain dicabut backend setelah berhasil.
export default function GantiPassword() {
  const [current, setCurrent] = useState("");
  const [baru, setBaru] = useState("");
  const [ulangi, setUlangi] = useState("");
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState<{ tone: "ok" | "error"; text: string } | null>(null);

  const simpan = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (saving) return;
    setNotice(null);
    const passwordError = validatePassword(baru);
    if (passwordError) {
      setNotice({ tone: "error", text: passwordError });
      return;
    }
    if (baru !== ulangi) {
      setNotice({ tone: "error", text: "Ulangi password baru dengan tepat." });
      return;
    }

    setSaving(true);
    const hasil = await changePasswordAction(current, baru);
    setSaving(false);
    if ("error" in hasil) {
      setNotice({ tone: "error", text: pesanGalat(hasil.error) });
      return;
    }
    setCurrent("");
    setBaru("");
    setUlangi("");
    setNotice({ tone: "ok", text: hasil.message });
  };

  return (
    <Card>
      <CardTitle sub="Setelah berhasil, perangkat lain yang masih login akan dikeluarkan">Ganti Password</CardTitle>
      <form onSubmit={simpan} className="mt-4 grid gap-3 sm:grid-cols-3">
        <label className={labelClass}>Password lama
          <input type="password" value={current} onChange={(e) => setCurrent(e.target.value)} className={`${inputClass} mt-1`} autoComplete="current-password" required />
        </label>
        <label className={labelClass}>Password baru
          <input type="password" value={baru} onChange={(e) => setBaru(e.target.value)} className={`${inputClass} mt-1`} minLength={8} maxLength={72} autoComplete="new-password" aria-describedby="syarat-password" required />
          <span id="syarat-password" className="mt-1 block font-sans text-[11px] font-normal text-abu">{PASSWORD_HINT}</span>
        </label>
        <label className={labelClass}>Ulangi password baru
          <input type="password" value={ulangi} onChange={(e) => setUlangi(e.target.value)} className={`${inputClass} mt-1`} minLength={8} maxLength={72} autoComplete="new-password" required />
        </label>
        <div className="sm:col-span-3 sm:flex sm:items-center sm:justify-between sm:gap-4">
          {notice ? (
            <p role={notice.tone === "error" ? "alert" : "status"}
               className={`rounded-xl px-4 py-2.5 text-sm ${notice.tone === "error" ? "bg-coral/12 text-coral" : "bg-leaf/12 text-forest"}`}>
              {notice.text}
            </p>
          ) : <span />}
          <PrimaryButton type="submit" className="w-full sm:w-auto" disabled={saving}>{saving ? "Menyimpan..." : "Ganti Password"}</PrimaryButton>
        </div>
      </form>
    </Card>
  );
}
