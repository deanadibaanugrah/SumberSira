import { LogIn, ScanLine } from "lucide-react";
import type { FormEvent, RefObject } from "react";

import ProgressBar from "@/components/charts/ProgressBar";
import { Card, CardTitle, PrimaryButton } from "@/components/admin/ui";
import { KAPASITAS, type useTiket } from "@/lib/tiket-store";

// Warna batang kapasitas sesuai status keramaian.
const BAR = { Sepi: "bg-leaf", Sedang: "bg-leaf/30", Ramai: "bg-coral" };

type ScanTiketProps = {
  tiket: ReturnType<typeof useTiket>;
  kode: string;
  onKode: (value: string) => void;
  onScan: (e: FormEvent<HTMLFormElement>) => void;
  inputRef: RefObject<HTMLInputElement>;
  hasil: { ok: boolean; message: string } | null;
};

// Kartu scan tiket di pintu masuk: form kode tiket, pesan hasil scan, dan kapasitas terisi (angka Live Crowd).
export default function ScanTiket({ tiket, kode, onKode, onScan, inputRef, hasil }: ScanTiketProps) {
  return (
    <Card>
      <CardTitle sub="Ketik atau scan kode di e-tiket pengunjung, mis. TK-1043"
                 right={<span className="flex h-8 items-center gap-2 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest">
                   <span className="relative flex size-2"><span className="absolute inline-flex size-full animate-ping rounded-full bg-leaf opacity-60" /><span className="relative size-2 rounded-full bg-leaf" /></span>
                   Live
                 </span>}>
        Scan Tiket di Pintu Masuk
      </CardTitle>
      {/* Form scan kode tiket */}
      <form onSubmit={onScan} className="mt-5 flex flex-wrap gap-3">
        <label className="flex h-12 min-w-[240px] flex-1 items-center gap-3 rounded-full bg-paper px-5 focus-within:ring-2 focus-within:ring-leaf/30">
          <ScanLine size={18} className="shrink-0 text-forest" aria-hidden="true" />
          <span className="sr-only">Kode tiket</span>
          <input ref={inputRef} value={kode} onChange={(e) => onKode(e.target.value)} placeholder="TK-1043" autoComplete="off"
                 className="w-full bg-transparent font-mono text-[15px] uppercase tracking-wider outline-none placeholder:normal-case placeholder:tracking-normal placeholder:text-ink/40" />
        </label>
        <PrimaryButton type="submit" icon={LogIn}>Check-in</PrimaryButton>
      </form>
      {/* Pesan hasil scan: hijau kalau berhasil, merah kalau ditolak */}
      {hasil && (
        <p role="status" className={`mt-3 rounded-2xl px-4 py-3 text-sm animate-fade-up ${hasil.ok ? "bg-leaf/12 text-forest" : "bg-coral/12 text-coral"}`}>
          {hasil.message}
        </p>
      )}

      {/* Jumlah pengunjung di dalam dan batang kapasitas (inilah angka Live Crowd) */}
      <div className="mt-6 rounded-2xl bg-paper p-5">
        <div className="flex flex-wrap items-end justify-between gap-3">
          <div>
            <p className="text-[13px] text-abu">Pengunjung di dalam sekarang</p>
            <p className="mt-1 font-display text-[32px] font-semibold leading-none tabular-nums text-forest">{tiket.inside}<span className="ml-1.5 font-sans text-base font-normal text-abu">/ {KAPASITAS} orang</span></p>
          </div>
          <span className="inline-flex items-center gap-1.5 rounded-full border border-ink/10 bg-white px-3 py-1.5 text-xs font-semibold text-ink">
            <span className={`size-1.5 rounded-full ${BAR[tiket.label]}`} aria-hidden="true" />{tiket.label} · {tiket.percent}%
          </span>
        </div>
        <div className="mt-4">
          <ProgressBar value={tiket.percent} fillClass={BAR[tiket.label]} trackClass="bg-ink/10" height="h-3" />
        </div>
        <p className="mt-3 text-xs text-abu">
          Angka ini tampil di Live Crowd aplikasi pengunjung{tiket.updatedAt ? `, terakhir berubah pukul ${tiket.updatedAt}` : ""}.
        </p>
      </div>
    </Card>
  );
}
