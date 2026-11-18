"use client";

import { Trash2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";

import { IconButton, Modal, PrimaryButton, SecondaryButton } from "@/components/admin/ui";

import { hapusFotoGaleri } from "../actions";

// Tombol hapus foto dengan konfirmasi. Setelah berhasil, halaman dimuat ulang dari server.
export default function HapusFoto({ id, title, owner }: { id: string; title: string; owner: string }) {
  const [konfirmasi, setKonfirmasi] = useState(false);
  const [sibuk, setSibuk] = useState(false);
  const [pesan, setPesan] = useState<string | null>(null);
  const router = useRouter();

  const pesanGalat = (error: string) => {
    if (error === "NOT_FOUND") return "Foto sudah tidak ada.";
    if (error === "FORBIDDEN") return "Hanya admin yang boleh menghapus foto.";
    if (error === "UNAUTHORIZED") return "Sesi berakhir. Silakan login lagi.";
    return "Foto belum bisa dihapus. Coba lagi.";
  };

  const jalankan = async () => {
    if (sibuk) return;
    setSibuk(true);
    const hasil = await hapusFotoGaleri(id);
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
        <IconButton tone="gray" label={`Hapus foto ${title}`} onClick={() => setKonfirmasi(true)}>
          <Trash2 size={16} />
        </IconButton>
        {pesan && <p className="max-w-28 text-right text-xs text-coral">{pesan}</p>}
      </div>

      {konfirmasi && (
        <Modal title="Hapus Foto?" onClose={() => setKonfirmasi(false)}>
          <p className="text-sm text-abu">
            Hapus foto &ldquo;{title}&rdquo; dari {owner}? Berkas foto ikut dihapus dan tidak bisa dikembalikan.
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
