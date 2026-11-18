"use client";

import { api } from "@/lib/live/http";
import { createPollStore } from "@/lib/live/poll-store";

// Live Crowd publik untuk halaman yang belum login (widget di halaman login) dan monitor dashboard.
// Mengambil /api/crowd dengan bentuk asli backend: angka ringkas + prakiraan puncak per jam (forecast).
// Tanpa data pengunjung. Di dalam panel admin, data tiket live ada di src/lib/tiket-store.ts.
export type CrowdForecast = { hour: string; count: number };
export type Crowd = {
  inside: number; percent: number; label: string; capacity: number;
  updatedAt: string | null; forecast: CrowdForecast[];
};

const store = createPollStore<Crowd>(() => api<Crowd>("GET", "/api/crowd"), 10_000);

export function useCrowd() {
  const { data, ready, error } = store.use();
  const c = data ?? { inside: 0, percent: 0, label: "Sepi", capacity: 300, updatedAt: null, forecast: [] };
  return { data, ...c, ready, error, refresh: store.refresh };
}
