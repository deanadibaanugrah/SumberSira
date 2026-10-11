// Font desain: judul serif (Fraunces), teks (Inter), angka/harga (JetBrains Mono).
// Dipasang dari npm (Fontsource), bukan next/font/google: mode dev Turbopack gagal memuat font Google
// bila path proyek mengandung spasi (mis. "D:\Tugas\Sumber Sira").
import "@fontsource-variable/fraunces";
import "@fontsource-variable/inter";
import "@fontsource-variable/jetbrains-mono";
import "./globals.css";

// Judul dan deskripsi website yang muncul di tab browser dan hasil pencarian.
export const metadata = {
  title: "Sumber Sira · Kunjungan Jernih Tanpa Antre",
  description: "Aplikasi booking wahana, cek keramaian, dan foto AI bawah air untuk wisata mata air Sumber Sira, Desa Putukrejo, Malang.",
};

// Warna bar browser di HP (Hijau Tua).
export const viewport = {
  themeColor: "#1b4332",
};

// Kerangka paling luar untuk semua halaman: web intro, aplikasi, dan admin.
export default function RootLayout({ children }) {
  return (
    <html lang="id" className="h-full antialiased">
      <body className="min-h-full">{children}</body>
    </html>
  );
}
