/** @type {import('next').NextConfig} */
const nextConfig = {
  // Sembunyikan tombol bulat "N" di pojok kiri bawah saat `npm run dev` supaya tidak menutupi
  // navigasi bawah aplikasi mobile. Pesan error build tetap muncul.
  devIndicators: false,
  experimental: {
    // Mengaktifkan forbidden() (halaman 403) yang dipakai DAL saat peran admin tidak punya izin.
    authInterrupts: true,
  },
};

export default nextConfig;
