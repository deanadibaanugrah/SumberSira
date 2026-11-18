# Uji manual ujung ke ujung

Dokumen ini dipakai manusia untuk memastikan frontend (Flutter + web admin) benar-benar tersambung ke backend
SumberSira. Kerjakan berurutan; tiap bagian punya hasil yang harus terlihat. Kalau ada yang gagal, catat layar,
langkah, dan isi tab Network/Console.

## 1. Persiapan

1. **Backend** (`SumberSira-backend`): arahkan `.env` ke database Neon **pengembangan** (bukan production), lalu:

   ```
   npm install
   npx prisma generate
   npx prisma migrate deploy
   npm run seed
   npm run dev
   ```

   Cek `http://localhost:4000/health` → `{"ok":true}`. Pastikan `PAYMENT_MODE=simulation` untuk uji sehari-hari.

2. **Web admin** (akar repo ini): pastikan `.env.local` berisi `API_URL=http://localhost:4000`, lalu `npm run dev`
   dan buka `http://localhost:3000/admin/login`.

3. **Flutter**: hentikan `npm run dev` web admin lebih dulu (mencegah folder `mobile\build` terkunci), lalu dari
   folder `mobile`:

   ```
   flutter run -d edge --dart-define=API_URL=http://localhost:4000
   ```

4. Siapkan dua akun dari seed: `admin@sumbersira.id` / `sumbersira` (admin) dan
   `petugas@sumbersira.id` / `petugas123` (petugas).

## 2. Tiket masuk (Flutter → admin)

1. Di aplikasi, buka **Tiket & Booking → Tiket Masuk**. Harga tiket dan tarif parkir harus sama dengan
   `GET /pricing` (ubah harga di admin lalu buka ulang form: harga ikut berubah).
2. Pilih 2 dewasa + 1 balita, parkir motor, jam datang, isi nama dan nomor WhatsApp, lalu **Beli** dengan QRIS.
3. Sheet pembayaran menampilkan QR. Di mode simulasi tombol **Saya Sudah Bayar** muncul; tekan tombol itu.
   Dalam ±3 detik status berubah lunas dan e-tiket terbuka. Total di e-tiket = hitungan server (bukan hitungan HP).
4. Ulangi dengan metode **Tunai di loket**. E-tiket harus bertuliskan "Menunggu pembayaran di loket".
5. Di web admin (`/admin/tiket`, login petugas), cari kode tiket tadi:
   - tiket tunai → **Konfirmasi Tunai** → status lunas, dan e-tiket di aplikasi berubah dalam ±5 detik;
   - tekan **Check-in** → e-tiket berubah "Di dalam";
   - tekan **Keluar** → e-tiket/riwayat berubah "Keluar".
6. Check-in tanpa lunas harus ditolak dengan pesan "belum lunas". Check-in dua kali harus ditolak
   (`INVALID_STATE`), bukan diam-diam berhasil.
7. Tutup dan buka lagi aplikasi, lalu cari nomor WhatsApp yang sama di tab **Riwayat**: tiket tadi tetap muncul
   (berasal dari server, bukan penyimpanan perangkat).
8. Matikan backend, lalu coba beli tiket: harus muncul pesan "Tidak dapat terhubung ke server." dan tombol coba lagi;
   aplikasi tidak boleh macet.

## 3. Booking sewa & wahana (Flutter → admin)

1. Buka **Tiket & Booking → Sewa & Wahana**. Jam yang tampil harus dari `GET /booking-slots`.
2. Pilih beberapa item (mis. 2 ban besar + 1 ATV), isi nama dan WhatsApp, lalu **Lanjut Booking**.
3. Di Ringkasan Booking, total pratinjau harus sama dengan total server. Tekan bayar: booking dibuat
   (`POST /bookings`), lalu layar QRIS muncul.
4. Bayar dengan **Saya Sudah Bayar**. Faktur terbuka dengan baris item, harga satuan, subtotal, total, dan kode booking
   dari server.
5. Di web admin `/admin/booking`, booking itu muncul. Detailnya harus sama dengan faktur.
6. Sebagai admin, ubah harga salah satu wahana di `/admin/wahana`, lalu ulangi booking baru dengan item yang sama:
   total mengikuti harga baru dari server.
7. Sebagai admin, nonaktifkan salah satu wahana, lalu dari aplikasi (layar Sewa & Wahana yang masih terbuka) coba
   booking wahana itu: harus muncul pesan "Ada wahana yang sudah tidak tersedia." dan daftar dimuat ulang.
8. Cek riwayat booking per nomor WhatsApp setelah aplikasi ditutup dan dibuka lagi.

## 4. Live Crowd (Flutter + web admin)

1. Buka Beranda aplikasi: angka persen, label (Sepi/Sedang/Ramai), dan grafik per jam berasal dari `GET /crowd`.
2. Check-in satu tiket lewat `/admin/tiket`, tunggu maksimal 30 detik: angka di Beranda, kartu keramaian di form tiket,
   dan e-tiket ikut naik. Check-out menurunkannya.
3. Dashboard admin dan widget Live Crowd di halaman login ikut berubah (widget login lewat `GET /api/crowd`, tanpa login).
4. Matikan backend: aplikasi tetap menampilkan angka terakhir beserta penanda "tidak terbaru", bukan 0 atau error layar.

## 5. Ulasan

1. Kirim ulasan dari aplikasi (pilih bintang + teks). Ulasan langsung muncul di daftar aplikasi.
2. Rata-rata bintang dan jumlah ulasan di Beranda berubah sesuai `GET /reviews` (bukan angka contoh 4,8/132).
3. Di web admin `/admin/ulasan` (login admin), ulasan itu muncul. Hapus satu ulasan, lalu muat ulang aplikasi:
   ulasan hilang dan rata-rata ikut berubah.
4. Login sebagai petugas: menu/halaman ulasan tidak boleh bisa dipakai untuk menghapus.

## 6. Galeri dan AI Photo

1. Di aplikasi, buka **Galeri → kirim foto**. Pilih JPEG/PNG/WebP di bawah 4 MB, isi judul dan nama, kirim.
   Muncul pemberitahuan bahwa foto menunggu persetujuan admin; foto **belum** tampil di galeri publik.
2. Coba kirim file lebih dari 4 MB dan file selain gambar: pesan harus jelas (`FILE_TOO_LARGE` / `UNSUPPORTED_MEDIA`),
   bukan teks mentah server.
3. Di web admin `/admin/galeri`, foto berstatus `pending`. Setujui: foto muncul di aplikasi. Tolak foto lain: tidak muncul.
   Hapus foto sebagai admin: hilang dari aplikasi.
4. Buka **AI Photo Studio**, pilih foto, unggah. Foto asli dan hasil perbaikan dari server tampil berdampingan.
   Tekan bagikan ke Galeri Komunitas, lalu setujui di admin, dan cek foto tampil di galeri aplikasi.

## 7. Chat dan FAQ

1. Buka chatbot Tanya Sira. Pertanyaan cepat berasal dari `GET /chat/quick-questions`.
2. Kirim pertanyaan yang sudah ada di FAQ: jawaban harus muncul dari `POST /chat` (bukan pencocokan lokal).
3. Kirim pertanyaan aneh yang belum ada jawabannya. Di `/admin/faq` pertanyaan itu muncul di daftar belum terjawab.
4. Sebagai admin, jawab pertanyaan itu (membuat FAQ baru lalu menghapus pertanyaan). Kirim pertanyaan serupa dari
   aplikasi: sekarang terjawab.
5. Edit dan hapus FAQ di admin; perubahan langsung terlihat pada pertanyaan berikutnya.

## 8. Insight, harga, akun petugas, ganti password

1. `/admin/insight` (admin) menampilkan rating, sebaran bintang, keramaian saat ini, jam terpadat, dan saran dari
   `GET /admin/insight`. Bagian yang tidak disediakan backend tidak ditampilkan.
2. `/admin/wahana`: petugas hanya melihat harga tiket/kapasitas/parkir; admin bisa mengubahnya (`PUT /admin/pricing`).
   Ubah harga tiket, lalu buka form tiket di aplikasi: harga baru tampil. Nilai di luar rentang harus ditolak dengan pesan.
3. `/admin/staff` (admin): tambah petugas baru, login dengan akun itu di jendela privat, lalu nonaktifkan akun tersebut.
   Sesi petugas itu harus langsung ditolak saat halaman berikutnya dibuka.
4. Coba nonaktifkan akun sendiri atau admin terakhir: harus muncul pesan `INVALID_STATE` yang jelas.
5. `/admin/akun`: ganti password sendiri (`POST /auth/change-password`), lalu logout dan login dengan password baru.
6. Sebagai petugas, buka `/admin/staff` dan `/admin/insight` lewat alamat langsung: harus halaman 403.

## 9. Hak akses dan galat umum

1. Tanpa login, buka `/admin/tiket`: diarahkan ke login, lalu kembali ke halaman yang dituju.
2. Petugas: sidebar tidak menampilkan menu khusus admin; aksi khusus admin di Server Action ditolak `FORBIDDEN`.
3. Matikan backend, lalu buka beberapa halaman admin: pesan "tidak bisa memuat" muncul, bukan layar putih.
4. Setiap pesan galat berbahasa Indonesia; tidak ada teks mentah backend, nomor WhatsApp, atau rahasia di log/console.

## 10. Pemeriksaan otomatis sebelum demo

Dari akar repo:

```
npx tsc --noEmit
npm run lint
npm run build
```

Dari folder `mobile`:

```
flutter analyze
flutter test
```

Opsional, dengan backend menyala di port 4100 (database pengembangan):

```
flutter test --dart-define=API_URL=http://localhost:4100 --dart-define=E2E=1 test/backend_e2e_test.dart
```
