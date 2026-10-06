/** @type {import('next').NextConfig} */
const nextConfig = {
  // Sembunyikan tombol bulat "N" di pojok kiri bawah saat `npm run dev` supaya tidak menutupi
  // navigasi bawah aplikasi mobile. Pesan error build tetap muncul.
  devIndicators: false,
};

export default nextConfig;
