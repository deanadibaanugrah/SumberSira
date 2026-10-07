"use client";

import { Check, MessageCircle } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { QRCodeSVG } from "qrcode.react";

import { useBooking } from "@/lib/booking-context";
import { rupiah } from "@/lib/format";

export default function KonfirmasiPage() {
  const router = useRouter();
  const booking = useBooking();

  // Halaman ini hanya boleh tampil setelah pembayaran QRIS lunas (paid diisi di /app/pembayaran).
  const unpaid = booking.loaded && Boolean(booking.code) && !booking.paid;
  useEffect(() => {
    if (unpaid) router.replace("/app/pembayaran");
  }, [unpaid, router]);

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

  if (unpaid) {
    return (
      <main className="grid min-h-dvh place-items-center px-5 text-center">
        <p className="text-xs text-white/80">Mengarahkan ke halaman pembayaran QRIS…</p>
      </main>
    );
  }

  const itemSummary = booking.items.map((i) => `${i.qty}x ${i.short}`).join(", ");
  const backHome = () => {
    booking.reset();
    router.push("/app/home");
  };
  const rows = [
    ["Nama Pemesan", booking.name],
    ["Waktu Kunjungan", booking.slotInfo.range],
    ["Item", itemSummary],
    ["Total Dibayar", rupiah(booking.total)],
  ];

  return (
    <main className="flex min-h-dvh flex-col px-5 pb-8 pt-[60px]">
      <span className="mx-auto grid size-[100px] place-items-center rounded-full border border-white/30 bg-leaf/45 animate-pop">
        <Check size={46} strokeWidth={2.6} />
      </span>
      <h1 className="mt-5 text-center font-display text-2xl font-semibold leading-tight">Booking Berhasil!</h1>
      <p className="mt-0.5 text-center text-xs text-white/70">Tunjukkan QR ini di pintu masuk</p>
      <p className="mt-1 text-center font-mono text-[10px] font-medium">Kode: {booking.code}</p>

      <div className="mx-auto mt-[18px] rounded-[20px] bg-white/85 p-5">
        {booking.code && <QRCodeSVG value={booking.code} size={140} bgColor="transparent" fgColor="#172321" level="M" />}
      </div>

      <dl className="glass mt-[22px] grid h-[170px] grid-cols-[160px_1fr] content-start items-center gap-y-[19.5px] rounded-[20px] px-5 pt-[18px]">
        {rows.map(([label, value]) => (
          <div key={label} className="contents">
            <dt className="text-[9px] text-white/70">{label}</dt>
            <dd className="text-[11px] font-semibold">{value}</dd>
          </div>
        ))}
      </dl>

      {/* Fase frontend: tombol invoice tampil dulu tapi belum aktif. Auto-send diaktifkan
          kembali saat backend /api/invoice diuji (lihat src/app/api/invoice/route.js). */}
      <p className="mt-3 text-center text-[9.5px] text-white/70">Invoice dikirim ke WhatsApp <span className="font-mono">{booking.whatsapp}</span></p>
      <button type="button" disabled aria-disabled="true"
              className="glass mt-2 flex h-10 items-center justify-center gap-2 rounded-full text-xs font-semibold transition hover:bg-white/15 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:bg-white/10">
        <MessageCircle size={15} /> Kirim Invoice ke WhatsApp
      </button>

      <div className="mt-auto pt-4">
        <button type="button" onClick={backHome}
                className="flex h-[50px] w-full items-center justify-center rounded-full bg-leaf text-[13px] font-semibold shadow-lg shadow-black/25 transition hover:brightness-110">
          Kembali ke Beranda
        </button>
      </div>
    </main>
  );
}
