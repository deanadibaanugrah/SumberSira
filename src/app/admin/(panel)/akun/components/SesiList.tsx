"use client";

import { Laptop, LogOut } from "lucide-react";
import { useState, useTransition } from "react";

import { revokeOtherSessionsAction, revokeSessionAction } from "@/lib/auth/actions";

export type Sesi = { id: string; device: string; createdAt: number; expiresAt: number; current: boolean };

// Format waktu singkat, mis. "21 Okt, 09.15".
const waktu = (ms: number) => new Date(ms).toLocaleString("id-ID", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });

// Daftar sesi login milik akun ini dengan tombol cabut. Sesi dicabut lewat Server Action;
// server hanya menghapus sesi bila memang milik akun yang sedang login.
export default function SesiList({ sessions }: { sessions: Sesi[] }) {
  const [pending, startTransition] = useTransition();
  const [message, setMessage] = useState("");

  // Cabut satu sesi (perangkat lain langsung keluar pada request berikutnya).
  const revoke = (id: string) =>
    startTransition(async () => {
      const result = await revokeSessionAction(id);
      setMessage("error" in result ? `Gagal: ${result.error}` : "Sesi dicabut. Perangkat itu harus login lagi.");
    });

  // Cabut semua sesi lain, sesi ini tetap aktif.
  const revokeOthers = () =>
    startTransition(async () => {
      const result = await revokeOtherSessionsAction();
      setMessage("count" in result ? `${result.count} sesi lain dicabut.` : `Gagal: ${result.error}`);
    });

  return (
    <div className="mt-4">
      <ul className="space-y-2.5">
        {sessions.map((s) => (
          <li key={s.id} className="flex items-center gap-3 rounded-2xl bg-paper px-4 py-3">
            <span className="grid size-9 shrink-0 place-items-center rounded-full bg-white text-forest"><Laptop size={17} /></span>
            <span className="min-w-0 flex-1">
              <span className="block text-sm font-semibold text-ink">
                {s.device} {s.current && <span className="ml-1 rounded-full bg-leaf/15 px-2 py-0.5 text-[11px] text-forest">Sesi ini</span>}
              </span>
              <span className="block text-xs text-ink/60">Masuk {waktu(s.createdAt)} · berlaku sampai {waktu(s.expiresAt)}</span>
            </span>
            {!s.current && (
              <button type="button" disabled={pending} onClick={() => revoke(s.id)}
                      className="h-9 shrink-0 rounded-full px-3.5 text-[13px] font-semibold text-coral transition hover:bg-coral/12 disabled:opacity-50">
                Cabut
              </button>
            )}
          </li>
        ))}
      </ul>
      {sessions.length > 1 && (
        <button type="button" disabled={pending} onClick={revokeOthers}
                className="mt-4 flex h-11 items-center gap-2 rounded-full border border-coral/40 px-5 text-sm font-semibold text-coral transition hover:bg-coral/10 disabled:opacity-50">
          <LogOut size={16} /> Keluar dari semua perangkat lain
        </button>
      )}
      {message && <p role="status" className="mt-3 text-sm text-ink/70">{message}</p>}
    </div>
  );
}
