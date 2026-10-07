import { PDFDocument, StandardFonts, rgb } from "pdf-lib";
import QRCode from "qrcode";

import { rupiah } from "./format";

/*
  Generator invoice PDF di sisi server.

  Kenapa di server: pengguna TIDAK BISA mengedit isinya — PDF dibuat dari data
  yang divalidasi server (harga & nama item diverifikasi terhadap katalog
  src/data/wahana.js, total dihitung ulang), lalu dikirim dari nomor WhatsApp
  resmi lewat Cloud API (lihat src/app/api/invoice/route.js).

  Warna mengikuti brand: leaf #40916c, gelap #172321 (lihat globals.css).
*/
const PAGE = { width: 419.53, height: 595.28 }; // A5 potret
const MARGIN = 36;
const LEAF = rgb(0x40 / 255, 0x91 / 255, 0x6c / 255);
const DARK = rgb(0x17 / 255, 0x23 / 255, 0x21 / 255);
const GRAY = rgb(0.45, 0.47, 0.47);
const COL = { item: MARGIN, qty: 232, price: 300, amount: PAGE.width - MARGIN };

export async function buildInvoicePdf({ code, name, whatsapp, slot, items, total, payment, issuedAt = new Date() }) {
  const pdf = await PDFDocument.create();
  pdf.setTitle(`Invoice ${code} — Sumber Sira`);
  pdf.setAuthor("Sumber Sira");
  pdf.setCreator("Sistem Sumber Sira (otomatis)");
  const page = pdf.addPage([PAGE.width, PAGE.height]);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const regular = await pdf.embedFont(StandardFonts.Helvetica);
  const mono = await pdf.embedFont(StandardFonts.Courier);
  const monoBold = await pdf.embedFont(StandardFonts.CourierBold);

  const fits = (text, font, size, maxWidth) => (font.widthOfTextAtSize(text, size) <= maxWidth ? text : `${text.slice(0, -3)}...`);
  const drawPair = (label, value, y, valueFont = regular) => {
    page.drawText(label, { x: MARGIN, y, size: 7, font: regular, color: GRAY });
    page.drawText(fits(value, valueFont, 9.5, 240), { x: 150, y: y - 1, size: 9.5, font: valueFont, color: DARK });
  };

  // Kepala halaman: pita hijau berisi nama usaha, kode invoice & status LUNAS.
  page.drawRectangle({ x: 0, y: PAGE.height - 84, width: PAGE.width, height: 84, color: DARK });
  page.drawRectangle({ x: 0, y: PAGE.height - 84, width: 6, height: 84, color: LEAF });
  page.drawText("SUMBER SIRA", { x: MARGIN, y: PAGE.height - 44, size: 18, font: bold, color: rgb(1, 1, 1) });
  page.drawText("Invoice Pembayaran Wisata & Wahana", { x: MARGIN, y: PAGE.height - 58, size: 8, font: regular, color: rgb(0.8, 0.87, 0.84) });
  page.drawText("STATUS: LUNAS", { x: MARGIN, y: PAGE.height - 73, size: 8, font: bold, color: LEAF });
  const codeText = code;
  page.drawText(codeText, { x: PAGE.width - MARGIN - mono.widthOfTextAtSize(codeText, 10), y: PAGE.height - 46, size: 10, font: monoBold, color: rgb(1, 1, 1) });
  page.drawText("Dokumen resmi — diterbitkan sistem", { x: PAGE.width - MARGIN - regular.widthOfTextAtSize("Dokumen resmi — diterbitkan sistem", 6.5), y: PAGE.height - 60, size: 6.5, font: regular, color: rgb(0.7, 0.8, 0.77) });

  // Data pemesan.
  let y = PAGE.height - 110;
  page.drawText("Data Pemesan", { x: MARGIN, y, size: 9, font: bold, color: DARK });
  y -= 15;
  drawPair("Nama Pemesan", name, y);
  y -= 14;
  drawPair("No. WhatsApp", whatsapp, y, mono);
  y -= 14;
  drawPair("Waktu Kunjungan", slot, y, mono);
  y -= 14;
  drawPair("Metode Pembayaran", payment, y);
  y -= 20;

  // Tabel item — angka memakai font mono agar rapi dan mudah diperiksa.
  page.drawLine({ start: { x: MARGIN, y: y + 8 }, end: { x: PAGE.width - MARGIN, y: y + 8 }, thickness: 1, color: DARK });
  page.drawText("Item", { x: COL.item, y, size: 7, font: bold, color: GRAY });
  page.drawText("Qty", { x: COL.qty, y, size: 7, font: bold, color: GRAY });
  page.drawText("Harga", { x: COL.price, y, size: 7, font: bold, color: GRAY });
  page.drawText("Jumlah", { x: COL.amount - monoBold.widthOfTextAtSize("Jumlah", 7), y, size: 7, font: bold, color: GRAY });
  y -= 15;
  for (const item of items) {
    const label = `${item.qty}x ${item.name}`;
    page.drawText(fits(label, regular, 9, 190), { x: COL.item, y, size: 9, font: regular, color: DARK });
    const price = rupiah(item.price);
    const amount = rupiah(item.qty * item.price);
    page.drawText(String(item.qty), { x: COL.qty, y, size: 9, font: mono, color: DARK });
    page.drawText(price, { x: COL.price, y, size: 9, font: mono, color: DARK });
    page.drawText(amount, { x: COL.amount - mono.widthOfTextAtSize(amount, 9), y, size: 9, font: mono, color: DARK });
    y -= 15;
  }
  page.drawLine({ start: { x: MARGIN, y: y + 7 }, end: { x: PAGE.width - MARGIN, y: y + 7 }, thickness: 0.75, color: rgb(0.8, 0.8, 0.8) });

  // Total tagih — server menghitung ulang, bukan menerima dari klien.
  y -= 8;
  page.drawText("TOTAL DIBAYAR", { x: 150, y, size: 9, font: bold, color: DARK });
  const totalText = rupiah(total);
  page.drawText(totalText, { x: COL.amount - monoBold.widthOfTextAtSize(totalText, 13), y: y - 3, size: 13, font: monoBold, color: LEAF });

  // QR kode booking untuk ditunjukkan di pintu masuk.
  const qrPng = await QRCode.toBuffer(code, { margin: 1, width: 96, color: { dark: "#172321FF", light: "#00000000" } });
  const qr = await pdf.embedPng(qrPng);
  y -= 108;
  page.drawRectangle({ x: MARGIN, y: y - 6, width: qr.width + 12, height: qr.height + 12, borderColor: rgb(0.8, 0.8, 0.8), borderWidth: 1, color: rgb(0.97, 0.98, 0.97) });
  page.drawImage(qr, { x: MARGIN + 6, y, width: qr.width, height: qr.height });
  const qrX = MARGIN + qr.width + 20;
  page.drawText("Tunjukkan QR ini di pintu masuk", { x: qrX, y: y + qr.height - 10, size: 8.5, font: bold, color: DARK });
  page.drawText(`Kode booking: ${code}`, { x: qrX, y: y + qr.height - 23, size: 8, font: mono, color: DARK });
  page.drawText("Invoice sah diterbitkan oleh sistem Sumber Sira;", { x: qrX, y: y + qr.height - 36, size: 7, font: regular, color: GRAY });
  page.drawText("file PDF ini tidak dapat diedit oleh pemesan.", { x: qrX, y: y + qr.height - 46, size: 7, font: regular, color: GRAY });

  // Kaki halaman.
  const stamp = `${issuedAt.toLocaleDateString("id-ID", { day: "2-digit", month: "2-digit", year: "numeric" })} ${issuedAt.toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit" })} WIB`;
  const stampText = `Dicetak otomatis: ${stamp}`;
  page.drawText(stampText, { x: PAGE.width - MARGIN - regular.widthOfTextAtSize(stampText, 7), y: MARGIN + 14, size: 7, font: regular, color: GRAY });
  page.drawText("Simpan invoice ini sebagai bukti pembayaran sah.", { x: MARGIN, y: MARGIN + 14, size: 7, font: regular, color: GRAY });

  return pdf.save();
}
