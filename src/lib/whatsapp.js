import { rupiah } from "./format";

/*
  Invoice WhatsApp setelah pembayaran (syarat dosen: "after bayar invoice terkirim ke whatsapp user").

  Tahap UTS (frontend): tombol membuka WhatsApp ke nomor pengunjung dengan teks invoice terisi otomatis
  (link wa.me — tanpa server, tanpa API key).

  Tahap backend (dikerjakan kelompok berikutnya): ganti sendInvoice() dengan panggilan ke API backend
  sendiri, mis. POST /api/invoice, yang mengirim pesan otomatis lewat WhatsApp Cloud API (Meta) atau
  gateway WhatsApp. API key disimpan di backend (environment variable), JANGAN di kode frontend.
*/

// 08123456789 / +62 812-3456-789 -> 628123456789
export function normalizeWhatsapp(number) {
  const digits = String(number || "").replace(/\D/g, "");
  if (digits.startsWith("0")) return `62${digits.slice(1)}`;
  if (digits.startsWith("62")) return digits;
  return digits ? `62${digits}` : "";
}

export function buildInvoiceMessage(booking) {
  const lines = booking.items.map((item) => `• ${item.qty}x ${item.name} — ${rupiah(item.qty * item.price)}`);
  return [
    "*INVOICE — Sumber Sira*",
    `Kode: ${booking.code}`,
    `Nama: ${booking.name}`,
    `Waktu kunjungan: ${booking.slot}`,
    "",
    ...lines,
    "",
    `*Total dibayar: ${rupiah(booking.total)}*`,
    `Metode: ${booking.payment}`,
    "",
    "Tunjukkan kode/QR ini di pintu masuk. Terima kasih sudah berkunjung ke Sumber Sira!",
  ].join("\n");
}

export function invoiceLink(booking) {
  const phone = normalizeWhatsapp(booking.whatsapp);
  return `https://wa.me/${phone}?text=${encodeURIComponent(buildInvoiceMessage(booking))}`;
}

// Tahap UTS: buka WhatsApp. Tahap backend: ganti isi fungsi ini dengan fetch("/api/invoice", ...).
export function sendInvoice(booking) {
  window.open(invoiceLink(booking), "_blank", "noopener,noreferrer");
}
