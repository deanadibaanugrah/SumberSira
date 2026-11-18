// Jam buka Sumber Sira: weekday 08.00 - 16.00, weekend (Sabtu dan Minggu) 08.00 - 17.00. Hari ditentukan menurut WIB.
export function jamBukaHariIni(now: Date = new Date()): { label: string; weekend: boolean } {
  const hari = new Intl.DateTimeFormat("en-US", { weekday: "short", timeZone: "Asia/Jakarta" }).format(now);
  const weekend = hari === "Sat" || hari === "Sun";
  return { label: weekend ? "08.00 - 17.00" : "08.00 - 16.00", weekend };
}
