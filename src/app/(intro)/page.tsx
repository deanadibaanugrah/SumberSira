import Fitur from "./components/Fitur";
import Footer from "./components/Footer";
import Hero from "./components/Hero";
import InfoKunjungan from "./components/InfoKunjungan";

// Introduction web (syarat dosen: "introduction web dan app").
// Halaman ini tidak ada di Figma; dibuat dengan gaya yang sama untuk mengarahkan ke aplikasi dan admin.
// Tiap bagian halaman ada di folder components/ (Hero, Fitur, InfoKunjungan, Footer).
export default function IntroPage() {
  return (
    <main className="app-bg min-h-dvh text-white">
      <Hero />
      <section className="mx-auto max-w-5xl px-6 py-14">
        <Fitur />
        <InfoKunjungan />
      </section>
      <Footer />
    </main>
  );
}
