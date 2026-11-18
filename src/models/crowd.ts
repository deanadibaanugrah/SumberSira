// Model: bentuk data yang dipakai View dan ViewModel.
// Live Crowd publik untuk halaman yang belum login (widget di halaman login) dan monitor dashboard.
// Mengambil /api/crowd dengan bentuk asli backend: angka ringkas + prakiraan puncak per jam (forecast).
// Tanpa data pengunjung. Di dalam panel admin, data tiket live ada di src/viewmodels/tiket-viewmodel.ts.
export type CrowdForecast = { hour: string; count: number };

export type Crowd = {
  inside: number; percent: number; label: string; capacity: number;
  updatedAt: string | null; forecast: CrowdForecast[];
};
