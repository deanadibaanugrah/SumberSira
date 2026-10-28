// Format angka ke Rupiah: 45000 -> "Rp45.000" (tanpa spasi, seperti di desain).
export function rupiah(value) {
  return `Rp${Number(value || 0).toLocaleString("id-ID")}`;
}
