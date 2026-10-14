// Foto web admin disimpan di desain/foto (tidak lagi di public/images), lalu di-import di sini.
// Next.js memproses import gambar statis: ukuran terbaca otomatis dan file diberi nama unik saat build.
import heroSawah from "../../desain/foto/hero-sawah.webp";
import airJernih from "../../desain/foto/onboarding-air-jernih.webp";
import keretaSawah from "../../desain/foto/onboarding-kereta-sawah.webp";
import sawah from "../../desain/foto/sawah-sumber-sira.webp";
import splash from "../../desain/foto/splash-sumber-sira.webp";

// Kumpulan foto yang dipakai di web, dipanggil lewat FOTO.splash, FOTO.heroSawah, dan seterusnya.
export const FOTO = {
  heroSawah,
  airJernih,
  keretaSawah,
  sawah,
  splash,
};
