import { Bot, MessageSquareText, UserRound } from "lucide-react";

import { Card } from "@/components/admin/ui";

// Penjelasan singkat cara Tanya Sira menjawab: tombol cepat dan FAQ dijawab persis tulisan admin, pertanyaan bebas dijawab AI
// hanya dari data resmi, dan yang tidak diketahui dicatat untuk admin.
export default function AlurJawaban() {
  const langkah = [
    { icon: MessageSquareText, judul: "1. Tombol cepat dan FAQ", isi: "Tombol di aplikasi yang cocok dengan kata kunci FAQ dijawab persis seperti yang kamu tulis, tanpa AI." },
    { icon: Bot, judul: "2. Pertanyaan bebas dijawab AI", isi: "AI menjawab hanya dari data resmi: harga, wahana, jam kedatangan, keramaian, dan FAQ. Tidak boleh mengarang." },
    { icon: UserRound, judul: "3. Tidak tahu? Dicatat untuk admin", isi: "Pertanyaan yang tidak ada jawabannya masuk ke Belum Terjawab. Buat FAQ baru agar pertanyaan serupa terjawab." },
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
