"use client";

import { api } from "@/lib/live/http";
import { createPollStore } from "@/lib/live/poll-store";
import { statusKeramaian } from "@/lib/tiket-store";

// Live Crowd publik untuk halaman yang belum login (widget di halaman login). Mengambil /api/crowd,
// yang hanya berisi angka ringkas. Di dalam panel admin pakai useTiket() (src/lib/tiket-store.ts).
type Crowd = { inside: number; percent: number; label: string; waiting: number; out: number; sold: number; capacity: number };

const store = createPollStore<Crowd>(() => api<Crowd>("GET", "/api/crowd"), 10_000);

export function useCrowd() {
  const { data, ready } = store.use();
  const c = data ?? { inside: 0, percent: 0, label: statusKeramaian(0), waiting: 0, out: 0, sold: 0, capacity: 300 };
  return { ...c, ready };
}
