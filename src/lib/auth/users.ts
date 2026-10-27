import "server-only";

import { scrypt, timingSafeEqual } from "node:crypto";
import { promisify } from "node:util";

import type { Role } from "./roles";

// Akun admin (tahap tanpa database). Password TIDAK disimpan sebagai teks, hanya hash scrypt
// (fungsi satu arah sekelas bcrypt/argon2) dengan salt acak: "scrypt$salt$hash".
// Tahap backend: pindahkan ke tabel users di database.
// "server-only" membuat build gagal kalau file ini sampai diimpor komponen browser.

export type AdminUser = {
  id: string;
  name: string;
  email: string;
  role: Role;
  passwordHash: string;
};

const USERS: AdminUser[] = [
  {
    id: "u-admin",
    name: "Pak Yono",
    email: "admin@sumbersira.id",
    role: "admin",
    passwordHash: "scrypt$pSvbWeBbhm7YvRpm5rnhZQ$JApHwtPjo9vSNu3YM118xkQCfHDEjFvDj3QpyK0bbajKBdqkM7ZqPZ4gHlvqRIRI7Zb8vVZyIpE3opESxH9h_g",
  },
  {
    id: "u-petugas",
    name: "Mbak Sari",
    email: "petugas@sumbersira.id",
    role: "petugas",
    passwordHash: "scrypt$xMxk7coC1LurI3cOQQ1L0A$ruRRiiY1hORVhHu28IAWPeHw8LbqmD8aBJ01JzjvQPcnJTsskGA2PYeQ7RQsGwsYbUZvlsjsroB05lIBTciFAg",
  },
];

const scryptAsync = promisify(scrypt) as (password: string, salt: Buffer, keylen: number, options: object) => Promise<Buffer>;
const SCRYPT_OPTIONS = { N: 16384, r: 8, p: 1 };
// Hash palsu untuk email yang tidak terdaftar, supaya lama prosesnya sama (tidak bisa menebak email mana yang ada).
const DUMMY_HASH = "scrypt$AAAAAAAAAAAAAAAAAAAAAA$" + "A".repeat(86);

// Membandingkan password dengan hash tersimpan memakai perbandingan waktu-tetap (timingSafeEqual).
async function passwordMatches(password: string, stored: string): Promise<boolean> {
  const [, saltText, hashText] = stored.split("$");
  const expected = Buffer.from(hashText, "base64url");
  const actual = await scryptAsync(password, Buffer.from(saltText, "base64url"), expected.length, SCRYPT_OPTIONS);
  return actual.length === expected.length && timingSafeEqual(actual, expected);
}

// Autentikasi: cari akun dari email lalu cocokkan password. Mengembalikan akun bila benar, null bila salah.
export async function verifyCredentials(email: string, password: string): Promise<AdminUser | null> {
  const user = USERS.find((u) => u.email === email.trim().toLowerCase());
  const ok = await passwordMatches(password, user?.passwordHash ?? DUMMY_HASH);
  return user && ok ? user : null;
}

export function findUserById(id: string): AdminUser | null {
  return USERS.find((u) => u.id === id) ?? null;
}
