import { RefreshCw } from "lucide-react";

import { Avatar, Card, CardTitle } from "@/components/admin/ui";
import { jumlahOrang, type Ticket } from "@/lib/tiket-store";

// Daftar check-in terbaru dan tombol untuk memuat ulang data dari server.
export default function CheckinTerbaru({ recent, ready, onRefresh }: { recent: Ticket[]; ready: boolean; onRefresh: () => void }) {
  return (
    <Card className="flex flex-col">
      <CardTitle sub="Diurutkan dari yang paling baru">Check-in Terbaru</CardTitle>
      <ul className="mt-4 space-y-2.5">
        {recent.slice(0, 6).map((t) => (
          <li key={t.id} className="flex items-center gap-3 rounded-2xl bg-paper px-3 py-2.5 animate-fade-up">
            <Avatar name={t.name} size={34} />
            <span className="min-w-0 flex-1">
              <span className="block truncate text-sm font-semibold">{t.name}</span>
              <span className="block font-mono text-xs text-abu">{t.code} · {jumlahOrang(t)} orang</span>
            </span>
            <span className="text-right">
              <span className="block font-mono text-sm">{t.status === "Keluar" ? t.checkOutAt : t.checkInAt}</span>
              <span className={`block text-[11px] ${t.status === "Keluar" ? "text-abu" : "text-leaf"}`}>{t.status === "Keluar" ? "keluar" : "masuk"}</span>
            </span>
          </li>
        ))}
        {ready && recent.length === 0 && <li className="rounded-2xl bg-paper px-4 py-5 text-center text-sm text-abu">Belum ada pengunjung yang discan masuk hari ini.</li>}
      </ul>
      {/* Data diperbarui otomatis tiap beberapa detik; tombol ini memuat ulang saat itu juga */}
      <button type="button" onClick={onRefresh}
              className="mt-auto flex items-center gap-2 self-start pt-5 text-[13px] text-abu hover:text-forest max-xl:mt-4">
        <RefreshCw size={14} /> Muat ulang sekarang
      </button>
    </Card>
  );
}
