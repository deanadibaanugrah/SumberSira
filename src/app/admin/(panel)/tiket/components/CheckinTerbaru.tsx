import { RotateCcw } from "lucide-react";

import { Avatar, Card, CardTitle } from "@/components/admin/ui";
import { jumlahOrang, type Ticket } from "@/lib/tiket-store";

// Daftar check-in terbaru dan tombol untuk mengembalikan data contoh.
export default function CheckinTerbaru({ recent, onReset }: { recent: Ticket[]; onReset: () => void }) {
  return (
    <Card className="flex flex-col">
      <CardTitle sub="Diurutkan dari yang paling baru">Check-in Terbaru</CardTitle>
      <ul className="mt-4 space-y-2.5">
        {recent.slice(0, 6).map((t) => (
          <li key={t.code} className="flex items-center gap-3 rounded-2xl bg-paper px-3 py-2.5 animate-fade-up">
            <Avatar name={t.name} size={34} />
            <span className="min-w-0 flex-1">
              <span className="block truncate text-sm font-semibold">{t.name}</span>
              <span className="block font-mono text-xs text-ink/60">{t.code} · {jumlahOrang(t)} orang</span>
            </span>
            <span className="text-right">
              <span className="block font-mono text-sm">{t.status === "Keluar" ? t.checkOutAt : t.checkInAt}</span>
              <span className={`block text-[11px] ${t.status === "Keluar" ? "text-ink/50" : "text-leaf"}`}>{t.status === "Keluar" ? "keluar" : "masuk"}</span>
            </span>
          </li>
        ))}
      </ul>
      {/* Tombol untuk mengembalikan data contoh */}
      <button type="button" onClick={onReset}
              className="mt-auto flex items-center gap-2 self-start pt-5 text-[13px] text-ink/60 hover:text-forest max-xl:mt-4">
        <RotateCcw size={14} /> Kembalikan data contoh hari ini
      </button>
    </Card>
  );
}
