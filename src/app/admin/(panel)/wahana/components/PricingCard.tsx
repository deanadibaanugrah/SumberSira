"use client";

import { Pencil } from "lucide-react";
import { useState } from "react";
import type { FormEvent } from "react";

import { Card, CardTitle, PrimaryButton, SecondaryButton, inputClass, labelClass } from "@/components/admin/ui";
import type { AdminPricing } from "@/lib/auth/dal";
import { rupiah } from "@/lib/format";

import { simpanPricing } from "../actions";

// Isian form dalam bentuk teks supaya pengguna bisa mengosongkan dulu sebelum mengetik.
type Isian = { ticketPricePerPerson: string; capacity: string; motor: string; mobil: string; bus: string };

const isianDari = (p: AdminPricing): Isian => ({
  ticketPricePerPerson: String(p.ticketPricePerPerson),
  capacity: String(p.capacity),
  motor: String(p.parking.motor),
  mobil: String(p.parking.mobil),
  bus: String(p.parking.bus),
});

// Bagian harga tiket masuk, kapasitas, dan parkir. Admin dan petugas boleh melihat; hanya admin
// yang mendapat tombol ubah (server juga menolak petugas dengan FORBIDDEN).
export default function PricingCard({ pricing, error, canEdit }: { pricing: AdminPricing | null; error: string | null; canEdit: boolean }) {
  const [data, setData] = useState(pricing);
  const [form, setForm] = useState<Isian | null>(null);
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);

  const ubah = (key: keyof Isian, value: string) => form && setForm({ ...form, [key]: value });

  const simpan = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!form || saving) return;
    const angka = (v: string) => (v.trim() === "" ? NaN : Number(v));
    const hasil = await simpanPricing({
      ticketPricePerPerson: angka(form.ticketPricePerPerson),
      capacity: angka(form.capacity),
      parking: { motor: angka(form.motor), mobil: angka(form.mobil), bus: angka(form.bus) },
    });
    if ("error" in hasil) {
      setNotice(
        hasil.error === "FORBIDDEN"
          ? "Hanya Pengelola (admin) yang boleh mengubah harga."
          : hasil.error === "UNAUTHORIZED"
            ? "Sesi login habis. Silakan masuk lagi."
            : hasil.error === "BACKEND_UNREACHABLE"
              ? "Tidak bisa terhubung ke server. Coba lagi sebentar lagi."
              : "Isian belum benar: tiket Rp500–Rp1.000.000, kapasitas 1–100.000, parkir Rp0–Rp1.000.000 (bilangan bulat).",
      );
      return;
    }
    setData(hasil.pricing);
    setForm(null);
    setNotice(null);
  };

  return (
    <Card className="mt-5">
      <CardTitle
        sub="Berlaku untuk pembelian tiket di aplikasi dan loket"
        right={canEdit && !form && data ? <PrimaryButton icon={Pencil} onClick={() => { setForm(isianDari(data)); setNotice(null); }}>Ubah Harga</PrimaryButton> : undefined}
      >
        Harga Tiket &amp; Parkir
      </CardTitle>

      {error && <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">Harga belum bisa dimuat. Pastikan backend menyala, lalu muat ulang halaman.</p>}
      {notice && <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">{notice}</p>}

      {!form && data && (
        <dl className="mt-5 grid gap-2 text-sm sm:grid-cols-2">
          {[
            ["Tiket masuk per orang", rupiah(data.ticketPricePerPerson)],
            ["Kapasitas harian", `${data.capacity} orang`],
            ["Parkir motor", rupiah(data.parking.motor)],
            ["Parkir mobil", rupiah(data.parking.mobil)],
            ["Parkir bus", rupiah(data.parking.bus)],
            ["Jalan kaki", "Gratis"],
          ].map(([label, value]) => (
            <div key={label} className="flex items-center justify-between gap-4 rounded-2xl bg-paper px-4 py-3">
              <dt className="text-abu">{label}</dt>
              <dd className="font-semibold tabular-nums text-ink">{value}</dd>
            </div>
          ))}
        </dl>
      )}

      {!canEdit && <p className="mt-4 flex items-start gap-2 text-xs text-abu">Akun Petugas Loket hanya bisa melihat harga. Perubahan hanya oleh Pengelola.</p>}

      {form && (
        <form onSubmit={simpan} className="mt-5 space-y-3">
          <div className="grid gap-3 sm:grid-cols-2">
            <label className={labelClass}>Tiket masuk per orang (Rp)
              <input type="number" min={500} max={1000000} step={1} required value={form.ticketPricePerPerson}
                     onChange={(e) => ubah("ticketPricePerPerson", e.target.value)} className={`${inputClass} mt-1`} />
            </label>
            <label className={labelClass}>Kapasitas harian (orang)
              <input type="number" min={1} max={100000} step={1} required value={form.capacity}
                     onChange={(e) => ubah("capacity", e.target.value)} className={`${inputClass} mt-1`} />
            </label>
            <label className={labelClass}>Parkir motor (Rp)
              <input type="number" min={0} max={1000000} step={1} required value={form.motor}
                     onChange={(e) => ubah("motor", e.target.value)} className={`${inputClass} mt-1`} />
            </label>
            <label className={labelClass}>Parkir mobil (Rp)
              <input type="number" min={0} max={1000000} step={1} required value={form.mobil}
                     onChange={(e) => ubah("mobil", e.target.value)} className={`${inputClass} mt-1`} />
            </label>
            <label className={labelClass}>Parkir bus (Rp)
              <input type="number" min={0} max={1000000} step={1} required value={form.bus}
                     onChange={(e) => ubah("bus", e.target.value)} className={`${inputClass} mt-1`} />
            </label>
            <div className={labelClass}>Jalan kaki
              <p className="mt-1 flex h-11 items-center rounded-xl bg-paper px-4 text-sm text-abu">Gratis (tetap 0)</p>
            </div>
          </div>
          <div className="flex justify-end gap-2 pt-1">
            <SecondaryButton disabled={saving} onClick={() => { setForm(null); setNotice(null); }}>Batal</SecondaryButton>
            <PrimaryButton type="submit" disabled={saving}>{saving ? "Menyimpan..." : "Simpan Harga"}</PrimaryButton>
          </div>
        </form>
      )}
    </Card>
  );
}
