// Format tanggal foto dalam WIB, contoh: 10 Okt 2026. Tanggal kosong atau tidak valid menjadi "-".
const DATE = new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "short", year: "numeric", timeZone: "Asia/Jakarta" });
export const formatDate = (iso?: string | null) => {
  if (!iso) return "-";
  const tanggal = new Date(iso);
  return Number.isNaN(tanggal.getTime()) ? "-" : DATE.format(tanggal).replace(".", "");
};
