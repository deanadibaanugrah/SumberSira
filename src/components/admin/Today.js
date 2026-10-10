"use client";

// Tanggal hari ini dalam Bahasa Indonesia, mis. "Sabtu, 10 Oktober 2026".
// Dihitung di browser supaya tidak membeku di tanggal build.
const FORMAT = new Intl.DateTimeFormat("id-ID", { weekday: "long", day: "numeric", month: "long", year: "numeric", timeZone: "Asia/Jakarta" });

export default function Today() {
  return <span suppressHydrationWarning>{FORMAT.format(new Date())}</span>;
}
