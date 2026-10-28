// Aturan email yang sama untuk form di browser dan pengecekan di server (Server Action dan API).
// Wajib satu tanda @, ada titik di bagian setelah @, dan hanya huruf, angka, titik (.), garis bawah (_), tanda hubung (-).
// Karakter seperti ( ) : & " ' atau spasi ditolak. Pesan error menjelaskan bagian mana yang salah.
export const EMAIL_MAX = 100;

const ALLOWED = /^[A-Za-z0-9._@-]+$/;
const LOCAL = "[A-Za-z0-9](?:[A-Za-z0-9._-]*[A-Za-z0-9])?";
const LABEL = "[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?";
const FORMAT = new RegExp(`^${LOCAL}@${LABEL}(?:\\.${LABEL})*\\.[A-Za-z]{2,}$`);

// Mengembalikan pesan error, atau null bila email benar.
export function validateEmail(value: string): string | null {
  const email = value.trim();
  if (!email) return "Email wajib diisi.";
  if (email.length > EMAIL_MAX) return `Email terlalu panjang (maksimal ${EMAIL_MAX} karakter).`;
  if (!email.includes("@")) return "Email harus memakai tanda @.";
  if (!ALLOWED.test(email)) return "Email hanya boleh berisi huruf, angka, titik (.), garis bawah (_), tanda hubung (-), dan @.";
  const [local, domain, ...rest] = email.split("@");
  if (rest.length) return "Email hanya boleh punya satu tanda @.";
  if (!local) return "Isi nama sebelum tanda @, contoh: nama@sumbersira.id.";
  if (!domain.includes(".")) return "Bagian setelah @ harus memakai titik, contoh: nama@sumbersira.id.";
  if (email.includes("..") || !FORMAT.test(email)) return "Format email belum benar, contoh: nama@sumbersira.id.";
  return null;
}
