// Format angka ke Rupiah: 45000 -> "Rp45.000" (tanpa spasi, seperti di desain).
export function rupiah(value) {
  return `Rp${Number(value || 0).toLocaleString("id-ID")}`;
}

// Kode booking: SS-YYYYMMDD-NNN.
export function bookingCode(date = new Date()) {
  const ymd = `${date.getFullYear()}${String(date.getMonth() + 1).padStart(2, "0")}${String(date.getDate()).padStart(2, "0")}`;
  const seq = String(Math.floor(Math.random() * 900) + 100);
  return `SS-${ymd}-${seq}`;
}
