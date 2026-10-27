"use client";

import { Download } from "lucide-react";
import { useMemo, useState } from "react";

import { AdminHeader, PrimaryButton } from "@/components/admin/ui";
import { BOOKINGS } from "@/data/dummy";

import DaftarBooking from "./DaftarBooking";
import DetailBooking from "./DetailBooking";
import StatBooking from "./StatBooking";

// Admin 2/7: Booking Sewa & Wahana. Filter status, cari pemesan (kotak cari di header), detail, konfirmasi/tolak.
// File ini memegang data dan pilihan pengguna, lalu menyusun bagian-bagiannya (StatBooking, DaftarBooking, DetailBooking).
export default function BookingView() {
  // Data booking, filter aktif, kata pencarian, dan booking yang sedang dipilih.
  const [rows, setRows] = useState(BOOKINGS);
  const [filter, setFilter] = useState("Semua");
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState(1);

  // Booking yang tampil = cocok dengan filter status dan namanya mengandung kata pencarian.
  const visible = useMemo(() => rows.filter((r) =>
    (filter === "Semua" || r.status === filter) && r.name.toLowerCase().includes(query.trim().toLowerCase())), [rows, filter, query]);
  // Booking yang dipilih.
  const selected = rows.find((r) => r.id === selectedId) ?? null;

  // Mengganti status satu booking (dipakai tombol Konfirmasi, Tandai Selesai, dan Tolak).
  const setStatus = (id, status) => setRows((all) => all.map((r) => (r.id === id ? { ...r, status } : r)));

  return (
    <>
      <AdminHeader title="Booking Sewa & Wahana" subtitle="Kelola pesanan sewa alat dan wahana dari aplikasi"
                   action={<PrimaryButton icon={Download}>Export</PrimaryButton>}
                   search={{ value: query, onChange: setQuery, placeholder: "Cari nama pemesan..." }} />

      <StatBooking rows={rows} />

      {/* Kiri: daftar booking. Kanan: detail booking yang dipilih */}
      <div className="mt-5 grid gap-5 xl:grid-cols-[736fr_380fr]">
        <DaftarBooking visible={visible} selectedId={selectedId} onSelect={setSelectedId}
                       filter={filter} onFilter={setFilter} query={query} onQuery={setQuery} />
        <DetailBooking selected={selected} onStatus={setStatus} />
      </div>
    </>
  );
}
