"use client";

import { ArrowLeft, BarChart3, Eye, EyeOff, Loader2, Lock, LogIn, Mail, Sparkles, Ticket } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

import LogoMark from "@/components/Logo";
import { AKUN_DEMO, login, useAdminSession } from "@/lib/admin-auth";
import { FOTO } from "@/lib/foto";

// Halaman masuk panel admin (tahap frontend: akun demo, lihat src/lib/admin-auth.js).
const HIGHLIGHTS = [
  { icon: Ticket, text: "Live Crowd dari tiket online yang discan" },
  { icon: BarChart3, text: "Booking sewa & wahana dalam satu dasbor" },
  { icon: Sparkles, text: "Ringkasan ulasan dan prediksi oleh AI" },
];
const field = "flex h-12 items-center gap-3 rounded-xl border border-black/10 bg-white px-4 focus-within:border-leaf focus-within:ring-2 focus-within:ring-leaf/20";

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
    }, 600);
  };

  const isiAkunDemo = () => {
    setEmail(AKUN_DEMO.email);
    setPassword(AKUN_DEMO.password);
    setError("");
  };

  return (
    <main className="grid min-h-dvh gap-4 bg-paper p-4 text-ink lg:grid-cols-2">
      <section className="relative hidden overflow-hidden rounded-3xl bg-forest text-white lg:block">
        <Image src={FOTO.sawah} alt="" fill priority sizes="50vw" className="object-cover opacity-40" />
        <div className="absolute inset-0 bg-gradient-to-t from-forest via-forest/70 to-forest/30" />
        <div className="relative flex h-full flex-col justify-between p-10">
          <div className="flex items-center gap-3">
            <LogoMark size={44} ring label="" />
            <span>
              <span className="block font-display text-[22px] font-semibold leading-tight">Sumber Sira</span>
              <span className="block text-xs text-white/70">Admin Panel</span>
            </span>
          </div>
          <div className="max-w-[460px]">
            <p className="font-mono text-[11px] uppercase tracking-[0.18em] text-white/70">Panel pengelola wisata</p>
            <h1 className="mt-3 font-display text-[42px] font-semibold leading-[1.1]">Kelola Sumber Sira dalam satu dasbor</h1>
            <p className="mt-4 text-[15px] leading-relaxed text-white/80">
              Pantau keramaian dari tiket online, konfirmasi booking, dan moderasi konten pengunjung.
            </p>
            <ul className="mt-6 space-y-2.5">
              {HIGHLIGHTS.map(({ icon: Icon, text }) => (
                <li key={text} className="flex items-center gap-3 text-sm">
                  <span className="grid size-9 place-items-center rounded-full bg-white/12"><Icon size={16} aria-hidden="true" /></span>
                  {text}
                </li>
              ))}
            </ul>
          </div>
          <p className="text-xs text-white/60">Desa Putukrejo, Malang</p>
        </div>
      </section>

      <section className="grid place-items-center py-8">
        <form onSubmit={submit} noValidate className="w-full max-w-[420px] rounded-3xl bg-white p-8 shadow-[0_8px_30px_rgba(23,35,33,0.06)] animate-fade-up">
          <LogoMark size={48} label="Logo Sumber Sira" className="lg:hidden" />
          <h2 className="mt-4 font-display text-[30px] font-semibold leading-tight lg:mt-0">Masuk Admin</h2>
          <p className="mt-1.5 text-sm text-ink/60">Masuk untuk mengelola wisata Sumber Sira.</p>

          <label className="mt-7 block text-[13px] font-medium text-ink/80" htmlFor="email">Email</label>
          <div className={`mt-1.5 ${field}`}>
            <Mail size={17} className="shrink-0 text-ink/50" aria-hidden="true" />
            <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} autoComplete="username"
                   placeholder="nama@sumbersira.id" className="w-full bg-transparent text-sm outline-none placeholder:text-ink/40" />
          </div>

          <label className="mt-4 block text-[13px] font-medium text-ink/80" htmlFor="password">Password</label>
          <div className={`mt-1.5 ${field}`}>
            <Lock size={17} className="shrink-0 text-ink/50" aria-hidden="true" />
            <input id="password" type={show ? "text" : "password"} value={password} onChange={(e) => setPassword(e.target.value)}
                   autoComplete="current-password" placeholder="Masukkan password" className="w-full bg-transparent text-sm outline-none placeholder:text-ink/40" />
            <button type="button" onClick={() => setShow((v) => !v)} aria-label={show ? "Sembunyikan password" : "Tampilkan password"}
                    className="grid size-8 shrink-0 place-items-center rounded-full text-ink/60 hover:bg-paper">
              {show ? <EyeOff size={17} /> : <Eye size={17} />}
            </button>
          </div>

          <label className="mt-4 flex w-fit cursor-pointer items-center gap-2.5 text-sm text-ink/80">
            <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} className="size-4 accent-forest" />
            Ingat saya di perangkat ini
          </label>

          {error && <p role="alert" className="mt-4 rounded-xl bg-coral/12 px-4 py-2.5 text-sm text-coral">{error}</p>}

          <button type="submit" disabled={busy}
                  className="mt-6 flex h-12 w-full items-center justify-center gap-2.5 rounded-full bg-forest text-sm font-semibold text-white transition hover:brightness-125 disabled:opacity-70">
            {busy ? <Loader2 size={18} className="animate-spin" /> : <LogIn size={18} />}
            {busy ? "Memeriksa..." : "Masuk"}
          </button>

          <div className="mt-6 rounded-2xl bg-leaf/[0.08] p-4">
            <p className="text-[13px] font-semibold text-forest">Akun demo (tahap frontend)</p>
            <p className="mt-1.5 font-mono text-xs text-ink/75">{AKUN_DEMO.email}<br />{AKUN_DEMO.password}</p>
            <button type="button" onClick={isiAkunDemo} className="mt-3 h-9 rounded-full bg-white px-4 text-[13px] font-semibold text-forest transition hover:bg-leaf/15">
              Isi otomatis
            </button>
          </div>

          <Link href="/" className="mt-6 flex w-fit items-center gap-2 text-sm text-ink/60 hover:text-forest">
            <ArrowLeft size={16} /> Kembali ke halaman utama
          </Link>
        </form>
      </section>
    </main>
  );
}
