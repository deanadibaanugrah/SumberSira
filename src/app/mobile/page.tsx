import { ArrowLeft, MonitorSmartphone, Smartphone } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

import mobileBooking from "../../../desain/screenshot/mobile-booking.png";
import mobileHome from "../../../desain/screenshot/mobile-home.png";
import mobileTiket from "../../../desain/screenshot/mobile-tiket.png";

const SCREENS = [
  { title: "Beranda", image: mobileHome },
  { title: "Tiket", image: mobileTiket },
  { title: "Booking", image: mobileBooking },
];

export default function MobilePage() {
  return (
    <main className="app-bg min-h-dvh text-white">
      <section className="mx-auto grid max-w-6xl gap-10 px-6 py-8 lg:grid-cols-[0.9fr_1.1fr] lg:items-center lg:py-14">
        <div>
          <Link href="/" className="glass inline-flex h-11 items-center gap-2 rounded-full px-4 text-sm font-semibold transition hover:bg-white/15">
            <ArrowLeft size={18} /> Kembali
          </Link>

          <div className="mt-12 flex size-16 items-center justify-center rounded-[22px] bg-leaf shadow-lg shadow-black/25">
            <Smartphone size={30} />
          </div>
          <h1 className="mt-6 font-display text-4xl font-semibold leading-tight sm:text-5xl">Aplikasi Pengunjung</h1>
          <p className="mt-4 max-w-xl text-white/75">
            Versi mobile dibuat dengan Flutter di folder <code className="rounded bg-white/10 px-1.5 py-0.5">mobile/</code>.
            Jalankan dari Flutter untuk Android, Chrome, atau Windows.
          </p>

          <div className="mt-8 grid gap-3 text-sm text-white/80">
            <p className="glass flex items-center gap-3 rounded-[18px] p-4">
              <MonitorSmartphone className="shrink-0 text-white" size={20} />
              <span>
                <b className="block text-white">Android / emulator</b>
                <code>cd mobile</code>, lalu <code>flutter run</code>
              </span>
            </p>
            <p className="glass flex items-center gap-3 rounded-[18px] p-4">
              <MonitorSmartphone className="shrink-0 text-white" size={20} />
              <span>
                <b className="block text-white">Mobile web</b>
                <code>cd mobile</code>, lalu <code>flutter run -d chrome</code>
              </span>
            </p>
          </div>
        </div>

        <div className="grid gap-4 sm:grid-cols-3">
          {SCREENS.map((screen) => (
            <figure key={screen.title} className="glass overflow-hidden rounded-[24px] p-3">
              <Image
                src={screen.image}
                alt={`Tampilan mobile ${screen.title}`}
                className="h-auto w-full rounded-[18px]"
                sizes="(min-width: 1024px) 20vw, (min-width: 640px) 30vw, 90vw"
                priority={screen.title === "Beranda"}
              />
              <figcaption className="px-1 pt-3 text-center text-sm font-semibold text-white/85">{screen.title}</figcaption>
            </figure>
          ))}
        </div>
      </section>
    </main>
  );
}
