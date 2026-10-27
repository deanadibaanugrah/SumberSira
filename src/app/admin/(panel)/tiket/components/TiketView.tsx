"use client";

import { ScanLine } from "lucide-react";
import { useMemo, useRef, useState } from "react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import { checkIn, resetDemo, useTiket } from "@/lib/tiket-store";

import CheckinTerbaru from "./CheckinTerbaru";
import DaftarTiket from "./DaftarTiket";
import ScanTiket from "./ScanTiket";
import StatTiket from "./StatTiket";

// Admin 3/7: Tiket & Check-in. Petugas memindai kode tiket di pintu masuk;
// jumlah orang yang sudah masuk dan belum keluar menjadi angka Live Crowd di aplikasi pengunjung.
// File ini memegang data dan pilihan pengguna, lalu menyusun bagian-bagiannya (StatTiket, ScanTiket, CheckinTerbaru, DaftarTiket).
export default function TiketView() {
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

      <StatTiket tiket={tiket} />

      <div className="mt-5 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <ScanTiket tiket={tiket} kode={kode} onKode={setKode} onScan={scan} inputRef={input} hasil={hasil} />
        <CheckinTerbaru recent={tiket.recent} onReset={() => { resetDemo(); setHasil(null); }} />
      </div>

      <DaftarTiket tiket={tiket} visible={visible} filter={filter} onFilter={setFilter}
                   query={query} onQuery={setQuery} onHasil={setHasil} />
    </>
  );
}
