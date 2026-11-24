"use client";

import { Bot, Plus, X } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";

import { Card, CardTitle, PrimaryButton, inputClass } from "@/components/admin/ui";
import type { AdminAiStatus } from "@/models/admin";

import { simpanTombolCepat } from "../actions";

const MAKS = 6;

// Tombol jawaban cepat yang tampil di kotak chat aplikasi (mis. "Jam buka?", "Harga tiket?"). Admin bisa menambah,
// mengurangi, dan mengubahnya. Tombol yang teksnya cocok dengan kata kunci sebuah FAQ dijawab persis seperti tulisan FAQ itu.
// Di bawahnya ada status chatbot AI: aktif atau belum (butuh kunci AI_API_KEY di server).
export default function TombolCepat({ tombol, ai, ready }: { tombol: string[]; ai: AdminAiStatus | null; ready: boolean }) {
  const [daftar, setDaftar] = useState<string[]>(tombol);
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null);
  const router = useRouter();

  const berubah = JSON.stringify(daftar.map((t) => t.trim())) !== JSON.stringify(tombol);
  const ubah = (i: number, v: string) => setDaftar((d) => d.map((t, j) => (j === i ? v : t)));
  const buang = (i: number) => setDaftar((d) => d.filter((_, j) => j !== i));
  const tambah = () => setDaftar((d) => (d.length < MAKS ? [...d, ""] : d));

  const simpan = async () => {
    const bersih = daftar.map((t) => t.trim()).filter(Boolean);
    if (bersih.length === 0) {
      setNotice({ ok: false, text: "Minimal satu tombol." });
      return;
    }
    if (bersih.some((t) => t.length < 2 || t.length > 40)) {
      setNotice({ ok: false, text: "Setiap tombol 2 sampai 40 huruf." });
      return;
    }
    setSaving(true);
    setNotice(null);
    const hasil = await simpanTombolCepat(bersih);
    setSaving(false);
    if ("error" in hasil) {
      setNotice({ ok: false, text: hasil.error === "VALIDATION" ? "Isian belum sesuai: 1 sampai 6 tombol, masing-masing 2 sampai 40 huruf." : "Gagal menyimpan. Coba lagi." });
      return;
    }
    setDaftar(hasil.questions);
    setNotice({ ok: true, text: "Tombol tersimpan. Aplikasi memuat yang baru saat chat dibuka." });
    router.refresh();
  };

  return (
    <Card className="mt-5">
      <CardTitle sub="Tombol di kotak chat aplikasi. Teks tombol sebaiknya mengandung kata kunci FAQ supaya dijawab sesuai tulisan admin.">
        Tombol Jawaban Cepat
      </CardTitle>

      <ul className="mt-4 grid gap-2.5 sm:grid-cols-2">
        {daftar.map((t, i) => (
          <li key={i} className="flex items-center gap-2">
            <input
              className={inputClass}
              value={t}
              maxLength={40}
              placeholder="mis. Jam buka?"
              aria-label={`Tombol ${i + 1}`}
              disabled={!ready}
              onChange={(e) => ubah(i, e.target.value)}
            />
            <button
              type="button"
              onClick={() => buang(i)}
              disabled={!ready || daftar.length <= 1}
              aria-label={`Hapus tombol ${i + 1}`}
              className="grid size-9 shrink-0 place-items-center rounded-full bg-coral/10 text-coral transition hover:bg-coral/20 disabled:opacity-40"
            >
              <X size={16} aria-hidden="true" />
            </button>
          </li>
        ))}
      </ul>

      <div className="mt-4 flex flex-wrap items-center gap-3">
        <button
          type="button"
          onClick={tambah}
          disabled={!ready || daftar.length >= MAKS}
          className="inline-flex h-10 items-center gap-1.5 rounded-full bg-leaf/12 px-4 text-sm font-semibold text-forest transition hover:bg-leaf/20 disabled:opacity-40"
        >
          <Plus size={16} aria-hidden="true" /> Tambah tombol
        </button>
        <PrimaryButton onClick={simpan} disabled={!ready || saving || !berubah}>{saving ? "Menyimpan..." : "Simpan tombol"}</PrimaryButton>
        <span className="text-xs text-abu">{daftar.length} dari {MAKS} tombol</span>
        {notice && (
          <span role="status" className={`text-sm ${notice.ok ? "text-forest" : "text-coral"}`}>{notice.text}</span>
        )}
      </div>

      <div className="mt-5 flex items-start gap-3 rounded-2xl bg-paper px-4 py-3">
        <span className="grid size-9 shrink-0 place-items-center rounded-full bg-leaf/12 text-forest"><Bot size={17} aria-hidden="true" /></span>
        <div className="text-[13px] leading-snug text-abu">
          {ai === null ? (
            <span>Status chatbot AI belum bisa dibaca dari server.</span>
          ) : ai.enabled ? (
            <>
              <span className="block text-sm font-semibold text-ink">Chatbot AI aktif</span>
              Pertanyaan bebas dijawab AI hanya dari data resmi (harga, wahana, keramaian, dan FAQ di atas). Jatah hari ini: {ai.usedToday} dari {ai.dailyLimit} jawaban.
            </>
          ) : (
            <>
              <span className="block text-sm font-semibold text-ink">Chatbot AI belum aktif</span>
              Tanya Sira masih menjawab dari FAQ saja. Untuk mengaktifkan AI, isi <code className="rounded bg-ink/5 px-1">AI_API_KEY</code> di pengaturan server backend.
            </>
          )}
        </div>
      </div>
    </Card>
  );
}
