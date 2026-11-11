"use client";

import { api } from "@/lib/live/http";
import { createPollStore } from "@/lib/live/poll-store";

// Data grafik keramaian untuk dashboard dan halaman Insight. Semuanya dihitung backend dari tiket yang discan
// (check-in menaikkan, check-out menurunkan, hanya untuk hari itu). Tidak ada AI di sini.

export type TimelinePoint = { at: string; label: string; inside: number; percent: number };
export type HourPoint = { hour: number; peak: number; percent: number };
export type InsightData = {
  date: string;
  summary: {
    sold: number; people: number; revenue: number; entered: number; peak: HourPoint | null;
    payment: { qris: number; cash: number };
    parking: { none: number; motor: number; mobil: number; bus: number };
    source: { app: number; loket: number };
  };
  timeline: TimelinePoint[];
  hourly: HourPoint[];
  crowd: { inside: number; percent: number; label: string; waiting: number; out: number; sold: number; capacity: number } | null;
};

// Satu penyimpan per tanggal yang dilihat (hari ini = kosong).
const stores = new Map<string, ReturnType<typeof createPollStore<InsightData>>>();

function storeFor(date: string) {
  let s = stores.get(date);
  if (!s) {
    s = createPollStore<InsightData>(() => api<InsightData>("GET", `/api/admin/insight${date ? `?date=${date}` : ""}`), 15_000);
    stores.set(date, s);
  }
  return s;
}

// date: "2026-11-11", atau "" untuk hari ini.
export function useInsight(date = "") {
  const { data, ready, error } = storeFor(date).use();
  return { data, ready, error };
}

export type WeekData = {
  hours: string[];
  days: { date: string; day: string; values: number[] }[];
  note: string;
};

const week = createPollStore<WeekData>(() => api<WeekData>("GET", "/api/admin/insight/week"), 60_000);

export function useWeek() {
  const { data, ready } = week.use();
  return { data, ready };
}

// Skala sumbu yang rapi untuk grafik batang: kelipatan 10/20/50/... sampai nilai tertinggi.
export function niceTicks(max: number): number[] {
  const top = Math.max(max, 30);
  const step = [10, 20, 30, 50, 100].find((s) => top / s <= 4) ?? 100;
  const end = Math.ceil(top / step) * step;
  return Array.from({ length: end / step + 1 }, (_, i) => i * step);
}
