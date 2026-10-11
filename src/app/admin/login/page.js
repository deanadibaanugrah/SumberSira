"use client";

import { ArrowLeft, ArrowRight, Eye, EyeOff, Loader2, Lock, Mail, ShieldCheck, Sparkles } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

import LogoMark from "@/components/Logo";
import LoginBackdrop from "@/components/admin/LoginBackdrop";
import { CrowdChip, CrowdWidget, RatingWidget, TiketWidget } from "@/components/admin/LoginWidgets";
import { AKUN_DEMO, login, useAdminSession } from "@/lib/admin-auth";

// Halaman masuk panel admin (tahap frontend: akun demo, lihat src/lib/admin-auth.js).
// Latar bergerak dari foto asli Sumber Sira + widget kaca melayang dengan angka live dari data tiket.
const field = "flex h-12 items-center gap-3 rounded-2xl border border-transparent bg-paper pl-1.5 pr-3 transition focus-within:border-leaf focus-within:bg-white focus-within:ring-4 focus-within:ring-leaf/15";
const iconBox = "grid size-9 shrink-0 place-items-center rounded-xl bg-white text-forest shadow-sm";

// Hanya izinkan kembali ke halaman di dalam /admin (mencegah redirect ke situs lain).
function tujuanSetelahLogin() {
  const next = new URLSearchParams(window.location.search).get("next") || "/admin";
  return next.startsWith("/admin") && !next.startsWith("/admin/login") ? next : "/admin";
}

export default function AdminLoginPage() {
  const router = useRouter();
  const session = useAdminSession();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(true);
  const [show, setShow] = useState(false);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  // Sudah login: langsung masuk ke panel.
  useEffect(() => {
    if (session && session !== "loading") router.replace(tujuanSetelahLogin());
  }, [session, router]);

  const submit = (e) => {
    e.preventDefault();
    if (busy) return;
    if (!email.trim() || !password) {
      setError("Isi email dan password terlebih dahulu.");
      return;
    }
    setBusy(true);
    setError("");
    // Jeda kecil seperti menunggu respons server.
    setTimeout(() => {
      if (!login(email, password, remember)) {
        setError("Email atau password salah. Coba lagi.");
        setBusy(false);
      }
    }, 700);
  };

  const isiAkunDemo = () => {
    setEmail(AKUN_DEMO.email);
    setPassword(AKUN_DEMO.password);
    setError("");
  };

  return (
    <main className="relative min-h-dvh overflow-hidden text-ink">
      <LoginBackdrop />

      <div className="relative z-10 mx-auto grid min-h-dvh max-w-[1440px] grid-cols-[minmax(0,1fr)] items-center gap-10 px-4 py-8 sm:px-8 lg:grid-cols-[minmax(0,1.15fr)_minmax(0,1fr)] lg:px-14">
        {/* Kiri (layar lebar): cerita singkat + widget live */}
        <section className="hidden text-white lg:block">
          <div className="flex items-center gap-3 animate-fade-up">
            <LogoMark size={48} ring label="" />
            <span>
              <span className="block font-display text-2xl font-semibold leading-tight">Sumber Sira</span>
              <span className="block text-xs text-white/70">Admin Panel · Desa Putukrejo, Malang</span>
            </span>
          </div>
          <h1 className="mt-10 max-w-[520px] font-display text-[48px] font-semibold leading-[1.08] animate-fade-up" style={{ animationDelay: "100ms" }}>
            Kelola wisata mata air dalam satu dasbor
          </h1>
          <p className="mt-4 max-w-[480px] text-[15px] leading-relaxed text-white/80 animate-fade-up" style={{ animationDelay: "200ms" }}>
            Pantau keramaian dari tiket online, konfirmasi booking, dan rangkum ulasan pengunjung dengan AI.
          </p>
          <div className="mt-10 grid max-w-[560px] grid-cols-2 gap-4">
            <CrowdWidget className="row-span-2 self-center" />
            <TiketWidget />
            <RatingWidget />
          </div>
        </section>

        {/* Kanan: form masuk */}
        <section className="flex min-w-0 flex-col items-center">
          <div className="mb-5 flex w-full max-w-[440px] flex-wrap items-center justify-between gap-3 text-white lg:hidden">
            <span className="flex items-center gap-2.5">
              <LogoMark size={40} ring label="" />
              <span className="font-display text-xl font-semibold">Sumber Sira</span>
            </span>
            <CrowdChip />
          </div>

          <form onSubmit={submit} noValidate
                className="relative w-full max-w-[440px] overflow-hidden rounded-[32px] border border-white/60 bg-white/90 p-6 shadow-[0_30px_80px_rgba(8,28,21,0.45)] backdrop-blur-2xl animate-fade-up sm:p-10">
            <span className="pointer-events-none absolute -right-16 -top-16 size-48 rounded-full bg-leaf/15 blur-2xl" aria-hidden="true" />
            <div className="relative">
              <span className="inline-flex items-center gap-2 rounded-full bg-leaf/12 px-3 py-1.5 text-xs font-semibold text-forest">
                <ShieldCheck size={14} /> Khusus pengelola
              </span>
              <h2 className="mt-4 font-display text-[28px] font-semibold leading-tight sm:text-[32px]">Selamat datang kembali</h2>
              <p className="mt-1.5 text-sm text-ink/60">Masuk untuk mengelola wisata Sumber Sira.</p>

              <label className="mt-7 block text-[13px] font-semibold text-ink/80" htmlFor="email">Email</label>
              <div className={`mt-1.5 ${field}`}>
                <span className={iconBox}><Mail size={16} aria-hidden="true" /></span>
                <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} autoComplete="username"
                       placeholder="nama@sumbersira.id" className="w-full bg-transparent text-sm outline-none placeholder:text-ink/40" />
              </div>

              <label className="mt-4 block text-[13px] font-semibold text-ink/80" htmlFor="password">Password</label>
              <div className={`mt-1.5 ${field}`}>
                <span className={iconBox}><Lock size={16} aria-hidden="true" /></span>
                <input id="password" type={show ? "text" : "password"} value={password} onChange={(e) => setPassword(e.target.value)}
                       autoComplete="current-password" placeholder="Masukkan password" className="w-full bg-transparent text-sm outline-none placeholder:text-ink/40" />
                <button type="button" onClick={() => setShow((v) => !v)} aria-label={show ? "Sembunyikan password" : "Tampilkan password"}
                        className="grid size-8 shrink-0 place-items-center rounded-full text-ink/60 hover:bg-ink/5">
                  {show ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </div>

              <button type="button" role="switch" aria-checked={remember} onClick={() => setRemember((v) => !v)}
                      className="mt-4 flex items-center gap-3 text-sm text-ink/80">
                <span className={`relative h-6 w-11 rounded-full transition ${remember ? "bg-forest" : "bg-ink/15"}`}>
                  <span className={`absolute top-1 size-4 rounded-full bg-white shadow transition-all ${remember ? "left-6" : "left-1"}`} />
                </span>
                Ingat saya di perangkat ini
              </button>

              {error && <p role="alert" className="mt-4 rounded-2xl bg-coral/12 px-4 py-2.5 text-sm text-coral animate-fade-up">{error}</p>}

              <button type="submit" disabled={busy}
                      className="group relative mt-6 flex h-[52px] w-full items-center justify-center gap-2.5 overflow-hidden rounded-full bg-gradient-to-r from-forest to-leaf text-[15px] font-semibold text-white shadow-lg shadow-forest/30 transition hover:shadow-xl hover:shadow-forest/40 disabled:opacity-80">
                <span className="pointer-events-none absolute inset-y-0 left-0 w-1/3 bg-white/25 opacity-0 group-hover:opacity-100"
                      style={{ animation: "shimmer 1.4s ease-in-out infinite" }} aria-hidden="true" />
                {busy ? <Loader2 size={18} className="animate-spin" /> : null}
                {busy ? "Memeriksa..." : "Masuk ke Dasbor"}
                {!busy && <ArrowRight size={18} className="transition group-hover:translate-x-1" />}
              </button>

              <div className="mt-6 flex items-center gap-3 rounded-2xl border border-dashed border-leaf/40 bg-leaf/[0.06] p-3.5">
                <span className="grid size-10 shrink-0 place-items-center rounded-full bg-forest text-white"><Sparkles size={17} /></span>
                <div className="min-w-0 flex-1">
                  <p className="text-[13px] font-semibold text-forest">Akun demo</p>
                  <p className="break-all font-mono text-[11px] leading-snug text-ink/70">{AKUN_DEMO.email}<br />{AKUN_DEMO.password}</p>
                </div>
                <button type="button" onClick={isiAkunDemo}
                        className="h-9 shrink-0 rounded-full bg-white px-3.5 text-[13px] font-semibold text-forest shadow-sm transition hover:bg-forest hover:text-white">
                  Isi otomatis
                </button>
              </div>

              <Link href="/" className="mt-6 flex w-fit items-center gap-2 text-sm text-ink/60 hover:text-forest">
                <ArrowLeft size={16} /> Kembali ke halaman utama
              </Link>
            </div>
          </form>

          {/* Layar sedang (tablet/laptop kecil): widget live ditampilkan di bawah form. */}
          <div className="mt-6 hidden w-full max-w-[720px] grid-cols-3 gap-4 md:grid lg:hidden">
            <CrowdWidget />
            <TiketWidget />
            <RatingWidget />
          </div>
        </section>
      </div>
    </main>
  );
}
