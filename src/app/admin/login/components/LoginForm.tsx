"use client";

import { ArrowLeft, ArrowRight, Eye, EyeOff, Loader2, Lock, Mail, ShieldCheck, Sparkles } from "lucide-react";
import Link from "next/link";
import { useActionState, useState } from "react";

import { loginAction } from "@/lib/auth/actions";
import { validateEmail } from "@/lib/validation/email";

// Form masuk panel admin. Format email dicek dulu di browser (validateEmail), lalu form dikirim ke Server Action
// loginAction: email dicek ulang dengan aturan yang sama, password dicek di server (hash scrypt),
// lalu sesi disimpan di cookie HttpOnly.
// Gaya kolom isian dan kotak ikon di dalamnya.
const field = "flex h-12 items-center gap-3 rounded-2xl border border-transparent bg-paper pl-1.5 pr-3 transition focus-within:border-leaf focus-within:bg-white focus-within:ring-4 focus-within:ring-leaf/15";
const iconBox = "grid size-9 shrink-0 place-items-center rounded-xl bg-white text-forest shadow-sm";

// Petunjuk akun demo untuk presentasi (hanya ditampilkan di layar). Pengecekan tetap di server memakai hash.
const DEMO_ACCOUNTS = [
  { label: "Admin", email: "admin@sumbersira.id", password: "sumbersira" },
  { label: "Petugas", email: "petugas@sumbersira.id", password: "petugas123" },
];

// next = halaman tujuan setelah login (sudah diamankan di server).
export default function LoginForm({ next }: { next: string }) {
  // [state dari server] error dan email terakhir dikembalikan loginAction; pending = sedang dicek server.
  const [state, formAction, pending] = useActionState(loginAction, undefined);
  // Isi form (email, password, ingat saya) dan tombol lihat password.
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(true);
  const [show, setShow] = useState(false);
  // Pesan salah format email dari pengecekan di browser, tampil di bawah kolom email.
  const [emailError, setEmailError] = useState<string | null>(null);
  const error = state?.error;

  // Tombol Isi: mengisi email dan password salah satu akun demo.
  const isiAkunDemo = (akun: (typeof DEMO_ACCOUNTS)[number]) => {
    setEmail(akun.email);
    setPassword(akun.password);
    setEmailError(null);
  };

  // Sebelum dikirim: email yang salah format tidak dikirim ke server, pesannya muncul di bawah kolom email.
  const cekSebelumKirim = (e: React.FormEvent<HTMLFormElement>) => {
    const pesan = validateEmail(email);
    setEmailError(pesan);
    if (pesan) e.preventDefault();
  };

  return (
    // action = Server Action loginAction; isian dikirim sebagai FormData ke server
    <form action={formAction} onSubmit={cekSebelumKirim} noValidate
          className="relative w-full max-w-[440px] overflow-hidden rounded-[32px] border border-white/60 bg-white/90 p-6 shadow-[0_30px_80px_rgba(8,28,21,0.45)] backdrop-blur-2xl animate-fade-up sm:p-10">
      <span className="pointer-events-none absolute -right-16 -top-16 size-48 rounded-full bg-leaf/15 blur-2xl" aria-hidden="true" />
      <div className="relative">
        {/* Data tersembunyi: halaman tujuan setelah login dan pilihan Ingat saya */}
        <input type="hidden" name="next" value={next} />
        {remember && <input type="hidden" name="remember" value="on" />}
        <span className="inline-flex items-center gap-2 rounded-full bg-leaf/12 px-3 py-1.5 text-xs font-semibold text-forest">
          <ShieldCheck size={14} /> Khusus pengelola
        </span>
        <h2 className="mt-4 font-display text-[28px] font-semibold leading-tight sm:text-[32px]">Selamat datang kembali</h2>
        <p className="mt-1.5 text-sm text-ink/60">Masuk untuk mengelola wisata Sumber Sira.</p>

        {/* Kolom email */}
        <label className="mt-7 block text-[13px] font-semibold text-ink/80" htmlFor="email">Email</label>
        <div className={`mt-1.5 ${field} ${emailError ? "border-coral!" : ""}`}>
          <span className={iconBox}><Mail size={16} aria-hidden="true" /></span>
          <input id="email" name="email" type="email" value={email} autoComplete="username" placeholder="nama@sumbersira.id"
                 onChange={(e) => { setEmail(e.target.value); if (emailError) setEmailError(null); }}
                 onBlur={() => email && setEmailError(validateEmail(email))}
                 aria-invalid={emailError ? true : undefined} aria-describedby={emailError ? "email-error" : undefined}
                 className="w-full bg-transparent text-sm outline-none placeholder:text-ink/40" />
        </div>
        {emailError && <p id="email-error" role="alert" className="mt-1.5 text-[13px] text-coral">{emailError}</p>}

        {/* Kolom password dengan tombol mata untuk melihat atau menyembunyikan */}
        <label className="mt-4 block text-[13px] font-semibold text-ink/80" htmlFor="password">Password</label>
        <div className={`mt-1.5 ${field}`}>
          <span className={iconBox}><Lock size={16} aria-hidden="true" /></span>
          <input id="password" name="password" type={show ? "text" : "password"} value={password} onChange={(e) => setPassword(e.target.value)}
                 autoComplete="current-password" placeholder="Masukkan password" className="w-full bg-transparent text-sm outline-none placeholder:text-ink/40" />
          <button type="button" onClick={() => setShow((v) => !v)} aria-label={show ? "Sembunyikan password" : "Tampilkan password"}
                  className="grid size-8 shrink-0 place-items-center rounded-full text-ink/60 hover:bg-ink/5">
            {show ? <EyeOff size={17} /> : <Eye size={17} />}
          </button>
        </div>

        {/* Saklar Ingat saya: aktif = cookie 7 hari, mati = cookie hilang saat browser ditutup (sesi maks 8 jam) */}
        <button type="button" role="switch" aria-checked={remember} onClick={() => setRemember((v) => !v)}
                className="mt-4 flex items-center gap-3 text-sm text-ink/80">
          <span className={`relative h-6 w-11 rounded-full transition ${remember ? "bg-forest" : "bg-ink/15"}`}>
            <span className={`absolute top-1 size-4 rounded-full bg-white shadow transition-all ${remember ? "left-6" : "left-1"}`} />
          </span>
          Ingat saya di perangkat ini
        </button>

        {error && <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-2.5 text-sm text-coral animate-fade-up">{error}</p>}

        {/* Tombol masuk, berubah jadi Memeriksa... selama server mengecek */}
        <button type="submit" disabled={pending}
                className="group relative mt-6 flex h-[52px] w-full items-center justify-center gap-2.5 overflow-hidden rounded-full bg-gradient-to-r from-forest to-leaf text-[15px] font-semibold text-white shadow-lg shadow-forest/30 transition hover:shadow-xl hover:shadow-forest/40 disabled:opacity-80">
          <span className="pointer-events-none absolute inset-y-0 left-0 w-1/3 bg-white/25 opacity-0 group-hover:opacity-100"
                style={{ animation: "shimmer 1.4s ease-in-out infinite" }} aria-hidden="true" />
          {pending ? <Loader2 size={18} className="animate-spin" /> : null}
          {pending ? "Memeriksa..." : "Masuk ke Dasbor"}
          {!pending && <ArrowRight size={18} className="transition group-hover:translate-x-1" />}
        </button>

        {/* Kotak akun demo untuk presentasi: Admin (semua menu) dan Petugas (menu terbatas) */}
        <div className="mt-6 rounded-2xl border border-dashed border-leaf/40 bg-leaf/[0.06] p-3.5">
          <p className="flex items-center gap-2 text-[13px] font-semibold text-forest"><Sparkles size={15} /> Akun demo</p>
          {DEMO_ACCOUNTS.map((akun) => (
            <div key={akun.email} className="mt-2.5 flex items-center gap-3">
              <span className="w-16 shrink-0 text-[12px] font-semibold text-ink/80">{akun.label}</span>
              <p className="min-w-0 flex-1 break-all font-mono text-[11px] leading-snug text-ink/70">{akun.email}<br />{akun.password}</p>
              <button type="button" onClick={() => isiAkunDemo(akun)}
                      className="h-8 shrink-0 rounded-full bg-white px-3.5 text-[12px] font-semibold text-forest shadow-sm transition hover:bg-forest hover:text-white">
                Isi
              </button>
            </div>
          ))}
        </div>

        <Link href="/" className="mt-6 flex w-fit items-center gap-2 text-sm text-ink/60 hover:text-forest">
          <ArrowLeft size={16} /> Kembali ke halaman utama
        </Link>
      </div>
    </form>
  );
}
