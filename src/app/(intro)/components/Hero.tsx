import { LayoutGrid, MapPin, Smartphone } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

import LogoMark from "@/components/Logo";
import { FOTO } from "@/lib/foto";

// Bagian atas: foto latar, logo, nama, dan tombol Buka Aplikasi / Masuk Admin.
export default function Hero() {
  return (
    <section className="relative overflow-hidden">
      <Image src={FOTO.heroSawah} alt="" fill priority sizes="100vw" className="object-cover opacity-40" />
      <div className="absolute inset-0 bg-gradient-to-b from-forest/40 via-forest/70 to-forest" />
      <div className="relative mx-auto max-w-5xl px-6 pb-20 pt-16 sm:pt-24">
        <LogoMark size={72} ring className="shadow-lg shadow-black/25" />
        <p className="mt-6 flex items-center gap-2 text-sm text-white/80"><MapPin size={16} /> Desa Putukrejo, Malang</p>
        <h1 className="mt-3 font-display text-5xl font-semibold leading-tight sm:text-6xl">Sumber Sira</h1>
        <p className="mt-3 text-xl text-white/90 sm:text-2xl">Kunjungan Jernih Tanpa Antre</p>
        <p className="mt-5 max-w-xl text-white/75">
          Kolam mata air alami yang jernih dan sejuk, dikelola masyarakat Desa Putukrejo. Booking wahana, cek keramaian,
          dan foto AI bawah air dalam satu aplikasi.
        </p>
        <div className="mt-8 flex flex-wrap gap-4">
          <Link href="/mobile" className="flex h-14 items-center gap-2.5 rounded-full bg-leaf px-7 font-semibold shadow-lg shadow-black/25 transition hover:bg-leaf/90">
            <Smartphone size={20} /> Aplikasi pengunjung: Android (Flutter)
          </Link>
          <Link href="/admin" className="glass flex h-14 items-center gap-2.5 rounded-full px-7 font-semibold transition hover:bg-white/15">
            <LayoutGrid size={20} /> Masuk Admin Panel
          </Link>
        </div>
      </div>
    </section>
  );
}
