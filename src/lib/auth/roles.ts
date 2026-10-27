// Otorisasi berbasis peran (RBAC): setiap peran punya daftar izin.
// File ini boleh dipakai server maupun browser karena tidak berisi rahasia.
// Browser memakainya hanya untuk menyembunyikan menu (pengaturan tampilan);
// keputusan akses yang sebenarnya tetap dicek ulang di server (lihat dal.ts).

export type Role = "admin" | "petugas";

// Nama izin. "wahana:lihat" dan "wahana:ubah" dipisah supaya petugas bisa melihat harga tapi tidak bisa mengubahnya.
export type Permission =
  | "dashboard"
  | "booking"
  | "tiket"
  | "insight"
  | "galeri"
  | "faq"
  | "wahana:lihat"
  | "wahana:ubah"
  | "akun";

// Label peran yang tampil di kartu profil sidebar.
export const ROLE_LABEL: Record<Role, string> = {
  admin: "Pengelola · BUMDes",
  petugas: "Petugas Loket",
};

// Izin tiap peran. Admin boleh semua; petugas loket hanya mengurus tiket, booking, dan melihat harga.
const PERMISSIONS: Record<Role, Permission[]> = {
  admin: ["dashboard", "booking", "tiket", "insight", "galeri", "faq", "wahana:lihat", "wahana:ubah", "akun"],
  petugas: ["dashboard", "booking", "tiket", "wahana:lihat", "akun"],
};

// Mengecek apakah peran tertentu punya izin tertentu.
export function can(role: Role, permission: Permission): boolean {
  return PERMISSIONS[role]?.includes(permission) ?? false;
}
