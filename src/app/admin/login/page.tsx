import { redirect } from "next/navigation";

import { getOptionalAdmin } from "@/lib/auth/dal";
import { safeAdminPath } from "@/lib/auth/redirect";

import BrandMobile from "./components/BrandMobile";
import LoginBackdrop from "./components/LoginBackdrop";
import LoginForm from "./components/LoginForm";
import LoginIntro from "./components/LoginIntro";
import WidgetTablet from "./components/WidgetTablet";

// Halaman login admin (server). Kalau sesi masih berlaku, langsung masuk ke panel.
// ?next= dibawa dari proxy.ts agar setelah login kembali ke halaman yang tadi dibuka.
// Latar bergerak dari foto asli Sumber Sira + widget kaca melayang dengan angka live dari data tiket.
// Tiap bagian ada di folder components/, halaman ini hanya menyusun tata letaknya.
export default async function AdminLoginPage({ searchParams }: { searchParams: Promise<{ next?: string }> }) {
  const next = safeAdminPath((await searchParams).next);
  if (await getOptionalAdmin()) redirect(next);

  return (
    <main className="relative min-h-dvh overflow-hidden text-ink">
      <LoginBackdrop />

      <div className="relative z-10 mx-auto grid min-h-dvh max-w-[1440px] grid-cols-[minmax(0,1fr)] items-center gap-10 px-4 py-8 sm:px-8 lg:grid-cols-[minmax(0,1.15fr)_minmax(0,1fr)] lg:px-14">
        <LoginIntro />

        {/* Kanan: form masuk */}
        <section className="flex min-w-0 flex-col items-center">
          <BrandMobile />
          <LoginForm next={next} />
          <WidgetTablet />
        </section>
      </div>
    </main>
  );
}
