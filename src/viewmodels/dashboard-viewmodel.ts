"use client";

import { api } from "@/repositories/http-client";
import { createPollStore } from "@/viewmodels/poll-store";
import type { DashboardData } from "@/models/dashboard";



const store = createPollStore<DashboardData>(() => api<DashboardData>("GET", "/api/admin/dashboard"), 10_000);

export function useDashboard() {
  const { data, ready, error } = store.use();
  return { data, ready, error, refresh: store.refresh };
}
