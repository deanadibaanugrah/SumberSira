import { Bot, MessageSquareText, UserRound } from "lucide-react";

import { Card } from "@/components/admin/ui";

// Penjelasan singkat cara Tanya Sira menjawab, supaya pengelola paham mana yang cepat dan mana yang menunggu manusia.
export default function AlurJawaban({ aiActive }: { aiActive: boolean | null }) {
  const langkah = [
    { icon: MessageSquareText, judul: "1. FAQ pengelola", isi: "Dicocokkan dulu dengan FAQ buatanmu. Cepat, tanpa AI." },
    {
      icon: Bot,
      judul: "2. AI dari data Sumber Sira",
      isi: aiActive === false
        ? "Belum aktif: isi ANTHROPIC_API_KEY di backend. Sementara dijawab dari data bawaan (jam, harga, parkir, fasilitas)."
        : "Bila tidak ada di FAQ, AI menjawab dari data resmi (jam, harga, wahana, keramaian). Tidak mengarang.",
    },
    { icon: UserRound, judul: "3. Tanya pengelola", isi: "Pengunjung bisa memilih jawaban pengelola. Lebih lambat: menunggu kamu membalas di sini." },
  ];
  return (
    <Card className="mt-5">
      <ol className="grid gap-4 md:grid-cols-3">
        {langkah.map(({ icon: Icon, judul, isi }) => (
          <li key={judul} className="flex items-start gap-3">
            <span className="grid size-9 shrink-0 place-items-center rounded-full bg-leaf/12 text-forest"><Icon size={17} aria-hidden="true" /></span>
            <span>
              <span className="block text-sm font-semibold text-ink">{judul}</span>
              <span className="mt-0.5 block text-[13px] leading-snug text-abu">{isi}</span>
            </span>
          </li>
        ))}
      </ol>
    </Card>
  );
}
