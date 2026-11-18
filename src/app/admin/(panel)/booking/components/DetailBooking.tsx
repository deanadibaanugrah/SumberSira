"use client";

import { Check, X } from "lucide-react";
import { useState } from "react";

import WahanaIcon from "@/components/WahanaIcon";
import { Avatar, Card, CardTitle, Modal, PrimaryButton, StatusPill } from "@/components/admin/ui";
import { batalkanPembayaran, tandaiLunas } from "@/viewmodels/booking-viewmodel";
import type { Booking } from "@/models/booking";
import { rupiah } from "@/lib/format";

// Ikon item sewa dari id wahana yang dikirim backend (mis. "ban-besar").

// "2026-11-15" -> "15 Nov 2026" (WIB).
const tanggalSingkat = (d: string) =>
  new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "short", year: "numeric", timeZone: "Asia/Jakarta" }).format(new Date(`${d}T00:00:00+07:00`));

// Chip metode + status pembayaran, mis. "QRIS Â· Lunas".
const chipPembayaran = (b: Booking) => `${b.payment?.method === "cash" ? "Tunai" : "QRIS"} Â· ${b.status}`;

type DetailBookingProps = {
  selected: Booking | null;
  canKelola: boolean;
};

// Panel detail booking yang dipilih: data pemesan, item disewa, total, status pembayaran (pemantauan),
// dan untuk pengelola saja aksi Tandai Lunas / Batalkan dengan konfirmasi.
export default function DetailBooking({ selected, canKelola }: DetailBookingProps) {
  // Konfirmasi aksi pembayaran (Modal) dan status aksi yang sedang berjalan.
  const [konfirmasi, setKonfirmasi] = useState<{ aksi: "lunas" | "batal" } | null>(null);
  const [pesan, setPesan] = useState<string | null>(null);
  const [sibuk, setSibuk] = useState(false);

  if (!selected) {
    return (
      <Card className="flex flex-col pt-5!">
        <CardTitle>Detail Booking</CardTitle>
        <p className="mt-4 text-sm text-abu">Pilih booking di tabel.</p>
      </Card>
    );
  }

  const pending = selected.payment?.status === "pending";

  // Jalankan aksi yang dikonfirmasi lewat Modal, lalu tampilkan hasilnya di bawah tombol.
  const jalankan = async () => {
    if (!konfirmasi || sibuk) return;
    setSibuk(true);
    setPesan(null);
    const hasil = konfirmasi.aksi === "lunas" ? await tandaiLunas(selected.code) : await batalkanPembayaran(selected.code);
    setPesan(hasil.message);
    setSibuk(false);
    setKonfirmasi(null);
  };

  return (
    <Card className="flex flex-col pt-5!">
      <CardTitle right={selected && <span className="rounded-full bg-paper px-3 py-1.5 font-mono text-xs text-ink">{selected.code}</span>}>
        Detail Booking
      </CardTitle>

      <div className="mt-5 flex items-center gap-3 border-b border-ink/10 pb-5">
        <Avatar name={selected.name} size={52} solid />
        <div className="min-w-0 flex-1">
          <p className="text-base font-semibold text-ink">{selected.name}</p>
          <p className="text-[13px] text-abu">Pesan lewat aplikasi Â· {selected.time}</p>
        </div>
        <StatusPill status={selected.status} />
      </div>

      <dl className="mt-4 space-y-3">
        <div><dt className="text-[13px] text-abu">Waktu kunjungan</dt><dd className="mt-0.5 text-base font-semibold text-ink">{selected.slotLabel}, {tanggalSingkat(selected.visitDate)}</dd></div>
        <div><dt className="text-[13px] text-abu">Kontak WhatsApp</dt><dd className="mt-0.5 text-base font-semibold text-ink">{selected.whatsapp}</dd></div>
      </dl>

      <p className="mt-4 text-[13px] text-abu">Item disewa</p>
      <ul className="mt-2 space-y-2.5">
        {selected.lines.map((l) => (
          <li key={l.rideId} className="flex h-[52px] items-center gap-3 rounded-2xl bg-paper px-3">
            <span className="grid size-8 shrink-0 place-items-center rounded-full bg-white text-forest"><WahanaIcon name={l.rideId} variant="admin" size={15} /></span>
            <span className="flex-1 text-sm font-semibold text-ink">{l.qty}x {l.name}</span>
            <span className="font-mono text-sm text-ink">{rupiah(l.subtotal)}</span>
          </li>
        ))}
        {selected.lines.length === 0 && <li className="rounded-2xl bg-paper px-3 py-2.5 text-sm text-abu">Tidak ada item.</li>}
      </ul>

      <div className="mt-5 flex items-end justify-between gap-3 border-t border-ink/10 pt-4">
        <div>
          <p className="text-[13px] text-abu">Total pembayaran</p>
          <p className="mt-1 font-display text-[28px] font-semibold leading-none tabular-nums text-forest">{rupiah(selected.amount)}</p>
        </div>
        <span className={`inline-flex h-7 items-center gap-1.5 rounded-full px-3 text-xs font-semibold ${pending ? "bg-leaf/12 text-forest" : "bg-paper text-abu"}`}>
          <span className={`size-1.5 rounded-full ${pending ? "bg-leaf" : "bg-ink/50"}`} />{chipPembayaran(selected)}
        </span>
      </div>

      {/* Pembayaran QRIS dikonfirmasi otomatis backend; pengelola bisa menandai lunas / membatalkan yang masih pending */}
      <div className="mt-auto space-y-3 pt-6">
        {canKelola && pending ? (
          <>
            <PrimaryButton icon={Check} className="w-full" disabled={sibuk} onClick={() => setKonfirmasi({ aksi: "lunas" })}>
              Tandai Lunas
            </PrimaryButton>
            <button type="button" disabled={sibuk} onClick={() => setKonfirmasi({ aksi: "batal" })}
                    className="flex h-11 w-full items-center justify-center gap-2 rounded-full border-[1.5px] border-coral text-sm font-semibold text-coral transition enabled:hover:bg-coral/10 disabled:opacity-40">
              <X size={17} aria-hidden="true" /> Batalkan
            </button>
          </>
        ) : (
          <p className="rounded-2xl bg-paper px-4 py-3 text-[13px] text-abu">
            {canKelola
              ? "Pembayaran ini sudah selesai. QRIS dikonfirmasi otomatis oleh sistem."
              : "Status pembayaran diperbarui otomatis. Hanya pengelola yang bisa menandai lunas atau membatalkan."}
          </p>
        )}
        {pesan && <p className="text-[13px] text-ink">{pesan}</p>}
      </div>

      {konfirmasi && (
        <Modal title={konfirmasi.aksi === "lunas" ? "Tandai Lunas?" : "Batalkan Pembayaran?"} onClose={() => setKonfirmasi(null)}>
          <p className="text-sm text-abu">
            {konfirmasi.aksi === "lunas"
              ? `Tandai pembayaran ${selected.code} a.n. ${selected.name} sebagai lunas?`
              : `Batalkan pembayaran ${selected.code} a.n. ${selected.name}? Pembayaran yang sudah dibatalkan tidak bisa diaktifkan lagi.`}
          </p>
          <div className="mt-5 flex justify-end gap-2">
            <button type="button" disabled={sibuk} onClick={() => setKonfirmasi(null)}
                    className="h-11 rounded-full px-5 text-sm font-semibold text-abu transition hover:bg-paper disabled:opacity-40">
              Batal
            </button>
            <PrimaryButton onClick={jalankan} disabled={sibuk}>
              {konfirmasi.aksi === "lunas" ? "Ya, Tandai Lunas" : "Ya, Batalkan"}
            </PrimaryButton>
          </div>
        </Modal>
      )}
    </Card>
  );
}
