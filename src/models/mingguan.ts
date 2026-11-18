// Model: bentuk data yang dipakai View dan ViewModel.
export type HariData = { date: string; day: string; tiket: number; sewa: number };

export type MingguanData = {
  days: HariData[];
  total: number;
  pola: { hours: string[]; days: { date: string; day: string; values: number[] }[]; note: string };
  wahana: { id: string; name: string; count: number }[];
};
