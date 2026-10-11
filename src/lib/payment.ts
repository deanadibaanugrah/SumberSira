// Metode pembayaran yang didukung, satu sumber data untuk client & server
// (server memvalidasi isi invoice terhadap daftar ini, lihat /api/invoice).
// Metode cash di lokasi sudah dihapus; hanya QRIS.
export const PAYMENT_METHODS = ["QRIS"];
