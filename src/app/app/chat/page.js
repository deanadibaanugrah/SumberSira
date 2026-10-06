"use client";

import { SendHorizontal } from "lucide-react";
import { useEffect, useRef, useState } from "react";

import PageHeader from "@/components/mobile/PageHeader";
import { CROWD_NOW } from "@/data/dummy";

// Chatbot "Tanya Sira". Tahap UTS: jawaban dari aturan kata kunci (data FAQ).
// Tahap backend: ganti answer() dengan panggilan ke API chatbot; FAQ dikelola di halaman admin Chatbot / FAQ.
const RULES = [
  { keys: ["jam", "buka", "tutup"], reply: "Weekend buka 08.00–17.00 ya! Weekday sampai 16.00 😊" },
  { keys: ["atv"], reply: "Buka menu Sewa & Booking, pilih jam kunjungan, tambah ATV (15 menit) Rp25.000, lalu tekan Lanjut Booking. Bisa bayar tunai atau QRIS 😊" },
  { keys: ["sewa", "ban", "loker", "wahana"], reply: "Ban kecil Rp5.000, ban besar Rp10.000, loker Rp5.000. Wahana: kereta sawah, bebek gayung, ATV, flying fox, komedi putar. Semua bisa dipesan di menu Sewa & Booking." },
  { keys: ["tiket", "harga", "htm", "masuk"], reply: "Tiket masuk Rp5.000 per orang (usia 3 tahun ke atas)." },
  { keys: ["qris", "bayar", "pembayaran", "tunai"], reply: "Pembayaran bisa tunai atau QRIS. Setelah bayar, invoice dikirim ke WhatsApp-mu." },
  { keys: ["parkir", "bus", "mobil", "motor"], reply: "Parkir motor 3rb, mobil 10rb, bus 20rb." },
  { keys: ["ramai", "sepi", "crowd", "antre"], reply: `Keramaian saat ini ${CROWD_NOW.label} (${CROWD_NOW.percent}%). Jam sepi terbaik 08.00–09.00 atau setelah 15.00.` },
  { keys: ["lokasi", "alamat", "dimana", "di mana"], reply: "Sumber Sira ada di Desa Putukrejo, Malang. Dikelola masyarakat Desa Putukrejo." },
];
const FALLBACK = "Maaf, Tanya Sira belum tahu jawabannya. Pertanyaanmu sudah diteruskan ke admin ya 🙏";

function answer(text) {
  const lower = text.toLowerCase();
  return RULES.find((r) => r.keys.some((k) => lower.includes(k)))?.reply ?? FALLBACK;
}

const START = [
  { from: "bot", text: "Halo! Aku Tanya Sira 👋 Ada yang bisa dibantu soal Sumber Sira?" },
  { from: "quick", options: ["Jam buka?", "Cara sewa ATV?"] },
  { from: "me", text: "Jam buka weekend jam berapa?" },
  { from: "bot", text: "Weekend buka 08.00–17.00 ya! Weekday sampai 16.00 😊" },
];

export default function ChatPage() {
  const [messages, setMessages] = useState(START);
  const [draft, setDraft] = useState("");
  const [typing, setTyping] = useState(false);
  const end = useRef(null);

  useEffect(() => {
    end.current?.scrollIntoView({ behavior: "smooth", block: "end" });
  }, [messages, typing]);

  const send = (text) => {
    const clean = text.trim();
    if (!clean || typing) return;
    setMessages((m) => [...m, { from: "me", text: clean }]);
    setDraft("");
    setTyping(true);
    setTimeout(() => {
      setMessages((m) => [...m, { from: "bot", text: answer(clean) }]);
      setTyping(false);
    }, 700);
  };

  return (
    <main className="flex min-h-dvh flex-col px-5">
      <PageHeader backHref="/app/home">
        <span className="flex items-center gap-2.5">
          <span className="size-9 rounded-full bg-leaf" aria-hidden="true" />
          <span>
            <span className="block font-display text-base font-semibold leading-tight">Tanya Sira</span>
            <span className="block text-[9px] text-white/70">AI Assistant • Online</span>
          </span>
        </span>
      </PageHeader>

      <ol className="mt-3 flex-1 space-y-4 pb-24" aria-live="polite">
        {messages.map((m, i) => {
          if (m.from === "quick") {
            return (
              <li key={i} className="flex flex-wrap gap-[6.5px] pl-9">
                {m.options.map((o) => (
                  <button key={o} type="button" onClick={() => send(o)}
                          className="h-[30px] rounded-full border border-white/25 bg-moss/50 pl-2.5 pr-9 text-[9px] transition hover:bg-moss">
                    {o}
                  </button>
                ))}
              </li>
            );
          }
          if (m.from === "me") {
            return (
              <li key={i} className="flex justify-end animate-fade-up">
                <p className="max-w-[220px] rounded-[18px] bg-leaf py-3 pl-4 pr-5 text-[11px] leading-[13px]">{m.text}</p>
              </li>
            );
          }
          return (
            <li key={i} className="flex items-start gap-2 animate-fade-up">
              <span className="size-7 shrink-0 rounded-full bg-leaf" aria-hidden="true" />
              <p className="glass max-w-[260px] rounded-[20px] py-3 pl-4 pr-6 text-[11px] leading-[13px]">{m.text}</p>
            </li>
          );
        })}
        {typing && (
          <li className="flex items-center gap-2">
            <span className="size-7 shrink-0 rounded-full bg-leaf" aria-hidden="true" />
            <span className="glass flex gap-1 rounded-[20px] px-4 py-3" aria-label="Tanya Sira sedang mengetik">
              {[0, 1, 2].map((d) => <span key={d} className="size-1.5 rounded-full bg-white/70 animate-bounce" style={{ animationDelay: `${d * 150}ms` }} />)}
            </span>
          </li>
        )}
        <li ref={end} aria-hidden="true" />
      </ol>

      <form onSubmit={(e) => { e.preventDefault(); send(draft); }}
            className="fixed inset-x-0 bottom-0 z-30 mx-auto flex w-full max-w-[430px] items-center gap-2 px-5 pb-6 pt-3">
        <label htmlFor="pesan" className="sr-only">Tulis pertanyaan</label>
        <input id="pesan" value={draft} onChange={(e) => setDraft(e.target.value)} placeholder="Tulis pertanyaan..."
               className="glass h-12 flex-1 rounded-full px-4 text-[11px] text-white outline-none placeholder:text-white/60" />
        <button type="submit" aria-label="Kirim" disabled={!draft.trim() || typing}
                className="grid size-8 shrink-0 place-items-center rounded-full bg-leaf transition enabled:hover:brightness-110 disabled:opacity-60">
          <SendHorizontal size={15} />
        </button>
      </form>
    </main>
  );
}
