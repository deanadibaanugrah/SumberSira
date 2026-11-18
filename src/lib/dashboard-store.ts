"use client";

import { api } from "@/lib/live/http";
import { createPollStore } from "@/lib/live/poll-store";

// Ringkasan operasional hari ini untuk kartu dashboard (GET /admin/dashboard via BFF).
// Angka dihitung backend dari tiket & booking LUNAS hari ini, plus pembayaran yang masih menunggu.
export type DashboardData = {
  ticketsToday: number;
  visitorsToday: number;
  bookingsToday: number;
  revenueToday: number;
  pendingCash: number;
  pendingQris: number;
  crowd: { inside: number; capacity: number; percent: number; label: string };
};

const store = createPollStore<DashboardData>(() => api<DashboardData>("GET", "/api/admin/dashboard"), 10_000);

export function useDashboard() {
  const { data, ready, error } = store.use();
  return { data, ready, error, refresh: store.refresh };
}
