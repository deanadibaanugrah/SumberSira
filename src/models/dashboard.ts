// Model: bentuk data yang dipakai View dan ViewModel.
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
