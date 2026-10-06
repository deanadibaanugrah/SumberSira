"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";

import PageHeader from "@/components/mobile/PageHeader";
import { useBooking } from "@/lib/booking-context";
import { bookingCode, rupiah } from "@/lib/format";

// Lebar tombol mengikuti desain (Cash 125 px, QRIS 86 px).
const METHODS = [
  { id: "Cash di Lokasi", width: "w-[125px]" },
  { id: "QRIS", width: "w-[86px]" },
];
const WA_PATTERN = /^(\+?62|0)8\d{8,12}$/;
const inputClass =
  "glass mt-1 h-11 w-full rounded-2xl px-4 text-[11px] text-white outline-none placeholder:text-white/55 focus:border-white/50";

export default function CheckoutPage() {
  const router = useRouter();
  const booking = useBooking();
  const [errors, setErrors] = useState({});

  if (booking.loaded && booking.items.length === 0) {
    return (
      <main className="px-5">
        <PageHeader title="Ringkasan Booking" backHref="/app/booking" />
        <div className="glass rounded-[20px] p-5 text-center">
          <p className="text-xs text-white/80">Belum ada item yang dipilih.</p>
          <Link href="/app/booking" className="mt-3 inline-flex h-10 items-center rounded-full bg-leaf px-6 text-xs font-semibold">Pilih wahana</Link>
        </div>
      </main>
    );
  }

  const submit = (e) => {
    e.preventDefault();
    const next = {};
    if (!booking.name.trim()) next.name = "Nama lengkap wajib diisi.";
    if (!WA_PATTERN.test(booking.whatsapp.replace(/[\s-]/g, ""))) next.whatsapp = "Masukkan nomor WhatsApp yang valid, mis. 081234567890.";
    setErrors(next);
    if (Object.keys(next).length) return;
    booking.update({ code: bookingCode() });
    router.push("/app/konfirmasi");
  };

  return (
    <main className="px-5 pb-24">
      <PageHeader title="Ringkasan Booking" backHref="/app/booking" />

      <form id="checkout" onSubmit={submit} noValidate>
        <h2 className="text-[11px] font-semibold">Waktu Kunjungan</h2>
        <p className="mt-1.5 inline-flex h-9 w-[125px] items-center justify-center rounded-full border border-white/30 bg-leaf/80 font-mono text-[11px]">
          {booking.slotInfo.range}
        </p>

        <h2 className="mt-5 text-[11px] font-semibold">Item Dipesan</h2>
        <ul className="mt-2 space-y-[25px] border-b border-white/15 pb-9 pr-8">
          {booking.items.map((item) => (
            <li key={item.id} className="flex items-center justify-between text-xs">
              <span>{item.qty}x {item.name}</span>
              <span className="font-mono text-[11px]">{rupiah(item.qty * item.price)}</span>
            </li>
          ))}
        </ul>

        <h2 className="mt-3.5 text-[11px] font-semibold">Data Pemesan</h2>
        <label className="mt-2 block text-[9px] text-white/65" htmlFor="nama">Nama Lengkap</label>
        <input id="nama" value={booking.name} onChange={(e) => booking.update({ name: e.target.value })}
               placeholder="Masukkan nama lengkap" autoComplete="name" aria-invalid={Boolean(errors.name)} className={inputClass} />
        {errors.name && <p className="mt-1 text-[9.5px] text-coral">{errors.name}</p>}

        <label className="mt-2.5 block text-[9px] text-white/65" htmlFor="wa">No. WhatsApp</label>
        <input id="wa" value={booking.whatsapp} onChange={(e) => booking.update({ whatsapp: e.target.value })}
               placeholder="08xxxxxxxxxx" inputMode="tel" autoComplete="tel" aria-invalid={Boolean(errors.whatsapp)} className={inputClass} />
        {errors.whatsapp && <p className="mt-1 text-[9.5px] text-coral">{errors.whatsapp}</p>}
        <p className="mt-1 text-[9px] text-white/55">Invoice dikirim ke nomor ini setelah pembayaran.</p>

        <h2 className="mt-4 text-[11px] font-semibold">Metode Pembayaran</h2>
        <div className="mt-1.5 flex gap-[39px]" role="radiogroup" aria-label="Metode pembayaran">
          {METHODS.map((m) => {
            const active = booking.payment === m.id;
            return (
              <button key={m.id} type="button" role="radio" aria-checked={active} onClick={() => booking.update({ payment: m.id })}
                      className={`h-10 rounded-full border text-[11px] font-semibold transition ${m.width} ${
                        active ? "border-white/30 bg-leaf/80" : "glass hover:bg-white/15"}`}>
                {m.id}
              </button>
            );
          })}
        </div>
      </form>

      <footer className="fixed inset-x-0 bottom-0 z-30 mx-auto w-full max-w-[430px]">
        <div className="glass flex h-16 items-center justify-between gap-4 rounded-t-[20px] border-b-0 px-5">
          <span>
            <span className="block text-[9.5px] text-white/70">Total</span>
            <span className="block font-mono text-[13px]">{rupiah(booking.total)}</span>
          </span>
          <button type="submit" form="checkout"
                  className="h-10 w-[210px] rounded-full bg-leaf text-xs font-semibold transition hover:brightness-110">
            Konfirmasi &amp; Bayar
          </button>
        </div>
      </footer>
    </main>
  );
}
