import { Calendar, Camera, ChartColumn, Clock, LayoutGrid, MapPin, MessageSquare, Smartphone, Ticket } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

// Introduction web (syarat dosen: "introduction web dan app").
// Halaman ini tidak ada di Figma; dibuat dengan gaya yang sama untuk mengarahkan ke aplikasi dan admin.
const FEATURES = [
  { title: "Booking tanpa antre", text: "Sewa ban, loker, ATV, flying fox, dan wahana lain dari rumah.", icon: Calendar },
  { title: "Live Crowd (AI)", text: "Cek keramaian real-time dan prediksi jam sepi sebelum berangkat.", icon: ChartColumn },
  { title: "AI Photo Studio", text: "Foto bawah air jadi lebih jernih dengan enhance otomatis.", icon: Camera },
  { title: "Tanya Sira", text: "Chatbot yang menjawab pertanyaan seputar Sumber Sira.", icon: MessageSquare },
];

export default function IntroPage() {
  return (
    <main className="app-bg min-h-dvh text-white">
      <section className="relative overflow-hidden">
        <Image src="/images/hero-sawah.webp" alt="" fill priority sizes="100vw" className="object-cover opacity-40" />
        <div className="absolute inset-0 bg-gradient-to-b from-forest/40 via-forest/70 to-[#1b3a2f]" />
        <div className="relative mx-auto max-w-5xl px-6 pb-20 pt-16 sm:pt-24">
          <p className="flex items-center gap-2 text-sm text-white/80"><MapPin size={16} /> Desa Putukrejo, Malang</p>
          <h1 className="mt-4 font-display text-5xl font-semibold leading-tight sm:text-6xl">Sumber Sira</h1>
          <p className="mt-3 text-xl text-white/90 sm:text-2xl">Kunjungan Jernih Tanpa Antre</p>
          <p className="mt-5 max-w-xl text-white/75">
            Kolam mata air alami yang jernih dan sejuk, dikelola masyarakat Desa Putukrejo. Booking wahana, cek keramaian,
            dan foto AI bawah air dalam satu aplikasi.
          </p>
          <div className="mt-8 flex flex-wrap gap-4">
            <Link href="/app" className="flex h-14 items-center gap-2.5 rounded-full bg-leaf px-7 font-semibold shadow-lg shadow-black/25 transition hover:brightness-110">
              <Smartphone size={20} /> Buka Aplikasi
            </Link>
            <Link href="/admin" className="glass flex h-14 items-center gap-2.5 rounded-full px-7 font-semibold transition hover:bg-white/15">
              <LayoutGrid size={20} /> Masuk Admin Panel
            </Link>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-6 py-14">
        <h2 className="font-display text-3xl font-semibold">Apa yang bisa dilakukan?</h2>
        <ul className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {FEATURES.map(({ title, text, icon: Icon }) => (
            <li key={title} className="glass rounded-[24px] p-5">
              <span className="grid size-12 place-items-center rounded-2xl bg-moss"><Icon size={22} /></span>
              <h3 className="mt-4 font-semibold">{title}</h3>
              <p className="mt-1.5 text-sm text-white/70">{text}</p>
            </li>
          ))}
        </ul>

        <div className="mt-10 grid gap-4 sm:grid-cols-2">
          <p className="glass flex items-center gap-4 rounded-[24px] p-5">
            <Clock className="shrink-0" /> <span><b className="block">Jam buka</b><span className="text-sm text-white/70">Weekday 08.00–16.00 · Weekend s/d 17.00</span></span>
          </p>
          <p className="glass flex items-center gap-4 rounded-[24px] p-5">
            <Ticket className="shrink-0" /> <span><b className="block">Tiket masuk</b><span className="text-sm text-white/70">Rp5.000 per orang (usia 3 tahun ke atas)</span></span>
          </p>
        </div>
      </section>

      <footer className="border-t border-white/10 px-6 py-6 text-center text-sm text-white/55">
        Sumber Sira · Tugas kelompok (UTS) — Next.js + Tailwind CSS
      </footer>
    </main>
  );
}
