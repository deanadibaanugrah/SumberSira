import { MessageSquareText, UserRound } from "lucide-react";

import { Card } from "@/components/admin/ui";

// Penjelasan singkat cara Tanya Sira menjawab: cocok dengan FAQ, atau pertanyaannya dicatat untuk admin.
export default function AlurJawaban() {
  const langkah = [
    { icon: MessageSquareText, judul: "1. Cocokkan dengan FAQ", isi: "Pertanyaan pengunjung dicocokkan dengan kata kunci FAQ. Jika cocok, jawabannya langsung dikirim." },
    { icon: UserRound, judul: "2. Dicatat untuk admin", isi: "Pertanyaan yang belum cocok masuk ke daftar Belum Terjawab. Buat FAQ baru agar pertanyaan serupa dijawab otomatis." },
  ];
  return (
    <Card className="mt-5">
      <ol className="grid gap-4 md:grid-cols-2">
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
