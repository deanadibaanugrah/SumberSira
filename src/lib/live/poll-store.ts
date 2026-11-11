"use client";

import { useSyncExternalStore } from "react";

// Penyimpan data "live" di browser: mengambil data dari server berkala, dibagi ke semua komponen yang memakainya,
// dan SENGAJA tidak dikosongkan saat pindah halaman. Jadi halaman berikutnya langsung tampil dengan data terakhir
// (lalu disegarkan diam-diam), tidak mulai dari layar kosong. Itu yang membuat pindah halaman admin terasa cepat.
// Polling berhenti saat tidak ada komponen yang memakai atau tab disembunyikan.

export type PollState<T> = { data: T | null; ready: boolean; error: string | null; at: number };

const EMPTY: PollState<any> = { data: null, ready: false, error: null, at: 0 };

export function createPollStore<T>(fetcher: () => Promise<T>, intervalMs: number) {
  let state: PollState<T> = EMPTY as PollState<T>;
  const listeners = new Set<() => void>();
  let timer: ReturnType<typeof setInterval> | null = null;
  let inflight: Promise<void> | null = null;

  const set = (next: PollState<T>) => {
    state = next;
    listeners.forEach((l) => l());
  };

  // Ambil data sekarang. Panggilan yang bertumpuk digabung jadi satu.
  function refresh(): Promise<void> {
    if (inflight) return inflight;
    inflight = (async () => {
      try {
        set({ data: await fetcher(), ready: true, error: null, at: Date.now() });
      } catch (e) {
        // Data lama tetap ditampilkan; hanya tandai ada masalah.
        set({ ...state, error: e instanceof Error ? e.message : "ERROR" });
      } finally {
        inflight = null;
      }
    })();
    return inflight;
  }

  const tick = () => {
    if (!document.hidden) void refresh();
  };

  function subscribe(listener: () => void) {
    listeners.add(listener);
    if (listeners.size === 1) {
      void refresh();
      timer = setInterval(tick, intervalMs);
      document.addEventListener("visibilitychange", tick);
    }
    return () => {
      listeners.delete(listener);
      if (listeners.size === 0) {
        if (timer) clearInterval(timer);
        timer = null;
        document.removeEventListener("visibilitychange", tick);
      }
    };
  }

  // Ubah data di browser seketika (misalnya setelah tombol check-in ditekan) sebelum jawaban server datang.
  function patch(fn: (data: T) => T) {
    if (state.data) set({ ...state, data: fn(state.data) });
  }

  function use(): PollState<T> {
    return useSyncExternalStore(subscribe, () => state, () => EMPTY as PollState<T>);
  }

  return { refresh, patch, use, get: () => state };
}
