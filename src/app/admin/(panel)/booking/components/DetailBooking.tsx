import { Check, X } from "lucide-react";

import WahanaIcon from "@/components/WahanaIcon";
import { Avatar, Card, CardTitle, PrimaryButton, StatusPill } from "@/components/admin/ui";
import { BOOKINGS } from "@/data/dummy";
import { WAHANA } from "@/data/wahana";
import { rupiah } from "@/lib/format";

// Status berikutnya saat tombol utama ditekan: Baru jadi Diproses, Diproses jadi Selesai.
const NEXT_STATUS = { Baru: "Diproses", Diproses: "Selesai" };
const CONFIRM_LABEL = { Baru: "Konfirmasi Booking", Diproses: "Tandai Selesai" };
// Katalog wahana berdasarkan id, untuk mengambil nama dan harga.
const CATALOG = Object.fromEntries(WAHANA.map((w) => [w.id, w]));

// Baris item + total dihitung dari katalog wahana, bukan diketik manual.
// Menyusun rincian item satu booking (nama, jumlah, harga) dari katalog wahana.
function lineItems(booking) {
  return booking.lines.map(({ id, qty }) => {
    const w = CATALOG[id];
    return { key: id, icon: w.icon, label: `${qty}x ${w.name}`, price: w.price * qty };
  });
}

type DetailBookingProps = {
  selected: (typeof BOOKINGS)[number] | null;
  onStatus: (id: number, status: string) => void;
};

// Panel detail booking yang dipilih: data pemesan, item disewa, total, dan tombol konfirmasi atau tolak.
export default function DetailBooking({ selected, onStatus }: DetailBookingProps) {
  // Rincian item booking yang dipilih dan total harganya.
  const lines = selected ? lineItems(selected) : [];
  const total = lines.reduce((sum, l) => sum + l.price, 0);

  return (
    <Card className="flex flex-col pt-5!">
      <CardTitle right={selected && <span className="rounded-full bg-paper px-3 py-1.5 font-mono text-xs text-ink">{selected.code}</span>}>
        Detail Booking
      </CardTitle>
      {selected ? (
        <>
          <div className="mt-5 flex items-center gap-3 border-b border-ink/10 pb-5">
            <Avatar name={selected.name} size={52} solid />
            <div className="min-w-0 flex-1">
              <p className="text-base font-semibold text-ink">{selected.name}</p>
              <p className="text-[13px] text-abu">Pesan lewat aplikasi · {selected.orderedAt}</p>
            </div>
            <StatusPill status={selected.status} />
          </div>

          <dl className="mt-4 space-y-3">
            <div><dt className="text-[13px] text-abu">Waktu kunjungan</dt><dd className="mt-0.5 text-base font-semibold text-ink">{selected.visit}</dd></div>
            <div><dt className="text-[13px] text-abu">Kontak WhatsApp</dt><dd className="mt-0.5 text-base font-semibold text-ink">{selected.phone}</dd></div>
          </dl>

          <p className="mt-4 text-[13px] text-abu">Item disewa</p>
          <ul className="mt-2 space-y-2.5">
            {lines.map((l) => (
              <li key={l.key} className="flex h-[52px] items-center gap-3 rounded-2xl bg-paper px-3">
                <span className="grid size-8 shrink-0 place-items-center rounded-full bg-white text-forest"><WahanaIcon name={l.icon} variant="admin" size={15} /></span>
                <span className="flex-1 text-sm font-semibold text-ink">{l.label}</span>
                <span className="font-mono text-sm text-ink">{rupiah(l.price)}</span>
              </li>
            ))}
          </ul>

          <div className="mt-5 flex items-end justify-between gap-3 border-t border-ink/10 pt-4">
            <div>
              <p className="text-[13px] text-abu">Total pembayaran</p>
              <p className="mt-1 font-display text-[28px] font-semibold leading-none tabular-nums text-forest">{rupiah(total)}</p>
            </div>
            <span className={`inline-flex h-7 items-center gap-1.5 rounded-full px-3 text-xs font-semibold ${selected.payment.includes("QRIS") ? "bg-leaf/12 text-forest" : "bg-paper text-abu"}`}>
              <span className={`size-1.5 rounded-full ${selected.payment.includes("QRIS") ? "bg-leaf" : "bg-ink/50"}`} />{selected.payment}
            </span>
          </div>

          {/* Tombol Konfirmasi atau Tandai Selesai, dan tombol Tolak */}
          <div className="mt-auto space-y-3 pt-6">
            <PrimaryButton icon={Check} className="w-full" disabled={!NEXT_STATUS[selected.status]}
                           onClick={() => onStatus(selected.id, NEXT_STATUS[selected.status])}>
              {CONFIRM_LABEL[selected.status] ?? "Sudah selesai"}
            </PrimaryButton>
            <button type="button" disabled={selected.status === "Selesai" || selected.status === "Ditolak"}
                    onClick={() => onStatus(selected.id, "Ditolak")}
                    className="flex h-11 w-full items-center justify-center gap-2 rounded-full border-[1.5px] border-coral text-sm font-semibold text-coral transition enabled:hover:bg-coral/10 disabled:opacity-40">
              <X size={17} aria-hidden="true" /> Tolak
            </button>
          </div>
        </>
      ) : <p className="mt-4 text-sm text-abu">Pilih booking di tabel.</p>}
    </Card>
  );
}
