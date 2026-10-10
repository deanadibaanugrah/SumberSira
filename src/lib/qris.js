/*
  Pembuat payload QRIS (standar EMVCo QR Code) untuk tahap frontend.

  QR yang tampil di halaman pembayaran memuat nominal yang HARUS dibayar (tag 54)
  dan kode booking sebagai referensi (tag 62/05), jadi aplikasi bank/e-wallet
  menampilkan nominal yang sama persis saat scan (QR dinamis, tag 01 = "12").

  Tahap backend (kelompok berikutnya): payload asli diterbitkan payment gateway
  lewat API, bukan dibuat di browser. Struktur & CRC tetap sama.
*/

// Satu field TLV: tag (2 digit) + panjang nilai (2 digit) + nilai.
function tlv(tag, value) {
  const text = String(value ?? "");
  return `${tag}${String(text.length).padStart(2, "0")}${text}`;
}

// CRC16-CCITT (polinom 0x1021, init 0xFFFF), checksum wajib di akhir payload QRIS.
function crc16(text) {
  let crc = 0xffff;
  for (let i = 0; i < text.length; i += 1) {
    crc ^= text.charCodeAt(i) << 8;
    for (let bit = 0; bit < 8; bit += 1) {
      crc = crc & 0x8000 ? (crc << 1) ^ 0x1021 : crc << 1;
      crc &= 0xffff;
    }
  }
  return crc.toString(16).toUpperCase().padStart(4, "0");
}

// amount dalam rupiah (angka bulat), reference = kode booking.
export function buildQrisPayload({ merchant, city, amount, reference }) {
  const merchantAccount = tlv("00", "ID.CO.QRIS.WWW") + tlv("01", "936009140000000123"); // akun merchant demo
  const body = [
    tlv("00", "01"), // payload format indicator
    tlv("01", "12"), // 12 = QR dinamis (nominal ikut di dalam QR)
    tlv("26", merchantAccount),
    tlv("52", "5812"), // merchant category: wisata/kuliner
    tlv("53", "360"), // mata uang: IDR
    tlv("54", `${Number(amount || 0)}.00`), // nominal yang harus dibayar
    tlv("58", "ID"),
    tlv("59", String(merchant).toUpperCase().slice(0, 25)),
    tlv("60", String(city).toUpperCase().slice(0, 15)),
    tlv("62", tlv("05", reference)), // referensi: kode booking
  ].join("");
  const withCrcTag = `${body}6304`;
  return withCrcTag + crc16(withCrcTag);
}
