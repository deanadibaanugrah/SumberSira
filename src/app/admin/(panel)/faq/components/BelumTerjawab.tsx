import type { AdminUnanswered } from "@/lib/auth/dal";

type BelumTerjawabProps = {
  pending: AdminUnanswered[];
  ready: boolean;
  onAnswer: (question: AdminUnanswered) => void;
  onRemove: (id: string, question: string) => void;
};

// Format waktu pertanyaan masuk dalam WIB.
const WAKTU = new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short", timeZone: "Asia/Jakarta" });
const waktu = (iso: string) => {
  const tanggal = new Date(iso);
  return Number.isNaN(tanggal.getTime()) ? "-" : WAKTU.format(tanggal);
};

// Pertanyaan pengunjung yang belum cocok dengan FAQ mana pun. Dijawab dengan membuat FAQ baru.
export default function BelumTerjawab({ pending, ready, onAnswer, onRemove }: BelumTerjawabProps) {
  return (
    <section className="flex flex-col rounded-3xl bg-gradient-to-b from-forest to-ink p-5 text-white">
      <div className="flex items-start justify-between gap-3 px-1">
        <div>
          <h2 className="text-lg font-semibold leading-tight">Belum Terjawab</h2>
          <p className="mt-1.5 text-[13px] text-white/70">Pertanyaan pengunjung yang belum cocok dengan FAQ</p>
        </div>
        {pending.length > 0 && (
          <span className="shrink-0 rounded-full border border-white/12 bg-white/12 px-3 py-1.5 text-xs font-semibold leading-none">{pending.length} pertanyaan</span>
        )}
      </div>
      <ul className="mt-5 space-y-3">
        {pending.map((p) => (
          <li key={p.id} className="rounded-2xl bg-white/[0.08] p-4 animate-fade-up">
            <p className="text-[15px] font-semibold leading-snug">{p.question}</p>
            <p className="mt-2 text-[13px] text-white/60">Masuk {waktu(p.createdAt)}</p>
            <div className="mt-3 flex gap-2">
              <button type="button" onClick={() => onAnswer(p)}
                      className="h-10 rounded-full bg-white px-4 text-[13px] font-semibold text-forest transition hover:bg-white/90">
                Jawab
              </button>
              <button type="button" onClick={() => onRemove(p.id, p.question)}
                      className="h-10 rounded-full px-4 text-[13px] font-semibold text-white/70 transition hover:bg-white/10 hover:text-white">
                Hapus
              </button>
            </div>
          </li>
        ))}
        {pending.length === 0 && (
          <li className="rounded-2xl bg-white/[0.08] p-4 text-sm text-white/80">{ready ? "Tidak ada pertanyaan yang menunggu. Semua sudah terjawab." : "Belum bisa dimuat."}</li>
        )}
      </ul>
      <p className="mt-auto px-1 pt-6 text-[13px] text-white/60">Jawab dengan membuat FAQ baru; pertanyaan serupa berikutnya dijawab otomatis.</p>
    </section>
  );
}
