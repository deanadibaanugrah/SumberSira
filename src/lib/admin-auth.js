"use client";

import { useSyncExternalStore } from "react";

// Login admin tahap frontend: akun demo dicek di browser, sesi disimpan di localStorage
// ("Ingat saya", 7 hari) atau sessionStorage (sampai browser ditutup, maks 8 jam).
// Ini hanya simulasi tampilan, BUKAN pengamanan sungguhan.
// Tahap backend: cek email & password di server, simpan sesi di cookie httpOnly,
// lalu lindungi /admin di server. Jangan menyimpan password di kode frontend.
export const AKUN_DEMO = {
  email: "admin@sumbersira.id",
  password: "sumbersira",
  name: "Pak Yono",
  role: "Pengelola · BUMDes",
};

const KEY = "sumber-sira:admin-session";
const LOADING = "loading";
const listeners = new Set();
let cache; // undefined = belum dibaca, null = belum login

// Membaca sesi login dari penyimpanan browser. Sesi yang sudah kedaluwarsa dianggap belum login.
function read() {
  if (cache !== undefined) return cache;
  let session = null;
  try {
    const raw = window.localStorage.getItem(KEY) ?? window.sessionStorage.getItem(KEY);
    const parsed = raw ? JSON.parse(raw) : null;
    if (parsed && parsed.expiresAt > Date.now()) session = parsed;
  } catch {
    // penyimpanan diblokir: anggap belum login
  }
  cache = session;
  return cache;
}

// Memberi tahu semua komponen bahwa status login berubah, supaya tampilannya ikut diperbarui.
function emit() {
  listeners.forEach((l) => l());
}

// Mendaftarkan komponen yang ingin tahu perubahan login, termasuk login atau logout dari tab lain.
function subscribe(listener) {
  listeners.add(listener);
  const onStorage = (e) => {
    if (e.key !== KEY) return;
    cache = undefined; // login/logout di tab lain
    listener();
  };
  window.addEventListener("storage", onStorage);
  return () => {
    listeners.delete(listener);
    window.removeEventListener("storage", onStorage);
  };
}

// "loading" saat render di server, null bila belum login, objek sesi bila sudah login.
export function useAdminSession() {
  return useSyncExternalStore(subscribe, read, () => LOADING);
}

// Mengecek email dan password dengan akun demo. Kalau cocok, sesi disimpan (7 hari bila Ingat saya aktif, 8 jam bila tidak).
export function login(email, password, remember) {
  const ok = email.trim().toLowerCase() === AKUN_DEMO.email && password === AKUN_DEMO.password;
  if (!ok) return false;
  const session = {
    name: AKUN_DEMO.name,
    role: AKUN_DEMO.role,
    email: AKUN_DEMO.email,
    expiresAt: Date.now() + (remember ? 7 * 24 : 8) * 60 * 60 * 1000,
  };
  try {
    window.localStorage.removeItem(KEY);
    window.sessionStorage.removeItem(KEY);
    (remember ? window.localStorage : window.sessionStorage).setItem(KEY, JSON.stringify(session));
  } catch {
    // tetap login selama halaman terbuka
  }
  cache = session;
  emit();
  return true;
}

// Keluar: hapus sesi dari penyimpanan browser lalu kabari semua komponen.
export function logout() {
  try {
    window.localStorage.removeItem(KEY);
    window.sessionStorage.removeItem(KEY);
  } catch {
    // abaikan
  }
  cache = null;
  emit();
}
