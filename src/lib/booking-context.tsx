"use client";

import { createContext, useContext, useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";

import { SLOTS, WAHANA, bookingLabel } from "@/data/wahana";
import { PAYMENT_METHODS } from "@/lib/payment";

// Satu sumber data metode pembayaran (client & server); di-export ulang agar
// halaman checkout tetap bisa mengimpor dari sini.
export { PAYMENT_METHODS };

// Keranjang booking dibagi ke halaman Booking -> Checkout -> Konfirmasi.
// Disimpan di sessionStorage supaya tidak hilang saat halaman di-refresh.
// Isi keranjang yang disimpan.
type BookingState = { slot: string; qty: Record<string, number>; name: string; whatsapp: string; payment: string; code: string | null; paid: boolean };
// Satu baris item di keranjang.
type BookingItem = { id: string; name: string; short: string; price: number; qty: number };
// Semua yang dibagikan ke halaman: isi keranjang, hasil hitungan, dan fungsi pengubahnya.
export type BookingValue = BookingState & {
  items: BookingItem[]; total: number; slotInfo: (typeof SLOTS)[number]; loaded: boolean;
  setSlot: (slotId: string) => void; add: (id: string) => void; remove: (id: string) => void;
  update: (patch: Partial<BookingState>) => void; reset: () => void;
};

const BookingContext = createContext<BookingValue | null>(null);
const STORAGE_KEY = "sumber-sira:booking";

// paid: true hanya setelah pembayaran QRIS terverifikasi di /app/pembayaran,
// sebelum itu halaman /app/konfirmasi menolak tampil (lihat guard di sana).
const empty: BookingState = { slot: SLOTS[0].id, qty: {}, name: "", whatsapp: "", payment: PAYMENT_METHODS[0], code: null, paid: false };

// Komponen pembungkus yang menyimpan keranjang booking (jam, jumlah item, data pemesan) untuk semua halaman aplikasi.
export function BookingProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<BookingState>(empty);
  const [loaded, setLoaded] = useState(false);

  // Saat aplikasi dibuka: ambil keranjang yang tersimpan di sessionStorage.
  useEffect(() => {
    try {
      const saved = window.sessionStorage.getItem(STORAGE_KEY);
      // Membaca penyimpanan browser hanya bisa setelah komponen tampil di browser.
      if (saved) {
        const parsed = JSON.parse(saved);
        // Sesi lama bisa menyimpan metode yang sudah dihapus; paksa kembali ke pilihan yang valid.
        // eslint-disable-next-line react-hooks/set-state-in-effect
        setState({ ...empty, ...parsed, payment: PAYMENT_METHODS.includes(parsed.payment) ? parsed.payment : empty.payment });
      }
    } catch {
      // penyimpanan diblokir (mode privat): keranjang tetap jalan, hanya tidak bertahan saat refresh
    }
    setLoaded(true);
  }, []);

  // Setiap kali keranjang berubah: simpan lagi ke sessionStorage.
  useEffect(() => {
    if (!loaded) return;
    try {
      window.sessionStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch {
      // abaikan
    }
  }, [state, loaded]);

  // Data yang dibagikan ke halaman: daftar item, total harga, jam kunjungan, dan fungsi untuk mengubahnya.
  const value = useMemo<BookingValue>(() => {
    const items = WAHANA.filter((w) => state.qty[w.id] > 0).map((w) => ({
      id: w.id, name: bookingLabel(w), short: w.name, price: w.price, qty: state.qty[w.id],
    }));
    const total = items.reduce((sum, item) => sum + item.qty * item.price, 0);
    const slot = SLOTS.find((s) => s.id === state.slot) ?? SLOTS[0];
    return {
      ...state, items, total, slotInfo: slot, loaded,
      // Fungsi pengubah keranjang: pilih jam, tambah atau kurangi item, isi data pemesan, dan kosongkan keranjang.
      setSlot: (slotId) => setState((s) => ({ ...s, slot: slotId })),
      add: (id) => setState((s) => ({ ...s, qty: { ...s.qty, [id]: (s.qty[id] || 0) + 1 } })),
      remove: (id) => setState((s) => ({ ...s, qty: { ...s.qty, [id]: Math.max(0, (s.qty[id] || 0) - 1) } })),
      update: (patch) => setState((s) => ({ ...s, ...patch })),
      reset: () => setState(empty),
    };
  }, [state, loaded]);

  return <BookingContext.Provider value={value}>{children}</BookingContext.Provider>;
}

// Hook untuk membaca keranjang booking dari halaman mana pun (harus berada di dalam BookingProvider).
export function useBooking() {
  const value = useContext(BookingContext);
  if (!value) throw new Error("useBooking harus dipakai di dalam <BookingProvider>");
  return value;
}
