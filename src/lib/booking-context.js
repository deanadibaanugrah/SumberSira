"use client";

import { createContext, useContext, useEffect, useMemo, useState } from "react";

import { SLOTS, WAHANA, bookingLabel } from "@/data/wahana";

// Keranjang booking dibagi ke halaman Booking -> Checkout -> Konfirmasi.
// Disimpan di sessionStorage supaya tidak hilang saat halaman di-refresh.
const BookingContext = createContext(null);
const STORAGE_KEY = "sumber-sira:booking";

const empty = { slot: SLOTS[0].id, qty: {}, name: "", whatsapp: "", payment: "Cash di Lokasi", code: null };

export function BookingProvider({ children }) {
  const [state, setState] = useState(empty);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    try {
      const saved = window.sessionStorage.getItem(STORAGE_KEY);
      // Membaca penyimpanan browser hanya bisa setelah komponen tampil di browser.
      // eslint-disable-next-line react-hooks/set-state-in-effect
      if (saved) setState({ ...empty, ...JSON.parse(saved) });
    } catch {
      // penyimpanan diblokir (mode privat): keranjang tetap jalan, hanya tidak bertahan saat refresh
    }
    setLoaded(true);
  }, []);

  useEffect(() => {
    if (!loaded) return;
    try {
      window.sessionStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch {
      // abaikan
    }
  }, [state, loaded]);

  const value = useMemo(() => {
    const items = WAHANA.filter((w) => state.qty[w.id] > 0).map((w) => ({
      id: w.id, name: bookingLabel(w), short: w.name, price: w.price, qty: state.qty[w.id],
    }));
    const total = items.reduce((sum, item) => sum + item.qty * item.price, 0);
    const slot = SLOTS.find((s) => s.id === state.slot) ?? SLOTS[0];
    return {
      ...state, items, total, slotInfo: slot, loaded,
      setSlot: (slotId) => setState((s) => ({ ...s, slot: slotId })),
      add: (id) => setState((s) => ({ ...s, qty: { ...s.qty, [id]: (s.qty[id] || 0) + 1 } })),
      remove: (id) => setState((s) => ({ ...s, qty: { ...s.qty, [id]: Math.max(0, (s.qty[id] || 0) - 1) } })),
      update: (patch) => setState((s) => ({ ...s, ...patch })),
      reset: () => setState(empty),
    };
  }, [state, loaded]);

  return <BookingContext.Provider value={value}>{children}</BookingContext.Provider>;
}

export function useBooking() {
  const value = useContext(BookingContext);
  if (!value) throw new Error("useBooking harus dipakai di dalam <BookingProvider>");
  return value;
}
