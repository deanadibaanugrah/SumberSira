import { SLOTS, WAHANA, bookingLabel } from "@/data/wahana";
import { buildInvoicePdf } from "@/lib/invoice-pdf";
import { rupiah } from "@/lib/format";
import { PAYMENT_METHODS } from "@/lib/payment";
import { normalizeWhatsapp } from "@/lib/whatsapp";

/*
  POST /api/invoice: buat invoice PDF di server lalu kirim dari nomor WhatsApp
  RESMI Sumber Sira ke nomor penyewa (WhatsApp Cloud API Meta).

  Anti-rekayasa (tahap tanpa database):
  • nama item, harga & total diambil/dihitung ulang dari katalog src/data/wahana.js,
    bukan dari data klien, jadi PDF tidak bisa "dipalsukan" dari sisi pengguna;
  • PDF digenerate di server, jadi tidak bisa diedit pengguna;
  • pengiriman dari nomor bisnis resmi (WHATSAPP_PHONE_NUMBER_ID), bukan wa.me.

  Tahap backend: simpan booking di DB + verifikasi pembayaran via webhook
  payment gateway sebelum nomor ini dihitung lunas.

  Env (.env.local): WHATSAPP_TOKEN, WHATSAPP_PHONE_NUMBER_ID, opsional WHATSAPP_API_VERSION.
*/
const WA_PATTERN = /^(\+?62|0)8\d{8,12}$/;
const CODE_PATTERN = /^SS-\d{8}-\d{3}$/;
const json = (status, body) => Response.json(body, { status });

export async function POST(request) {
  let input;
  try {
    input = await request.json();
  } catch {
    return json(400, { ok: false, error: "invalid_payload" });
  }

  // --- Validasi & derivasi data di server --------------------------------
  const { code, name, whatsapp, slot, payment } = input ?? {};
  if (typeof code !== "string" || !CODE_PATTERN.test(code)) return json(400, { ok: false, error: "invalid_payload" });
  if (typeof name !== "string" || !name.trim() || name.length > 80) return json(400, { ok: false, error: "invalid_payload" });
  const wa = normalizeWhatsapp(typeof whatsapp === "string" ? whatsapp : "");
  if (!WA_PATTERN.test(wa)) return json(400, { ok: false, error: "invalid_whatsapp" });
  const slotInfo = SLOTS.find((s) => s.id === slot);
  if (!slotInfo) return json(400, { ok: false, error: "invalid_payload" });
  if (!PAYMENT_METHODS.includes(payment)) return json(400, { ok: false, error: "invalid_payload" });

  const rawItems = Array.isArray(input?.items) ? input.items : [];
  if (!rawItems.length || rawItems.length > 50) return json(400, { ok: false, error: "invalid_payload" });
  const items = [];
  for (const raw of rawItems) {
    const wahana = WAHANA.find((w) => w.id === raw?.id);
    const qty = Number(raw?.qty);
    // Harga & nama dari katalog server, jadi klien tidak bisa memanipulasi nominal.
    if (!wahana || !Number.isInteger(qty) || qty < 1 || qty > 99) return json(400, { ok: false, error: "invalid_payload" });
    items.push({ name: bookingLabel(wahana), qty, price: wahana.price });
  }
  const total = items.reduce((sum, item) => sum + item.qty * item.price, 0);

  // --- Buat PDF invoice di server ---------------------------------------
  let pdfBytes;
  try {
    pdfBytes = await buildInvoicePdf({ code, name: name.trim(), whatsapp: wa, slot: slotInfo.range, items, total, payment });
  } catch (err) {
    console.error("invoice pdf gagal:", err?.message || err);
    return json(500, { ok: false, error: "pdf_failed" });
  }

  // --- Kirim dari nomor resmi via WhatsApp Cloud API ----------------------
  const token = process.env.WHATSAPP_TOKEN;
  const phoneId = process.env.WHATSAPP_PHONE_NUMBER_ID;
  if (!token || !phoneId) return json(503, { ok: false, error: "missing_config" });
  const version = process.env.WHATSAPP_API_VERSION || "v25.0";
  const filename = `Invoice-SumberSira-${code}.pdf`;
  const auth = { Authorization: `Bearer ${token}` };

  try {
    // 1) Upload PDF sebagai media resmi.
    const form = new FormData();
    form.append("messaging_product", "whatsapp");
    form.append("type", "application/pdf");
    form.append("file", new Blob([pdfBytes], { type: "application/pdf" }), filename);
    const upload = await fetch(`https://graph.facebook.com/${version}/${phoneId}/media`, {
      method: "POST", headers: auth, body: form, signal: AbortSignal.timeout(20000),
    });
    const uploaded = await upload.json().catch(() => null);
    if (!upload.ok || !uploaded?.id) {
      console.error("upload media WhatsApp gagal:", upload.status, uploaded);
      return json(502, { ok: false, error: "provider_error" });
    }

    // 2) Kirim document message (PDF) ke nomor penyewa.
    const send = await fetch(`https://graph.facebook.com/${version}/${phoneId}/messages`, {
      method: "POST",
      headers: { ...auth, "Content-Type": "application/json" },
      body: JSON.stringify({
        messaging_product: "whatsapp",
        recipient_type: "individual",
        to: wa,
        type: "document",
        document: {
          id: uploaded.id,
          filename,
          caption: `Invoice resmi ${code}, total ${rupiah(total)}. Terima kasih sudah berkunjung ke Sumber Sira!`,
        },
      }),
      signal: AbortSignal.timeout(20000),
    });
    const sent = await send.json().catch(() => null);
    if (!send.ok) {
      console.error("kirim pesan WhatsApp gagal:", send.status, sent);
      return json(502, { ok: false, error: "provider_error" });
    }

    return json(200, { ok: true, to: wa, messageId: sent?.messages?.[0]?.id ?? null, total });
  } catch (err) {
    console.error("WhatsApp API error:", err?.message || err);
    return json(502, { ok: false, error: "provider_error" });
  }
}
