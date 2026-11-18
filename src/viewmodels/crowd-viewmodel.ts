"use client";

import { api } from "@/repositories/http-client";
import { createPollStore } from "@/viewmodels/poll-store";
import type { Crowd } from "@/models/crowd";




const store = createPollStore<Crowd>(() => api<Crowd>("GET", "/api/crowd"), 10_000);

export function useCrowd() {
  const { data, ready, error } = store.use();
  // Tidak ada angka cadangan: data harus datang dari backend (lewat BFF /api/crowd) supaya
  // tampilan tidak pernah menampilkan angka yang bukan milik server.
  return { data, ready, error, refresh: store.refresh };
}
