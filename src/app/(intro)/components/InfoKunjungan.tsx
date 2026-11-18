import { Clock, Ticket } from "lucide-react";

import { apiFetch } from "@/repositories/api-server";
import { rupiah } from "@/lib/format";

// Info jam buka dan harga tiket masuk. Harga berasal dari backend (GET /pricing); bila backend
// belum menjawab, baris harga tidak ditampilkan, bukan diganti dengan angka lain.
export default async function InfoKunjungan() {
  let harga: number | null = null;
  try {
    const res = await apiFetch("/pricing");
    if (res.ok) {
      const p = await res.json();
      harga = typeof p?.ticketPricePerPerson === "number" ? p.ticketPricePerPerson : null;
    }
  } catch {
    harga = null;
  }
  return (
    <div className="mt-10 grid gap-4 sm:grid-cols-2">
      <p className="glass flex items-center gap-4 rounded-[24px] p-5">
        <Clock className="shrink-0" /> <span><b className="block">Jam buka</b><span className="text-sm text-white/70">Weekday 08.00-16.00 · Weekend s/d 17.00</span></span>
      </p>
      <p className="glass flex items-center gap-4 rounded-[24px] p-5">
        <Ticket className="shrink-0" /> <span><b className="block">Tiket masuk</b><span className="text-sm text-white/70">{harga == null ? "Lihat harga di aplikasi" : `${rupiah(harga)} per orang (usia 3 tahun ke atas)`}</span></span>
      </p>
    </div>
  );
}
