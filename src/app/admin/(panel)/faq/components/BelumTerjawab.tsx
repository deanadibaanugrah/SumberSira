import type { UNANSWERED } from "@/data/dummy";

type BelumTerjawabProps = {
  pending: typeof UNANSWERED;
  onAnswer: (question: (typeof UNANSWERED)[number]) => void;
};

// Kartu pertanyaan pengunjung yang belum bisa dijawab chatbot.
export default function BelumTerjawab({ pending, onAnswer }: BelumTerjawabProps) {
  return (
    <section className="flex flex-col rounded-3xl bg-gradient-to-b from-forest to-ink p-5 text-white">
      <div className="flex items-start justify-between gap-3 px-1">
        <div>
          <h2 className="text-lg font-semibold leading-tight">Belum Terjawab</h2>
          <p className="mt-1.5 text-[13px] text-white/70">Pertanyaan yang belum bisa dijawab Tanya Sira</p>
        </div>
        {pending.length > 0 && (
          <span className="shrink-0 rounded-full border border-white/12 bg-white/12 px-3 py-1.5 text-xs font-semibold leading-none">{pending.length} pertanyaan</span>
        )}
      </div>
      <ul className="mt-5 space-y-3">
        {pending.map((p) => (
          <li key={p.id} className="flex items-center gap-3 rounded-2xl bg-white/[0.08] p-4 animate-fade-up">
            <div className="min-w-0 flex-1">
              <p className="text-[15px] font-semibold leading-snug">{p.q}</p>
              <p className="mt-2 text-[13px] text-white/60">Ditanyakan {p.asked}x minggu ini</p>
            </div>
            <button type="button" onClick={() => onAnswer(p)}
                    className="h-10 shrink-0 rounded-full bg-white px-4 text-[13px] font-semibold text-forest transition hover:bg-white/90">
              Jawab
            </button>
          </li>
        ))}
        {pending.length === 0 && <li className="rounded-2xl bg-white/[0.08] p-4 text-sm text-white/80">Semua pertanyaan sudah dijawab. 🎉</li>}
      </ul>
      <p className="mt-auto px-1 pt-6 text-[13px] text-white/60">Jawaban baru langsung dipakai Tanya Sira di aplikasi pengunjung.</p>
    </section>
  );
}
