"use client";

import { Loader2 } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { QRCodeSVG } from "qrcode.react";

import PageHeader from "@/components/mobile/PageHeader";
import { useBooking } from "@/lib/booking-context";
import { rupiah } from "@/lib/format";
import { buildQrisPayload } from "@/lib/qris";

// Step pembayaran QRIS antara Checkout dan Konfirmasi: pengguna wajib scan QR
// dengan nominal yang sudah terkunci di dalam QR (lihat lib/qris.js), baru
// setelah dinyatakan lunas boleh masuk halaman konfirmasi.
const MERCHANT = "Sumber Sira";
const CITY = "Bojonegoro";

export default function PembayaranPage() {
  const router = useRouter();
  const booking = useBooking();
  const [checking, setChecking] = useState(false);

  if (booking.loaded && !booking.code) {
    return (
      <main className="grid min-h-dvh place-items-center px-5 text-center">
        <div>
          <p className="text-xs text-white/80">Belum ada booking yang dikonfirmasi.</p>
          <Link href="/app/booking" className="mt-3 inline-flex h-10 items-center rounded-full bg-leaf px-6 text-xs font-semibold">Mulai booking</Link>
        </div>
      </main>
    );
  }

  // Nominal di dalam QR (tag 54) selalu mengikuti total keranjang saat ini.
  const payload = booking.code
    ? buildQrisPayload({ merchant: MERCHANT, city: CITY, amount: booking.total, reference: booking.code })
    : "";
  const steps = [
    "Buka aplikasi bank atau e-wallet apa pun (GoPay, OVO, DANA, dll.).",
    "Pilih menu Bayar / Scan QRIS, lalu arahkan ke QR di atas.",
    <>Pastikan nominal <span className="font-mono font-semibold text-white">{rupiah(booking.total)}</span> dan nama merchant <span className="font-semibold text-white">{MERCHANT.toUpperCase()}</span> sebelum membayar.</>,
    "Setelah pembayaran sukses, tekan tombol di bawah.",
  ];

  // Demo frontend: verifikasi pembayaran disimulasikan.
  // Tahap backend: cek status ke payment gateway (Webhook/API), lalu baru set paid = true.
  const verify = () => {
    if (checking) return;
    setChecking(true);
    setTimeout(() => {
      booking.update({ paid: true });
      router.push("/app/konfirmasi");
    }, 1200);
  };

  return (
    <main className="px-5 pb-24">
      <PageHeader title="Pembayaran QRIS" backHref="/app/checkout" />

      <div className="flex flex-col items-center pt-2">
        <p className="text-center text-[11px] text-white/75">Scan QRIS berikut dengan aplikasi pembayaranmu</p>
        <div className="mt-4 rounded-[20px] bg-white/85 p-5">
          {payload && <QRCodeSVG value={payload} size={185} bgColor="transparent" fgColor="#172321" level="M" />}
        </div>
        <p className="mt-3.5 text-center font-mono text-lg font-semibold leading-none">{rupiah(booking.total)}</p>
        <p className="mt-1.5 text-center text-[9.5px] text-white/65">
          Nominal sudah terkunci di dalam QR, pastikan nilainya sama persis sebelum membayar.
        </p>
      </div>

      <ol className="glass mt-5 list-decimal space-y-2.5 rounded-[20px] p-4 pl-8 text-[11px] leading-snug text-white/80 marker:font-semibold marker:text-leaf">
        {steps.map((step, i) => <li key={i}>{step}</li>)}
      </ol>

      <footer className="fixed inset-x-0 bottom-0 z-30 mx-auto w-full max-w-[430px]">
        <div className="glass flex h-16 items-center justify-between gap-4 rounded-t-[20px] border-b-0 px-5">
          <span>
            <span className="block text-[9.5px] text-white/70">Total Bayar</span>
            <span className="block font-mono text-[13px]">{rupiah(booking.total)}</span>
          </span>
          <button type="button" onClick={verify} disabled={checking || !payload}
                  className="flex h-10 w-[210px] items-center justify-center gap-2 rounded-full bg-leaf text-xs font-semibold transition hover:brightness-110 disabled:opacity-70">
            {checking && <Loader2 size={15} className="animate-spin" />}
            {checking ? "Memeriksa pembayaran…" : "Saya Sudah Bayar"}
          </button>
        </div>
      </footer>
    </main>
  );
}
