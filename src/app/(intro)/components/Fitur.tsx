import { Calendar, Camera, ChartColumn, MessageSquare } from "lucide-react";

// Fitur utama aplikasi pengunjung yang diperkenalkan di web intro.
const FEATURES = [
  { title: "Booking tanpa antre", text: "Sewa ban, loker, ATV, flying fox, dan wahana lain dari rumah.", icon: Calendar },
  { title: "Live Crowd (AI)", text: "Cek keramaian real-time dan prediksi jam sepi sebelum berangkat.", icon: ChartColumn },
  { title: "AI Photo Studio", text: "Foto bawah air jadi lebih jernih dengan enhance otomatis.", icon: Camera },
  { title: "Tanya Sira", text: "Chatbot yang menjawab pertanyaan seputar Sumber Sira.", icon: MessageSquare },
];

// Daftar fitur utama aplikasi.
export default function Fitur() {
  return (
    <>
      <h2 className="font-display text-3xl font-semibold">Apa yang bisa dilakukan?</h2>
      <ul className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {FEATURES.map(({ title, text, icon: Icon }) => (
          <li key={title} className="glass rounded-[24px] p-5">
            <span className="grid size-12 place-items-center rounded-2xl bg-leaf/45"><Icon size={22} /></span>
            <h3 className="mt-4 font-semibold">{title}</h3>
            <p className="mt-1.5 text-sm text-white/70">{text}</p>
          </li>
        ))}
      </ul>
    </>
  );
}
