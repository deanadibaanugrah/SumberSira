import { BookingProvider } from "@/lib/booking-context";

export const metadata = {
  title: "Sumber Sira App",
};

// Semua halaman aplikasi mobile (URL /app/...). Di HP tampil penuh; di laptop tampil di tengah
// selebar ponsel (maks 430 px) supaya terlihat seperti desain mobile.
export default function MobileLayout({ children }) {
  return (
    <div className="min-h-dvh bg-ink">
      <div className="app-bg relative mx-auto min-h-dvh w-full max-w-[430px] overflow-x-hidden text-white shadow-2xl shadow-black/40">
        <BookingProvider>{children}</BookingProvider>
      </div>
    </div>
  );
}
