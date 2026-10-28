import "server-only";

import { createHash, randomBytes } from "node:crypto";
import { cookies, headers } from "next/headers";

import { SESSION_COOKIE } from "./constants";

// Sesi berbasis server (cocok untuk panel admin karena bisa dicabut seketika):
// - Server menyimpan catatan sesi; browser hanya memegang ID acak di cookie.
//   Klien API (mis. Postman) memegang ID acak yang sama sebagai token di header "Authorization: Bearer".
// - Yang disimpan di server adalah hash dari ID itu, jadi kalau datanya bocor ID aslinya tetap tidak diketahui.
// - Cookie: HttpOnly (tidak bisa dibaca JavaScript, mencegah pencurian lewat XSS), Secure (hanya lewat HTTPS,
//   localhost tetap boleh), SameSite=Lax (tidak ikut terkirim di sebagian besar request lintas situs, mencegah CSRF).
// Tahap UTS tanpa database: sesi disimpan di memori server (hilang saat server dimatikan).
// Tahap backend: pindahkan Map ini ke tabel sessions di database atau Redis.

const SHORT_SESSION_MS = 8 * 60 * 60 * 1000; // 8 jam bila "Ingat saya" mati
const LONG_SESSION_MS = 7 * 24 * 60 * 60 * 1000; // 7 hari bila "Ingat saya" aktif

export type SessionRecord = {
  publicId: string; // ID pendek untuk ditampilkan dan dicabut dari halaman Akun (bukan isi cookie)
  userId: string;
  createdAt: number;
  expiresAt: number;
  device: string;
};

// Disimpan di globalThis supaya tidak terhapus saat file dimuat ulang ketika development.
const globalStore = globalThis as unknown as { __sumberSiraSessions?: Map<string, SessionRecord> };
const store = (globalStore.__sumberSiraSessions ??= new Map<string, SessionRecord>());

const hashToken = (token: string) => createHash("sha256").update(token).digest("hex");

// Ringkasan perangkat dari User-Agent, mis. "Chrome · Windows", untuk daftar sesi. Login lewat Postman tercatat "Postman".
function describeDevice(userAgent: string): string {
  if (/PostmanRuntime\//.test(userAgent)) return "Postman · API";
  const browser = /Edg\//.test(userAgent) ? "Edge" : /Chrome\//.test(userAgent) ? "Chrome" : /Firefox\//.test(userAgent) ? "Firefox" : /Safari\//.test(userAgent) ? "Safari" : "Browser";
  const os = /Windows/.test(userAgent) ? "Windows" : /Android/.test(userAgent) ? "Android" : /iPhone|iPad/.test(userAgent) ? "iOS" : /Mac OS/.test(userAgent) ? "macOS" : /Linux/.test(userAgent) ? "Linux" : "Perangkat lain";
  return `${browser} · ${os}`;
}

// Membuat sesi baru dan mengembalikan token-nya. ID selalu baru setiap login (mencegah session fixation).
// Login lewat form menyimpan token di cookie (createSession); login lewat API mengirim token di body
// supaya klien seperti Postman bisa memakainya di header "Authorization: Bearer <token>".
export async function issueSession(userId: string, remember: boolean): Promise<{ token: string; expiresAt: number }> {
  const token = randomBytes(32).toString("base64url");
  const now = Date.now();
  const expiresAt = now + (remember ? LONG_SESSION_MS : SHORT_SESSION_MS);
  const userAgent = (await headers()).get("user-agent") ?? "";
  store.set(hashToken(token), { publicId: randomBytes(6).toString("hex"), userId, createdAt: now, expiresAt, device: describeDevice(userAgent) });
  return { token, expiresAt };
}

// Login lewat form: sesi baru disimpan di cookie HttpOnly.
export async function createSession(userId: string, remember: boolean): Promise<void> {
  const { token, expiresAt } = await issueSession(userId, remember);
  (await cookies()).set(SESSION_COOKIE, token, {
    httpOnly: true,
    secure: true,
    sameSite: "lax",
    path: "/",
    // Tanpa "Ingat saya" cookie hilang saat browser ditutup; dengan "Ingat saya" bertahan 7 hari.
    ...(remember ? { expires: new Date(expiresAt) } : {}),
  });
}

// Token sesi dari header "Authorization: Bearer" (klien API seperti Postman) atau dari cookie (browser).
async function currentToken(): Promise<string | undefined> {
  const auth = (await headers()).get("authorization");
  if (auth?.startsWith("Bearer ")) return auth.slice(7).trim() || undefined;
  return (await cookies()).get(SESSION_COOKIE)?.value;
}

// Membaca sesi dari token. Mengembalikan null bila tidak ada, tidak dikenal, atau sudah kedaluwarsa.
export async function readSession(): Promise<SessionRecord | null> {
  const token = await currentToken();
  if (!token) return null;
  const key = hashToken(token);
  const record = store.get(key);
  if (!record) return null;
  if (record.expiresAt <= Date.now()) {
    store.delete(key);
    return null;
  }
  return record;
}

// Logout: hapus catatan sesi di server lalu hapus cookie di browser. Token yang sama langsung ditolak setelahnya.
export async function deleteCurrentSession(): Promise<void> {
  const token = await currentToken();
  if (token) store.delete(hashToken(token));
  (await cookies()).delete(SESSION_COOKIE);
}

// Daftar sesi aktif milik satu akun saja (query dibatasi ke pemiliknya).
export function listSessionsOf(userId: string): SessionRecord[] {
  const now = Date.now();
  return [...store.values()].filter((s) => s.userId === userId && s.expiresAt > now).sort((a, b) => b.createdAt - a.createdAt);
}

// Mencabut satu sesi. Sesi hanya dicabut bila memang milik akun ini; sesi orang lain dianggap tidak ada (cegah IDOR).
export function revokeSessionOf(userId: string, publicId: string): boolean {
  for (const [key, s] of store) {
    if (s.userId === userId && s.publicId === publicId) {
      store.delete(key);
      return true;
    }
  }
  return false;
}

// Mencabut semua sesi milik akun ini kecuali sesi yang sedang dipakai.
export function revokeOtherSessionsOf(userId: string, keepPublicId: string): number {
  let count = 0;
  for (const [key, s] of store) {
    if (s.userId === userId && s.publicId !== keepPublicId) {
      store.delete(key);
      count++;
    }
  }
  return count;
}
