# Sumber Sira — Aplikasi Mobile & Web Admin

Tugas kelompok (UTS, fokus frontend). Konversi desain Figma **HI-FI** Sumber Sira ke kode:
aplikasi pengunjung (tampilan mobile) dan panel admin (tampilan web), dibangun dengan
**Next.js 16 (App Router) + JavaScript + Tailwind CSS 4**.

Sumber Sira adalah wisata kolam mata air di Desa Putukrejo, Malang. Aplikasi ini untuk booking sewa alat
dan wahana, cek keramaian, foto AI bawah air, chatbot, dan ulasan. Panel admin dipakai pengelola.

## Menjalankan

Butuh Node.js 20 atau lebih baru.

```bash
npm install
npm run dev
```

Buka <http://localhost:3000>:

| Alamat | Isi |
|---|---|
| `/` | Halaman perkenalan web (introduction web) |
| `/app` | Aplikasi pengunjung, mulai dari splash. Paling pas dibuka di DevTools mode ponsel (375 × 812) |
| `/admin` | Panel admin. Desainnya untuk layar 1440 × 900 |

Perintah lain:

- `npm run build` untuk build produksi, `npm start` untuk menjalankan hasil build.
- `npm run lint` untuk ESLint.
- `npm run dev:turbo` untuk mode dev Turbopack. Lebih cepat, tetapi lihat catatan di bawah.

> **Kenapa `npm run dev` memakai webpack?** Kalau path folder proyek mengandung spasi
> (misalnya `D:\Tugas\Sumber Sira`), mode dev Turbopack kadang tidak memperbarui CSS Tailwind
> setelah file diubah. Kelas baru jadi tidak berpengaruh sampai server di-restart. Mode webpack
> tidak punya masalah ini. Kalau folder kamu tanpa spasi, `npm run dev:turbo` juga aman.

## Halaman

### Aplikasi pengunjung (13 layar, sesuai Figma)

| Rute | Layar Figma |
|---|---|
| `/app` | Splash (otomatis lanjut ke Tentang setelah 2,6 detik, atau ketuk) |
| `/app/tentang` | Tentang Sumber Sira (introduction app) |
| `/app/onboarding` | Onboarding 1–3: bisa digeser (swipe/drag) **dan** pakai tombol Kembali/Lanjut |
| `/app/home` | Home |
| `/app/booking` | Booking Sewa & Wahana |
| `/app/checkout` | Checkout (Ringkasan Booking) |
| `/app/konfirmasi` | Konfirmasi & E-Voucher (QR + kirim invoice ke WhatsApp) |
| `/app/crowd` | Live Crowd Tracker (AI) |
| `/app/ai-photo` | AI Underwater Photo Studio |
| `/app/chat` | Chatbot Tanya Sira |
| `/app/ulasan` | Ulasan & Rating |

### Panel admin (6 halaman, sesuai Figma)

| Rute | Halaman |
|---|---|
| `/admin` | Dashboard Overview (grafik batang beranimasi) |
| `/admin/booking` | Booking Management (filter, cari, detail, konfirmasi/tolak) |
| `/admin/insight` | AI Insight (grafik garis + batang sentimen beranimasi) |
| `/admin/galeri` | Galeri & Konten (moderasi foto) |
| `/admin/faq` | Chatbot / FAQ (tambah, edit, hapus, jawab pertanyaan) |
| `/admin/wahana` | Wahana & Harga (tambah, edit, hapus) |

## Syarat dosen dan letaknya

| Syarat | Implementasi |
|---|---|
| Gunakan Next.js | Next.js 16 App Router (`src/app`) |
| UTS fokus frontend web, minimal 3 slide (admin) | 6 halaman admin di `src/app/admin` |
| Animasi grafik di admin | `src/components/charts/`: batang tumbuh dari bawah (`BarChart`), garis digambar kiri ke kanan (`LineChart`), progres mengisi (`ProgressBar`) |
| Onboarding pakai tombol atau swipe | `src/app/app/onboarding/page.js`: keduanya ada, plus tombol titik dan panah keyboard |
| Introduction web dan app | Web: `src/app/page.js`. App: splash + `src/app/app/tentang/page.js` |
| Setelah bayar, invoice terkirim ke WhatsApp user | `src/lib/whatsapp.js` + halaman konfirmasi. Lihat bagian "Tahap backend" |

## Struktur folder

```
desain/                PNG ekspor dari Figma (acuan tampilan, 2× dari ukuran asli)
public/images/         Foto yang dipotong dari PNG desain
src/app/               Halaman (App Router)
  page.js              Intro web
  app/                 Aplikasi pengunjung (layout lebar maks 430 px)
  admin/               Panel admin (layout sidebar)
src/components/
  charts/              BarChart, LineChart, ProgressBar (beranimasi)
  mobile/              PageHeader, BottomNav
  admin/               Sidebar, ui.js (AdminHeader, Card, StatCard, StatusPill, Modal, ...)
  WahanaIcon.js        Ikon per wahana
src/data/              Data dummy (wahana.js, dummy.js). Tahap backend: ganti dengan data API
src/lib/
  booking-context.js   Keranjang booking (disimpan di sessionStorage)
  whatsapp.js          Pesan invoice WhatsApp
  format.js            Format Rupiah dan kode booking
```

## Catatan desain

- Ukuran mengikuti Figma: frame mobile **375 × 812** dan admin **1440 × 900**. PNG di `desain/`
  diekspor 2×, jadi 1 px di kode = 2 px di PNG. Ukuran teks, jarak, dan kartu diukur dari PNG.
  Teksnya memang kecil (9–13 px) karena begitu di desain. Kalau mau diperbesar demi keterbacaan,
  diskusikan dulu dengan kelompok supaya tetap konsisten.
- Warna dan font ada di `src/app/globals.css` (`@theme`): `forest`, `leaf`, `moss`, `mint`, `coral`, dan lainnya.
  Pakai lewat kelas Tailwind, misalnya `bg-forest` dan `text-leaf`.
- Font dipasang dari npm (Fontsource): Fraunces (judul), Inter (teks), JetBrains Mono (angka/harga).
- Foto di `public/images/` dipotong dari PNG desain. Badge yang ikut tercetak di foto galeri sudah
  ditambal; posisinya tertutup badge dari kode.
- Yang tidak ada di Figma dan sengaja ditambahkan: halaman intro web, tombol "Kirim Invoice ke WhatsApp",
  pesan validasi form, stepper jumlah di Booking, dan modal Tambah/Edit di admin.
- Ikon profil di navigasi bawah sementara menuju Ulasan & Rating, karena halaman Profil belum didesain.

## Masih simulasi dan perlu dikerjakan di tahap backend

| Fitur | Sekarang (frontend) | Tahap backend |
|---|---|---|
| Invoice WhatsApp | Tombol membuka `wa.me` dengan teks invoice terisi otomatis | Buat `POST /api/invoice` yang mengirim otomatis lewat WhatsApp Cloud API (Meta) atau gateway. Panggil setelah pembayaran sukses |
| Data (wahana, booking, keramaian, FAQ, ulasan, galeri) | Konstanta di `src/data/` | Ambil dari API/database |
| Booking & pembayaran | Kode booking dibuat di browser, pembayaran tidak diproses | Simpan booking di server. QRIS lewat payment gateway |
| AI Photo enhance | Filter CSS sebagai simulasi | Kirim foto ke layanan AI, tampilkan hasilnya |
| Chatbot Tanya Sira | Jawaban berdasar kata kunci | Hubungkan ke data FAQ admin dan/atau layanan AI |
| Live Crowd | Angka dummy | Data sensor/kamera atau perhitungan tiket masuk |
| Login admin | Belum ada | Autentikasi, dan batasi `/admin` hanya untuk pengelola |

**Keamanan untuk tahap backend:**

- Semua API key (WhatsApp, payment gateway, AI) disimpan di environment variable server, misalnya
  `.env.local`. **Jangan** taruh di kode frontend dan **jangan** commit ke git. `.env*` sudah ada di `.gitignore`.
- Pakai kredensial dengan hak akses seminimal mungkin.
- Jangan menulis API key atau data pribadi pengunjung (nomor WhatsApp, dll.) ke log.

## Kerja kelompok dengan Git

1. Clone repo, lalu `npm install`.
2. Buat branch per fitur: `git checkout -b fitur/nama-fitur`.
3. Commit kecil-kecil dengan pesan jelas, lalu `git push -u origin fitur/nama-fitur`.
4. Buka Pull Request ke `main` dan minta teman sekelompok me-review sebelum merge.
5. Sebelum push, jalankan `npm run lint` dan `npm run build` supaya tidak ada error.
