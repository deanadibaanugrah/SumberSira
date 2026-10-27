import { Clock, Ticket } from "lucide-react";

// Info jam buka dan harga tiket masuk.
export default function InfoKunjungan() {
  return (
    <div className="mt-10 grid gap-4 sm:grid-cols-2">
      <p className="glass flex items-center gap-4 rounded-[24px] p-5">
        <Clock className="shrink-0" /> <span><b className="block">Jam buka</b><span className="text-sm text-white/70">Weekday 08.00-16.00 · Weekend s/d 17.00</span></span>
      </p>
      <p className="glass flex items-center gap-4 rounded-[24px] p-5">
        <Ticket className="shrink-0" /> <span><b className="block">Tiket masuk</b><span className="text-sm text-white/70">Rp5.000 per orang (usia 3 tahun ke atas)</span></span>
      </p>
    </div>
  );
}
