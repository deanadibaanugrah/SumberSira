"use client";

import { DoorOpen, LogIn, LogOut, RotateCcw, ScanLine, Ticket, Users } from "lucide-react";
import { useMemo, useRef, useState } from "react";

import ProgressBar from "@/components/charts/ProgressBar";
import { AdminHeader, Avatar, Card, CardTitle, FilterPills, PrimaryButton, StatCard, StatusPill } from "@/components/admin/ui";
import { rupiah } from "@/lib/format";
import { KAPASITAS, PARKIR, checkIn, checkOut, jumlahOrang, resetDemo, useTiket } from "@/lib/tiket-store";

// Admin 3/7: Tiket & Check-in. Petugas memindai kode tiket di pintu masuk;
// jumlah orang yang sudah masuk dan belum keluar menjadi angka Live Crowd di aplikasi pengunjung.
// Pilihan filter status tiket.
const FILTERS = ["Semua", "Belum masuk", "Di dalam", "Keluar"];
// Nama parkir untuk tabel (Tidak ditulis sebagai tanda -).
const PARKIR_LABEL = Object.fromEntries(PARKIR.map((p) => [p.id, p.id === "none" ? "-" : p.label]));
// Warna batang kapasitas sesuai status keramaian.
const BAR = { Sepi: "bg-leaf", Sedang: "bg-forest", Ramai: "bg-coral" };

// Halaman admin Tiket & Check-in: petugas scan kode tiket di pintu, angka di sini menjadi Live Crowd aplikasi.
export default function TiketAdminPage() {
  // Data tiket dan ringkasan live (orang di dalam, persen, terjual, belum datang).
  const tiket = useTiket();
  // Filter tabel, kata pencarian, kode yang diketik petugas, dan hasil scan terakhir.
  const [filter, setFilter] = useState("Semua");
  const [query, setQuery] = useState("");
  const [kode, setKode] = useState("");
  const [hasil, setHasil] = useState(null); // { ok, message }
  const input = useRef(null);

  // Tiket yang tampil di tabel: cocok dengan filter dan pencarian (nama atau kode), urut dari yang terbaru dibeli.
  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();
    return [...tiket.tickets]
      .filter((t) => (filter === "Semua" || t.status === filter) && (!q || t.name.toLowerCase().includes(q) || t.code.toLowerCase().includes(q)))
      .sort((a, b) => b.boughtAt.localeCompare(a.boughtAt));
  }, [tiket.tickets, filter, query]);

  // Form scan: check-in kode yang diketik, tampilkan hasilnya, kosongkan kolom, lalu fokus lagi untuk scan berikutnya.
  const scan = (e) => {
    e.preventDefault();
    if (!kode.trim()) return;
    setHasil(checkIn(kode));
    setKode("");
    input.current?.focus();
  };
  // Tombol Scan Tiket di atas: arahkan kursor ke kolom kode tiket.
  const fokusScan = () => {
    input.current?.focus();
    input.current?.scrollIntoView({ block: "center", behavior: "smooth" });
  };

  return (
    <>
      <AdminHeader title="Tiket & Check-in" subtitle="Tiket masuk online yang discan di pintu menjadi data Live Crowd"
                   action={<PrimaryButton icon={ScanLine} onClick={fokusScan}>Scan Tiket</PrimaryButton>}
                   search={{ value: query, onChange: setQuery, placeholder: "Cari nama atau kode tiket..." }} />

      {/* Kartu ringkasan: terjual, orang di dalam, kapasitas, belum datang */}
      <div className="mt-6 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard icon={Ticket} solid value={tiket.sold} label="Tiket terjual hari ini" />
        <StatCard icon={Users} value={tiket.inside} label="Orang di dalam" />
        <StatCard icon={DoorOpen} value={`${tiket.percent}%`} label={`Kapasitas terisi · ${tiket.label}`} />
        <StatCard icon={LogIn} value={tiket.waiting} label="Belum datang (orang)" />
      </div>

      <div className="mt-5 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <Card>
          <CardTitle sub="Ketik atau scan kode di e-tiket pengunjung, mis. TK-1043"
                     right={<span className="flex h-8 items-center gap-2 rounded-full bg-leaf/12 px-3 text-[13px] font-semibold text-forest">
                       <span className="relative flex size-2"><span className="absolute inline-flex size-full animate-ping rounded-full bg-leaf opacity-60" /><span className="relative size-2 rounded-full bg-leaf" /></span>
                       Live
                     </span>}>
            Scan Tiket di Pintu Masuk
          </CardTitle>
          {/* Form scan kode tiket */}
          <form onSubmit={scan} className="mt-5 flex flex-wrap gap-3">
            <label className="flex h-12 min-w-[240px] flex-1 items-center gap-3 rounded-full bg-paper px-5 focus-within:ring-2 focus-within:ring-leaf/30">
              <ScanLine size={18} className="shrink-0 text-forest" aria-hidden="true" />
              <span className="sr-only">Kode tiket</span>
              <input ref={input} value={kode} onChange={(e) => setKode(e.target.value)} placeholder="TK-1043" autoComplete="off"
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
                <p className="text-[13px] text-ink/60">Pengunjung di dalam sekarang</p>
                <p className="mt-1 text-[32px] font-semibold leading-none">{tiket.inside}<span className="ml-1.5 text-base font-normal text-ink/60">/ {KAPASITAS} orang</span></p>
              </div>
              <span className={`rounded-full px-3 py-1.5 text-xs font-semibold text-white ${BAR[tiket.label]}`}>{tiket.label} · {tiket.percent}%</span>
            </div>
            <div className="mt-4">
              <ProgressBar value={tiket.percent} fillClass={BAR[tiket.label]} trackClass="bg-ink/[0.07]" height="h-3" />
            </div>
            <p className="mt-3 text-xs text-ink/60">
              Angka ini tampil di Live Crowd aplikasi pengunjung{tiket.updatedAt ? `, terakhir berubah pukul ${tiket.updatedAt}` : ""}.
            </p>
          </div>
        </Card>

        {/* Daftar check-in terbaru */}
        <Card className="flex flex-col">
          <CardTitle sub="Diurutkan dari yang paling baru">Check-in Terbaru</CardTitle>
          <ul className="mt-4 space-y-2.5">
            {tiket.recent.slice(0, 6).map((t) => (
              <li key={t.code} className="flex items-center gap-3 rounded-2xl bg-paper px-3 py-2.5 animate-fade-up">
                <Avatar name={t.name} size={34} />
                <span className="min-w-0 flex-1">
                  <span className="block truncate text-sm font-semibold">{t.name}</span>
                  <span className="block font-mono text-xs text-ink/60">{t.code} · {jumlahOrang(t)} orang</span>
                </span>
                <span className="text-right">
                  <span className="block font-mono text-sm">{t.status === "Keluar" ? t.checkOutAt : t.checkInAt}</span>
                  <span className={`block text-[11px] ${t.status === "Keluar" ? "text-ink/50" : "text-leaf"}`}>{t.status === "Keluar" ? "keluar" : "masuk"}</span>
                </span>
              </li>
            ))}
          </ul>
          {/* Tombol untuk mengembalikan data contoh */}
          <button type="button" onClick={() => { resetDemo(); setHasil(null); }}
                  className="mt-auto flex items-center gap-2 self-start pt-5 text-[13px] text-ink/60 hover:text-forest max-xl:mt-4">
            <RotateCcw size={14} /> Kembalikan data contoh hari ini
          </button>
        </Card>
      </div>

      {/* Tabel semua tiket hari ini */}
      <Card className="mt-5 px-4! pt-5!">
        <div className="px-2">
          <CardTitle>Daftar Tiket Hari Ini</CardTitle>
          <div className="mt-4"><FilterPills options={FILTERS} value={filter} onChange={setFilter} label="Filter status tiket" /></div>
          <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Cari nama atau kode tiket..." aria-label="Cari tiket"
                 className="mt-3 h-10 w-full rounded-full bg-paper px-4 text-sm outline-none focus:ring-2 focus:ring-leaf/30 md:hidden" />
        </div>
        <div className="mt-4 overflow-x-auto">
          <table className="w-full min-w-[820px] border-separate border-spacing-y-2 text-left text-sm">
            <thead className="text-[13px] text-ink/60">
              <tr>
                <th className="pl-4 font-normal">Kode</th>
                <th className="font-normal">Pemesan</th>
                <th className="font-normal">Orang</th>
                <th className="font-normal">Parkir</th>
                <th className="font-normal">Dibeli</th>
                <th className="font-normal">Masuk</th>
                <th className="font-normal">Status</th>
                <th className="pr-4 text-right font-normal">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {visible.map((t) => (
                <tr key={t.code} className={`[&>td:first-child]:rounded-l-2xl [&>td:last-child]:rounded-r-2xl ${t.mine ? "bg-leaf/[0.08]" : "bg-paper"}`}>
                  <td className="h-12 pl-4 font-mono font-medium">{t.code}</td>
                  <td>
                    <span className="font-semibold">{t.name}</span>
                    {t.mine && <span className="ml-2 rounded-full bg-white px-2 py-0.5 text-[11px] text-forest">dari aplikasi</span>}
                  </td>
                  <td>{jumlahOrang(t)}{t.kids > 0 && <span className="text-ink/50"> ({t.kids} balita)</span>}</td>
                  <td>{PARKIR_LABEL[t.parking]}</td>
                  <td className="font-mono">{t.boughtAt}</td>
                  <td className="font-mono">{t.checkInAt ?? "-"}</td>
                  <td><StatusPill status={t.status} /></td>
                  <td className="pr-3 text-right">
                    {/* Tiket belum masuk: tombol Check-in */}
                    {t.status === "Belum masuk" && (
                      <button type="button" onClick={() => setHasil(checkIn(t.code))}
                              className="inline-flex h-8 items-center gap-1.5 rounded-full bg-forest px-3 text-xs font-semibold text-white hover:brightness-125">
                        <LogIn size={14} /> Check-in
                      </button>
                    )}
                    {/* Pengunjung di dalam: tombol Keluar */}
                    {t.status === "Di dalam" && (
                      <button type="button" onClick={() => setHasil(checkOut(t.code))}
                              className="inline-flex h-8 items-center gap-1.5 rounded-full bg-white px-3 text-xs font-semibold text-ink hover:bg-ink/10">
                        <LogOut size={14} /> Keluar
                      </button>
                    )}
                    {t.status === "Keluar" && <span className="text-xs text-ink/50">{t.checkOutAt}</span>}
                  </td>
                </tr>
              ))}
              {visible.length === 0 && (
                <tr><td colSpan={8} className="rounded-2xl bg-paper px-5 py-10 text-center text-ink/60">Tidak ada tiket yang cocok.</td></tr>
              )}
            </tbody>
          </table>
        </div>
        <p className="px-2 pb-2 pt-3 text-xs text-ink/60">
          Total {tiket.sold} tiket · nilai penjualan {rupiah(tiket.tickets.reduce((sum, t) => sum + t.total, 0))}
        </p>
      </Card>
    </>
  );
}
