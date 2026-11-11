import type { ChatQuestion } from "@/lib/chat-store";
import { jam } from "@/lib/tiket-store";

type BelumTerjawabProps = {
  pending: ChatQuestion[];
  answered: ChatQuestion[];
  ready: boolean;
  onAnswer: (question: ChatQuestion) => void;
  onRemove: (id: string, question: string) => void;
};

// Pertanyaan yang pengunjung kirim langsung ke pengelola (jawaban lambat, menunggu dibalas manusia).
// Balasan langsung muncul di aplikasi pengunjung yang bertanya.
export default function BelumTerjawab({ pending, answered, ready, onAnswer, onRemove }: BelumTerjawabProps) {
  return (
    <section className="flex flex-col rounded-3xl bg-gradient-to-b from-forest to-ink p-5 text-white">
      <div className="flex items-start justify-between gap-3 px-1">
        <div>
          <h2 className="text-lg font-semibold leading-tight">Menunggu Pengelola</h2>
          <p className="mt-1.5 text-[13px] text-white/70">Pertanyaan yang pengunjung minta dijawab pengelola</p>
        </div>
        {pending.length > 0 && (
          <span className="shrink-0 rounded-full border border-white/12 bg-white/12 px-3 py-1.5 text-xs font-semibold leading-none">{pending.length} pertanyaan</span>
        )}
      </div>
      <ul className="mt-5 space-y-3">
        {pending.map((p) => (
          <li key={p.id} className="rounded-2xl bg-white/[0.08] p-4 animate-fade-up">
            <p className="text-[15px] font-semibold leading-snug">{p.question}</p>
            <p className="mt-2 text-[13px] text-white/60">Masuk pukul {jam(p.askedAt)}</p>
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
          <li className="rounded-2xl bg-white/[0.08] p-4 text-sm text-white/80">{ready ? "Tidak ada pertanyaan yang menunggu. Semua sudah dijawab." : "Memuat..."}</li>
        )}
      </ul>

      {answered.length > 0 && (
        <>
          <p className="mt-6 px-1 text-[13px] text-white/70">Terakhir dijawab</p>
          <ul className="mt-2 space-y-2">
            {answered.slice(0, 3).map((q) => (
              <li key={q.id} className="rounded-2xl bg-white/[0.06] px-4 py-3">
                <p className="truncate text-sm font-medium">{q.question}</p>
                <p className="mt-1 line-clamp-2 text-xs text-white/65">{q.answer}</p>
              </li>
            ))}
          </ul>
        </>
      )}
      <p className="mt-auto px-1 pt-6 text-[13px] text-white/60">Jawabanmu terkirim ke aplikasi pengunjung yang bertanya.</p>
    </section>
  );
}
