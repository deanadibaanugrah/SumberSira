"use client";

import { Minus, Plus } from "lucide-react";
import { useRouter } from "next/navigation";

import WahanaIcon from "@/components/WahanaIcon";
import PageHeader from "@/components/mobile/PageHeader";
import { SLOTS, WAHANA, bookingLabel } from "@/data/wahana";
import { useBooking } from "@/lib/booking-context";
import { rupiah } from "@/lib/format";

export default function BookingPage() {
  const router = useRouter();
  const booking = useBooking();

  return (
    <main className="px-5 pb-24">
      <PageHeader title="Sewa & Booking Wahana" backHref="/app/home" />

      <h2 className="text-[11px] font-semibold">Pilih Jam Kunjungan</h2>
      <div className="mt-2 grid grid-cols-4 gap-2" role="radiogroup" aria-label="Jam kunjungan">
        {SLOTS.map((slot) => {
          const active = booking.slot === slot.id;
          return (
            <button key={slot.id} type="button" role="radio" aria-checked={active} onClick={() => booking.setSlot(slot.id)}
                    className={`relative h-8 rounded-full border font-mono text-[11px] transition ${
                      active ? "border-white/30 bg-leaf/80" : "glass hover:bg-white/15"}`}>
              {slot.label}
              {slot.busy && (
                <span className="absolute -right-0.5 -top-[3.5px] size-[9px] rounded-full border-[1.5px] border-white/80 bg-coral" aria-label="ramai" />
              )}
            </button>
          );
        })}
      </div>
      <p className="mt-1.5 flex items-center gap-1.5 text-[9px] text-white/70">
        <span className="size-2 rounded-full bg-coral" /> Jam ramai (10.00–14.00)
      </p>

      <ul className="mt-3 space-y-2">
        {WAHANA.filter((w) => w.status === "Aktif").map((w) => {
          const qty = booking.qty[w.id] || 0;
          return (
            <li key={w.id} className="glass flex h-[60px] items-center gap-2.5 rounded-[20px] pl-2 pr-[15px]">
              <span className="grid size-11 shrink-0 place-items-center rounded-full border border-white/25 bg-leaf/35">
                <WahanaIcon name={w.icon} size={18} />
              </span>
              <span className="flex-1">
                <span className="block text-[11px]">{bookingLabel(w)}</span>
                <span className="mt-[5px] block font-mono text-[11px]">{rupiah(w.price)}</span>
              </span>
              {qty === 0 ? (
                <button type="button" onClick={() => booking.add(w.id)} aria-label={`Tambah ${w.name}`}
                        className="grid h-7 w-10 place-items-center rounded-full bg-leaf transition hover:brightness-110">
                  <Plus size={12} strokeWidth={3} />
                </button>
              ) : (
                <span className="flex h-7 items-center gap-1.5 rounded-full bg-leaf/90 px-0.5">
                  <button type="button" onClick={() => booking.remove(w.id)} aria-label={`Kurangi ${w.name}`}
                          className="grid size-6 place-items-center rounded-full bg-white/15 hover:bg-white/25"><Minus size={12} strokeWidth={3} /></button>
                  <span className="w-4 text-center font-mono text-[11px] font-semibold" aria-live="polite">{qty}</span>
                  <button type="button" onClick={() => booking.add(w.id)} aria-label={`Tambah ${w.name}`}
                          className="grid size-6 place-items-center rounded-full bg-white/15 hover:bg-white/25"><Plus size={12} strokeWidth={3} /></button>
                </span>
              )}
            </li>
          );
        })}
      </ul>

      <footer className="fixed inset-x-0 bottom-0 z-30 mx-auto w-full max-w-[430px]">
        <div className="glass flex h-16 items-center justify-between gap-4 rounded-t-[20px] border-b-0 px-5">
          <span>
            <span className="block text-[9.5px] text-white/70">Total</span>
            <span className="block font-mono text-[13px]">{rupiah(booking.total)}</span>
          </span>
          <button type="button" disabled={booking.items.length === 0} onClick={() => router.push("/app/checkout")}
                  className="h-10 w-[195px] rounded-full bg-leaf text-xs font-semibold transition enabled:hover:brightness-110 disabled:opacity-60">
            Lanjut Booking
          </button>
        </div>
      </footer>
    </main>
  );
}
