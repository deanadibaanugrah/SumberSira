import type { AdminGalleryPhoto } from "@/models/admin";

// Label Indonesia untuk status foto backend, dipakai StatusPill di halaman Galeri & Konten.
export const LABEL_STATUS: Record<AdminGalleryPhoto["status"], string> = {
  pending: "Baru",
  approved: "Ditampilkan",
  rejected: "Ditolak",
};
