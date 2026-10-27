// Format tanggal foto, contoh: 10 Okt 2026.
const DATE = new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "short", year: "numeric", timeZone: "UTC" });
export const formatDate = (iso) => DATE.format(new Date(`${iso}T00:00:00Z`)).replace(".", "");
