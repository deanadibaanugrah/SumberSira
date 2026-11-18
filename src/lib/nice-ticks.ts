// Skala sumbu yang rapi untuk grafik batang: kelipatan 10/20/30/50/100 sampai nilai tertinggi.
// Dipakai grafik keramaian dashboard (LiveCrowdMonitor).
export function niceTicks(max: number): number[] {
  const top = Math.max(max, 30);
  const step = [10, 20, 30, 50, 100].find((s) => top / s <= 4) ?? 100;
  const end = Math.ceil(top / step) * step;
  return Array.from({ length: end / step + 1 }, (_, i) => i * step);
}
