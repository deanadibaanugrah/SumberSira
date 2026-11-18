"use client";

import { Trash2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";

import { IconButton, Modal, PrimaryButton, SecondaryButton } from "@/components/admin/ui";

import { hapusUlasan } from "../actions";

// Tombol hapus ulasan dengan konfirmasi. Setelah berhasil, halaman dimuat ulang dari server.
export default function HapusUlasan({ id, name }: { id: string; name: string }) {
  const [konfirmasi, setKonfirmasi] = useState(false);
  const [sibuk, setSibuk] = useState(false);
  const [pesan, setPesan] = useState<string | null>(null);
  const router = useRouter();

  // Terjemahkan kode galat backend menjadi pesan Indonesia.
  const pesanGalat = (error: string) => {
    if (error === "NOT_FOUND") return "Ulasan sudah tidak ada.";
    if (error === "FORBIDDEN") return "Hanya admin yang boleh menghapus ulasan.";
    if (error === "UNAUTHORIZED") return "Sesi berakhir. Silakan login lagi.";
    return "Ulasan belum bisa dihapus. Coba lagi.";
  };

  const jalankan = async () => {
    if (sibuk) return;
    setSibuk(true);
    const hasil = await hapusUlasan(id);
    setSibuk(false);
    setKonfirmasi(false);
    if ("error" in hasil) {
      setPesan(pesanGalat(hasil.error));
    } else {
      setPesan(null);
      router.refresh();
    }
  };

  return (
    <>
      <div className="flex flex-col items-end gap-1">
        <IconButton tone="coral" label={`Hapus ulasan ${name}`} onClick={() => setKonfirmasi(true)}>
          <Trash2 size={16} />
        </IconButton>
        {pesan && <p className="max-w-32 text-right text-xs text-coral">{pesan}</p>}
      </div>

      {konfirmasi && (
        <Modal title="Hapus Ulasan?" onClose={() => setKonfirmasi(false)}>
          <p className="text-sm text-abu">
            Hapus ulasan dari {name}? Ulasan yang dihapus tidak bisa dikembalikan dan langsung hilang dari aplikasi.
          </p>
          <div className="mt-5 flex justify-end gap-2">
            <SecondaryButton disabled={sibuk} onClick={() => setKonfirmasi(false)}>Batal</SecondaryButton>
            <PrimaryButton icon={Trash2} disabled={sibuk} onClick={jalankan}>
              {sibuk ? "Menghapus..." : "Ya, Hapus"}
            </PrimaryButton>
          </div>
        </Modal>
      )}
    </>
  );
}
