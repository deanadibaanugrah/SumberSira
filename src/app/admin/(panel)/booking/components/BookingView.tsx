"use client";

import { useMemo, useState } from "react";

import { AdminHeader } from "@/components/admin/ui";
import { useBooking } from "@/viewmodels/booking-viewmodel";

import DaftarBooking from "./DaftarBooking";
import DetailBooking from "./DetailBooking";
import StatBooking from "./StatBooking";

// Admin 2/7: Booking Sewa & Wahana. Pembayaran QRIS dikonfirmasi otomatis backend, jadi bagian
// "validasi pembayaran" menjadi pemantauan status; aksi Tandai Lunas / Batalkan hanya untuk pengelola (canKelola).
// File ini memegang data dan pilihan pengguna, lalu menyusun bagian-bagiannya (StatBooking, DaftarBooking, DetailBooking).
export default function BookingView({ canKelola }: { canKelola: boolean }) {
  // Data booking (per halaman, 100 baris), filter aktif, kata pencarian, dan booking yang sedang dipilih.
  const [page, setPage] = useState(1);
  const { rows, total, ready, error } = useBooking(page);
  const [filter, setFilter] = useState("Semua");
  const [query, setQuery] = useState("");
  const [selectedCode, setSelectedCode] = useState<string | null>(null);

  const q = query.trim().toLowerCase();
  // Booking yang tampil = cocok dengan filter status ("Batal" mencakup Kedaluwarsa) dan nama/kode pemesan.
  const visible = useMemo(() => rows.filter((r) =>
    (filter === "Semua" || (filter === "Batal" ? r.status === "Batal" || r.status === "Kedaluwarsa" : r.status === filter)) &&
    (!q || r.name.toLowerCase().includes(q) || r.code.toLowerCase().includes(q))), [rows, filter, q]);
  // Booking yang dipilih (bawaan: baris pertama yang tampil).
  const selected = rows.find((r) => r.code === selectedCode) ?? visible[0] ?? rows[0] ?? null;

  return (
    <>
      <AdminHeader title="Booking Sewa & Wahana" subtitle="Kelola pesanan sewa alat dan wahana dari aplikasi"
                   search={{ value: query, onChange: setQuery, placeholder: "Cari nama pemesan..." }} />

      <StatBooking />

      {/* Kiri: daftar booking. Kanan: detail booking yang dipilih */}
      <div className="mt-5 grid grid-cols-1 gap-5 xl:grid-cols-[736fr_380fr]">
        <DaftarBooking visible={visible} selectedCode={selected?.code ?? null} onSelect={setSelectedCode}
                       filter={filter} onFilter={setFilter} query={query} onQuery={setQuery}
                       total={total} page={page} onPage={setPage} ready={ready} error={error} />
        <DetailBooking selected={selected} canKelola={canKelola} />
      </div>
    </>
  );
}
