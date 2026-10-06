import { Car, Clock, Droplet, Fish, LifeBuoy, MapPin, Tent, Ticket, Users, Wallet } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

// Introduction aplikasi: "Tentang Sumber Sira" (syarat dosen: introduction app).
const FEATURES = [
  { label: "Air jernih", icon: Droplet },
  { label: "Ikan wader", icon: Fish },
  { label: "Kolam anak", icon: LifeBuoy },
  { label: "Gazebo", icon: Tent },
];

const INFO = [
  { title: "Jam buka", text: "Weekday 08.00–16.00 · Weekend s/d 17.00", icon: Clock },
  { title: "Tiket masuk", text: "Rp5.000 per orang (usia 3 tahun ke atas)", icon: Ticket },
  { title: "Parkir", text: "Motor 3rb · Mobil 10rb · Bus 20rb", icon: Car },
  { title: "Pembayaran", text: "Tunai & QRIS", icon: Wallet },
];

export default function TentangPage() {
  return (
    <main className="px-5 pb-6">
      <header className="flex items-center justify-between pt-9 pb-4">
        <span className="font-display text-base font-semibold">Sumber Sira</span>
        <Link href="/app/home" className="mr-[25px] text-[11px] font-semibold text-white/75 hover:text-white">Lewati</Link>
      </header>

      <div className="relative aspect-[67/40] overflow-hidden rounded-[18px] border border-white/20">
        <Image src="/images/sawah-sumber-sira.webp" alt="Kolam dan sawah di Sumber Sira" fill sizes="430px" className="object-cover" priority />
        <span className="absolute left-3.5 top-3.5 flex items-center gap-1.5 rounded-full bg-black/30 px-2.5 py-1.5 text-[11px] font-medium backdrop-blur-sm">
          <MapPin size={12} /> Desa Putukrejo, Malang
        </span>
      </div>

      <h1 className="mt-5 font-display text-[26px] font-semibold leading-tight">Tentang Sumber Sira</h1>
      <p className="mt-1.5 text-[13px] leading-[1.35] text-white/80">
        Kolam mata air alami yang jernih dan sejuk — seru buat berenang, main air, dan foto bareng keluarga.
      </p>

      <p className="glass mt-3 inline-flex h-[29px] items-center gap-2 rounded-full px-3 text-[11px]">
        <Users size={13} /> Dikelola masyarakat Desa Putukrejo
      </p>

      <ul className="mt-4 grid grid-cols-4 text-center">
        {FEATURES.map(({ label, icon: Icon }) => (
          <li key={label} className="flex flex-col items-center gap-2">
            <span className="grid size-[52px] place-items-center rounded-full border border-white/25 bg-leaf/30">
              <Icon size={20} />
            </span>
            <span className="text-[11px] text-white/90">{label}</span>
          </li>
        ))}
      </ul>

      <ul className="glass mt-5 divide-y divide-white/15 rounded-[20px] px-4 py-0.5">
        {INFO.map(({ title, text, icon: Icon }) => (
          <li key={title} className="flex h-12 items-center gap-3">
            <span className="grid size-8 shrink-0 place-items-center rounded-full bg-leaf/35"><Icon size={15} /></span>
            <span>
              <span className="block text-xs font-semibold">{title}</span>
              <span className="block text-[11px] text-white/70">{text}</span>
            </span>
          </li>
        ))}
      </ul>

      <Link href="/app/onboarding"
            className="mt-4 flex h-[50px] items-center justify-center rounded-full bg-leaf text-[13px] font-semibold shadow-lg shadow-black/25 transition hover:brightness-110">
        Lanjut
      </Link>
    </main>
  );
}
