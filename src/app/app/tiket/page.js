"use client";

import { ChevronRight, Loader2, Minus, Plus, Ticket } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { QRCodeSVG } from "qrcode.react";

import PageHeader from "@/components/mobile/PageHeader";
import { LiveCrowdBanner, TicketStatus } from "@/components/mobile/LiveCrowd";
import { useBooking } from "@/lib/booking-context";
import { rupiah } from "@/lib/format";
import { buildQrisPayload } from "@/lib/qris";
import { HARGA_TIKET, PARKIR, beliTiket, hargaTiket, useTiket } from "@/lib/tiket-store";

// Tiket masuk online: pilih jumlah pengunjung dan parkir, isi data, bayar QRIS, lalu dapat e-tiket QR.
// Saat QR discan petugas, pengunjung ikut terhitung di Live Crowd (lihat src/lib/tiket-store.js).
const WA_PATTERN = /^(\+?62|0)8\d{8,12}$/;
const inputClass = "glass mt-1 h-11 w-full rounded-2xl px-4 text-[11px] text-white outline-none placeholder:text-white/55 focus:border-white/50";
const HARI_INI = new Intl.DateTimeFormat("id-ID", { weekday: "long", day: "numeric", month: "long", timeZone: "Asia/Jakarta" });

function Stepper({ label, value, onChange, min, max }) {
  return (
    <span className="flex h-7 items-center gap-1.5 rounded-full bg-leaf/90 px-0.5">
      <button type="button" onClick={() => onChange(Math.max(min, value - 1))} disabled={value <= min} aria-label={`Kurangi ${label}`}
              className="grid size-6 place-items-center rounded-full bg-white/15 hover:bg-white/25 disabled:opacity-40"><Minus size={12} strokeWidth={3} /></button>
      <span className="w-4 text-center font-mono text-[11px] font-semibold" aria-live="polite">{value}</span>
      <button type="button" onClick={() => onChange(Math.min(max, value + 1))} disabled={value >= max} aria-label={`Tambah ${label}`}
              className="grid size-6 place-items-center rounded-full bg-white/15 hover:bg-white/25 disabled:opacity-40"><Plus size={12} strokeWidth={3} /></button>
    </span>
  );
}

export default function TiketPage() {
  const router = useRouter();
  const booking = useBooking();
  const tiket = useTiket();
  const [adults, setAdults] = useState(2);
  const [kids, setKids] = useState(0);
  const [parking, setParking] = useState("motor");
  const [name, setName] = useState(booking.name);
  const [whatsapp, setWhatsapp] = useState(booking.whatsapp);
  const [errors, setErrors] = useState({});
  const [step, setStep] = useState("form"); // form | bayar
  const [ref, setRef] = useState("");
  const [checking, setChecking] = useState(false);

  const total = hargaTiket(adults, parking);
  const mine = tiket.tickets.filter((t) => t.mine).reverse();

  const lanjut = (e) => {
    e.preventDefault();
    const next = {};
    if (!name.trim()) next.name = "Nama wajib diisi.";
    if (!WA_PATTERN.test(whatsapp.replace(/[\s-]/g, ""))) next.whatsapp = "Masukkan nomor WhatsApp yang valid, mis. 081234567890.";
    setErrors(next);
    if (Object.keys(next).length) return;
    booking.update({ name, whatsapp }); // isi otomatis di form booking wahana
    setRef(`TIKET-${Date.now().toString().slice(-6)}`);
    setStep("bayar");
    window.scrollTo({ top: 0 });
  };

  // Demo frontend: verifikasi pembayaran disimulasikan, lalu e-tiket diterbitkan.
  const sudahBayar = () => {
    if (checking) return;
    setChecking(true);
    setTimeout(() => {
      const t = beliTiket({ name, whatsapp, adults, kids, parking });
      router.replace(`/app/tiket/${t.code}`);
    }, 1200);
  };

  if (step === "bayar") {
    const payload = buildQrisPayload({ merchant: "Sumber Sira", city: "Malang", amount: total, reference: ref });
    return (
      <main className="px-5 pb-28">
        <PageHeader title="Bayar Tiket Masuk" backHref="/app/home" />
        <div className="flex flex-col items-center">
          <p className="text-center text-[11px] text-white/75">Scan QRIS berikut dengan aplikasi pembayaranmu</p>
          <div className="mt-4 rounded-[20px] bg-white/85 p-5">
            <QRCodeSVG value={payload} size={185} bgColor="transparent" fgColor="#172321" level="M" />
          </div>
          <p className="mt-3.5 font-mono text-lg font-semibold leading-none">{rupiah(total)}</p>
          <p className="mt-1.5 text-center text-[9.5px] text-white/65">
            {adults} orang x {rupiah(HARGA_TIKET)}{kids > 0 ? ` + ${kids} balita gratis` : ""}{parking !== "none" ? ` + parkir ${PARKIR.find((p) => p.id === parking).label.toLowerCase()}` : ""}
          </p>
        </div>
        <ol className="glass mt-5 list-decimal space-y-2.5 rounded-[20px] p-4 pl-8 text-[11px] leading-snug text-white/80 marker:font-semibold marker:text-leaf">
          <li>Buka aplikasi bank atau e-wallet, pilih Bayar / Scan QRIS.</li>
          <li>Pastikan nominal <span className="font-mono font-semibold text-white">{rupiah(total)}</span> sebelum membayar.</li>
          <li>Setelah berhasil, tekan tombol di bawah untuk mengambil e-tiket.</li>
        </ol>
        <button type="button" onClick={() => setStep("form")} className="mt-4 text-[11px] font-semibold text-white/75 underline-offset-2 hover:underline">
          Ubah pesanan
        </button>

        <footer className="fixed inset-x-0 bottom-0 z-30 mx-auto w-full max-w-[430px]">
          <div className="glass flex h-16 items-center justify-between gap-4 rounded-t-[20px] border-b-0 px-5">
            <span>
              <span className="block text-[9.5px] text-white/70">Total Bayar</span>
              <span className="block font-mono text-[13px]">{rupiah(total)}</span>
            </span>
            <button type="button" onClick={sudahBayar} disabled={checking}
                    className="flex h-10 w-[210px] items-center justify-center gap-2 rounded-full bg-leaf text-xs font-semibold transition hover:brightness-110 disabled:opacity-70">
              {checking && <Loader2 size={15} className="animate-spin" />}
              {checking ? "Memeriksa pembayaran..." : "Saya Sudah Bayar"}
            </button>
          </div>
        </footer>
      </main>
    );
  }

  return (
    <main className="px-5 pb-28">
      <PageHeader title="Tiket Masuk Online" backHref="/app/home" />

      <LiveCrowdBanner />

      {mine.length > 0 && (
        <>
          <h2 className="mt-5 text-[11px] font-semibold">Tiket Saya Hari Ini</h2>
          <ul className="mt-2 space-y-2">
            {mine.map((t) => (
              <li key={t.code}>
                <Link href={`/app/tiket/${t.code}`} className="glass flex h-14 items-center gap-3 rounded-[20px] px-4 transition hover:bg-white/15">
                  <span className="grid size-9 shrink-0 place-items-center rounded-full bg-leaf/45"><Ticket size={16} /></span>
                  <span className="flex-1">
                    <span className="block font-mono text-[11px] font-semibold">{t.code}</span>
                    <span className="block text-[10px] text-white/70">{t.adults + t.kids} orang · dibeli {t.boughtAt}</span>
                  </span>
                  <TicketStatus status={t.status} />
                  <ChevronRight size={16} className="text-white/70" />
                </Link>
              </li>
            ))}
          </ul>
        </>
      )}

      <form id="tiket" onSubmit={lanjut} noValidate>
        <h2 className="mt-5 text-[11px] font-semibold">Jumlah Pengunjung</h2>
        <p className="mt-0.5 text-[9.5px] text-white/65" suppressHydrationWarning>Berlaku untuk hari ini, {HARI_INI.format(new Date())}</p>
        <ul className="mt-2 space-y-2">
          <li className="glass flex h-[60px] items-center gap-3 rounded-[20px] px-4">
            <span className="flex-1">
              <span className="block text-[11px]">Usia 3 tahun ke atas</span>
              <span className="mt-[5px] block font-mono text-[11px]">{rupiah(HARGA_TIKET)} / orang</span>
            </span>
            <Stepper label="pengunjung" value={adults} onChange={setAdults} min={1} max={30} />
          </li>
          <li className="glass flex h-[60px] items-center gap-3 rounded-[20px] px-4">
            <span className="flex-1">
              <span className="block text-[11px]">Anak di bawah 3 tahun</span>
              <span className="mt-[5px] block font-mono text-[11px] text-white/80">Gratis</span>
            </span>
            <Stepper label="balita" value={kids} onChange={setKids} min={0} max={10} />
          </li>
        </ul>

        <h2 className="mt-5 text-[11px] font-semibold">Parkir Kendaraan</h2>
        <div className="mt-2 grid grid-cols-4 gap-2" role="radiogroup" aria-label="Parkir">
          {PARKIR.map((p) => {
            const active = parking === p.id;
            return (
              <button key={p.id} type="button" role="radio" aria-checked={active} onClick={() => setParking(p.id)}
                      className={`h-12 rounded-2xl border text-[11px] transition ${active ? "border-white/30 bg-leaf/80 font-semibold" : "glass hover:bg-white/15"}`}>
                <span className="block">{p.label}</span>
                <span className="block font-mono text-[9px] text-white/75">{p.price ? rupiah(p.price) : "-"}</span>
              </button>
            );
          })}
        </div>

        <h2 className="mt-5 text-[11px] font-semibold">Data Pemesan</h2>
        <label className="mt-2 block text-[9px] text-white/65" htmlFor="tiket-nama">Nama</label>
        <input id="tiket-nama" value={name} onChange={(e) => setName(e.target.value)} placeholder="Nama sesuai identitas" autoComplete="name"
               aria-invalid={Boolean(errors.name)} className={inputClass} />
        {errors.name && <p className="mt-1 text-[9.5px] text-coral">{errors.name}</p>}
        <label className="mt-2.5 block text-[9px] text-white/65" htmlFor="tiket-wa">No. WhatsApp</label>
        <input id="tiket-wa" value={whatsapp} onChange={(e) => setWhatsapp(e.target.value)} placeholder="08xxxxxxxxxx" inputMode="tel" autoComplete="tel"
               aria-invalid={Boolean(errors.whatsapp)} className={inputClass} />
        {errors.whatsapp && <p className="mt-1 text-[9.5px] text-coral">{errors.whatsapp}</p>}
        <p className="mt-1 text-[9px] text-white/55">E-tiket juga dikirim ke nomor ini.</p>
      </form>

      <footer className="fixed inset-x-0 bottom-0 z-30 mx-auto w-full max-w-[430px]">
        <div className="glass flex h-16 items-center justify-between gap-4 rounded-t-[20px] border-b-0 px-5">
          <span>
            <span className="block text-[9.5px] text-white/70">Total ({adults + kids} orang)</span>
            <span className="block font-mono text-[13px]">{rupiah(total)}</span>
          </span>
          <button type="submit" form="tiket" className="h-10 w-[195px] rounded-full bg-leaf text-xs font-semibold transition hover:brightness-110">
            Bayar dengan QRIS
          </button>
        </div>
      </footer>
    </main>
  );
}
