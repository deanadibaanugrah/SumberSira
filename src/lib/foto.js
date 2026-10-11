// Foto aplikasi disimpan di desain/foto (tidak lagi di public/images), lalu di-import di sini.
// Next.js memproses import gambar statis: ukuran terbaca otomatis dan file diberi nama unik saat build.
import heroSawah from "../../desain/foto/hero-sawah.webp";
import komunitas1 from "../../desain/foto/komunitas-1.webp";
import komunitas2 from "../../desain/foto/komunitas-2.webp";
import komunitas3 from "../../desain/foto/komunitas-3.webp";
import airJernih from "../../desain/foto/onboarding-air-jernih.webp";
import bawahAir from "../../desain/foto/onboarding-bawah-air.webp";
import keretaSawah from "../../desain/foto/onboarding-kereta-sawah.webp";
import sawah from "../../desain/foto/sawah-sumber-sira.webp";
import splash from "../../desain/foto/splash-sumber-sira.webp";

// Kumpulan foto yang dipakai di aplikasi, dipanggil lewat FOTO.splash, FOTO.heroSawah, dan seterusnya.
export const FOTO = {
  heroSawah,
  komunitas: [komunitas1, komunitas2, komunitas3],
  airJernih,
  bawahAir,
  keretaSawah,
  sawah,
  splash,
};
