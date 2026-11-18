// Aturan kekuatan password yang sama dengan backend (src/lib/validatePassword.ts).
// Dipakai form dan Server Action supaya pengguna mendapat pesan cepat, tanpa
// menghilangkan pemeriksaan ulang di backend.
export const PASSWORD_MIN = 8;
export const PASSWORD_MAX = 72;

export const PASSWORD_HINT = "Minimal 8 karakter, mengandung huruf besar, huruf kecil, dan angka.";

// Mengembalikan pesan kesalahan, atau null bila password memenuhi syarat.
export function validatePassword(value: string): string | null {
  if (!value) return "Password wajib diisi.";
  if (value.length < PASSWORD_MIN) return `Password minimal ${PASSWORD_MIN} karakter.`;
  if (value.length > PASSWORD_MAX) return `Password maksimal ${PASSWORD_MAX} karakter.`;
  if (!/[a-z]/.test(value)) return "Password harus mengandung huruf kecil.";
  if (!/[A-Z]/.test(value)) return "Password harus mengandung huruf besar.";
  if (!/[0-9]/.test(value)) return "Password harus mengandung angka.";
  return null;
}
