"use client";

import { Check, ScanLine } from "lucide-react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { QRCodeSVG } from "qrcode.react";

import PageHeader from "@/components/mobile/PageHeader";
import { LiveCrowdBanner, TicketStatus } from "@/components/mobile/LiveCrowd";
import { rupiah } from "@/lib/format";
import { PARKIR, checkIn, normalisasiKode, useTiket } from "@/lib/tiket-store";

// E-tiket masuk: QR berisi kode tiket. Statusnya ikut berubah saat petugas memindai di /admin/tiket
// (juga bila admin dibuka di tab lain pada browser yang sama).
const HARI_INI = new Intl.DateTimeFormat("id-ID", { weekday: "long", day: "numeric", month: "long", year: "numeric", timeZone: "Asia/Jakarta" });
const PESAN = {
  "Belum masuk": "Tunjukkan QR ini ke petugas di pintu masuk. Setelah discan, kamu ikut terhitung di Live Crowd.",
  "Di dalam": "Kamu sudah masuk dan ikut terhitung di Live Crowd. Selamat bermain air!",
  Keluar: "Tiket sudah dipakai. Terima kasih sudah berkunjung ke Sumber Sira!",
};

export default function ETiketPage() {
  const { kode } = useParams();
  const tiket = useTiket();
  const code = normalisasiKode(decodeURIComponent(kode));
  const t = tiket.tickets.find((x) => x.code === code);

  if (!tiket.ready) return <main className="grid min-h-dvh place-items-center text-xs text-white/70">Memuat e-tiket...</main>;

  if (!t) {
    return (
      <main className="px-5">
        <PageHeader title="E-Tiket Masuk" backHref="/app/tiket" />
        <div className="glass rounded-[20px] p-5 text-center">
          <p className="text-xs text-white/80">Tiket {code} tidak ditemukan untuk hari ini.</p>
          <Link href="/app/tiket" className="mt-3 inline-flex h-10 items-center rounded-full bg-leaf px-6 text-xs font-semibold">Beli tiket</Link>
        </div>
      </main>
    );
  }

  const parkir = PARKIR.find((p) => p.id === t.parking);
  const rows = [
    ["Nama", t.name],
    ["Pengunjung", `${t.adults} orang${t.kids ? ` + ${t.kids} balita` : ""}`],
    ["Parkir", parkir && parkir.id !== "none" ? parkir.label : "Tidak"],
    ["Berlaku", HARI_INI.format(new Date())],
    ["Total dibayar", rupiah(t.total)],
  ];

  return (
    <main className="px-5 pb-10">
      <PageHeader title="E-Tiket Masuk" backHref="/app/tiket" />

      <section className="glass flex flex-col items-center rounded-[24px] px-5 pb-5 pt-6">
        <div className={`relative rounded-[20px] bg-white/90 p-5 transition ${t.status === "Belum masuk" ? "" : "opacity-60"}`}>
          <QRCodeSVG value={t.code} size={170} bgColor="transparent" fgColor="#172321" level="M" />
          {t.status === "Di dalam" && (
            <span className="absolute inset-0 grid place-items-center">
              <span className="grid size-16 place-items-center rounded-full bg-leaf text-white shadow-lg animate-pop"><Check size={32} strokeWidth={3} /></span>
            </span>
          )}
        </div>
        <p className="mt-4 font-mono text-xl font-semibold tracking-wider">{t.code}</p>
        <TicketStatus status={t.status} className="mt-2" />
        <p className="mt-3 max-w-[280px] text-center text-[11px] leading-snug text-white/80">{PESAN[t.status]}</p>
        {t.checkInAt && <p className="mt-1 font-mono text-[10px] text-white/65">Masuk {t.checkInAt}{t.checkOutAt ? ` · keluar ${t.checkOutAt}` : ""}</p>}
      </section>

      <dl className="glass mt-4 grid grid-cols-[120px_1fr] gap-y-3 rounded-[20px] px-5 py-4">
        {rows.map(([k, v]) => (
          <div key={k} className="contents">
            <dt className="text-[10px] text-white/70">{k}</dt>
            <dd className="text-[11px] font-semibold" suppressHydrationWarning>{v}</dd>
          </div>
        ))}
      </dl>

      <div className="mt-4"><LiveCrowdBanner /></div>

      {t.status === "Belum masuk" && (
        <button type="button" onClick={() => checkIn(t.code)}
                className="glass mt-4 flex h-11 w-full items-center justify-center gap-2 rounded-full text-[11px] font-semibold transition hover:bg-white/15">
          <ScanLine size={15} /> Simulasi scan petugas (demo)
        </button>
      )}

      <Link href="/app/home"
            className="mt-3 flex h-[50px] items-center justify-center rounded-full bg-leaf text-[13px] font-semibold shadow-lg shadow-black/25 transition hover:brightness-110">
        Kembali ke Beranda
      </Link>
    </main>
  );
}
