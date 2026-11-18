# Deploy & Akses Tim

Panduan ini membuat perubahan yang di-push ke branch **main** otomatis terbit, sehingga anggota tim
bisa langsung memakai web admin, API, dan aplikasi pengunjung tanpa menjalankan server di laptop.

```
Flutter web / HP  ─┐
                   ├──► Backend (Render) ──► PostgreSQL Neon
Web admin (Vercel) ┘
```

| Bagian | Repo | Hosting | Auto-deploy |
|---|---|---|---|
| Web admin (Next.js) | `Sumber-Sira` | Vercel | Ya, setiap push ke `main` |
| Backend (Express) | `SumberSira-backend` | Render | Ya, setiap push ke `main` |
| Aplikasi pengunjung (Flutter web) | `Sumber-Sira/mobile` | GitHub Pages | Ya, lewat workflow `flutter-web.yml` |

Database tetap memakai Neon yang sudah ada. Tidak perlu membuat database baru.

---

## 1. Deploy backend ke Render

1. Push repo backend ke GitHub (branch `main`).
2. Buka [dashboard.render.com](https://dashboard.render.com) → **New** → **Blueprint**.
3. Pilih repo `SumberSira-backend`. Render membaca `render.yaml` dan membuat service `sumbersira-api`.
4. Isi variabel yang diminta:

   | Variabel | Nilai |
   |---|---|
   | `DATABASE_URL` | Connection string Neon (yang sekarang dipakai di `.env`) |
   | `ADMIN_ORIGIN` | URL web admin Vercel, mis. `https://sumber-sira.vercel.app` |
   | `PUBLIC_BASE_URL` | URL backend ini, mis. `https://sumbersira-api.onrender.com` |
   | `EXTRA_ORIGINS` | URL Flutter web (kalau dipakai), mis. `https://nama-tim.github.io` |

5. Klik **Apply**. Build menjalankan `npm ci --include=dev` + `npx prisma migrate deploy`, lalu `npm start`.
6. Setelah selesai, buka `https://<alamat-render>/health`. Harus muncul `{"ok":true}`.
   Cek juga `https://<alamat-render>/health/db`.

> Free tier Render tidur setelah tidak dipakai. Request pertama bisa lambat 30–60 detik.
> Untuk demo presentasi, buka `/health` dulu beberapa saat sebelum acara.

**Pembayaran demo:** `render.yaml` mengisi `NODE_ENV=production` dan `ALLOW_SIMULATE_PAY=true`,
jadi tombol "Saya Sudah Bayar" tetap berfungsi walau mode produksi. Untuk pembayaran sungguhan,
ganti `PAYMENT_MODE=midtrans`, isi kunci Midtrans, dan set `ALLOW_SIMULATE_PAY=false`.

**Upload foto:** dengan `STORAGE_DRIVER=local`, foto tersimpan di disk Render yang hilang saat deploy
ulang. Untuk produksi, buat Vercel Blob token lalu ubah `STORAGE_DRIVER=vercel-blob` dan isi
`BLOB_READ_WRITE_TOKEN`.

---

## 2. Deploy web admin ke Vercel

1. Buka [vercel.com/new](https://vercel.com/new), impor repo `Sumber-Sira`.
2. Framework terdeteksi **Next.js**. Root directory biarkan kosong (bukan `mobile`).
3. Tambahkan Environment Variable:

   | Nama | Nilai |
   |---|---|
   | `API_URL` | URL backend Render, mis. `https://sumbersira-api.onrender.com` |

4. Klik **Deploy**. Setiap push ke `main` akan otomatis membuat deployment baru.
5. Salin URL Vercel, lalu **kembali ke Render** dan ubah `ADMIN_ORIGIN` menjadi URL itu. Simpan
   (Render deploy ulang otomatis). Tanpa langkah ini login admin akan ditolak CORS.

Login memakai akun yang dibuat `npm run seed` di backend:
`admin@sumbersira.id` / `sumbersira` dan `petugas@sumbersira.id` / `petugas123`.

---

## 3. Deploy aplikasi pengunjung (Flutter web) ke GitHub Pages

1. Di repo `Sumber-Sira`: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
2. Di **Settings → Secrets and variables → Actions → Variables**, buat variable:

   | Nama | Nilai |
   |---|---|
   | `API_URL` | URL backend Render, mis. `https://sumbersira-api.onrender.com` |

3. Push ke `main`. Workflow `.github/workflows/flutter-web.yml` membangun `mobile/` dan menerbitkannya
   di `https://<pemilik>.github.io/Sumber-Sira/`.
4. Tambahkan alamat itu ke `EXTRA_ORIGINS` di Render (pisahkan dengan koma bila lebih dari satu).

Kalau GitHub Pages tidak tersedia (repo privat di akun gratis), aplikasi tetap bisa dipakai lewat
APK Android: jalankan `flutter build apk --dart-define=API_URL=https://<alamat-render>` lalu bagikan
file `mobile/build/app/outputs/flutter-apk/app-release.apk` ke tim.

---

## 4. Yang terjadi saat `git push origin main`

| Repo | Otomatis |
|---|---|
| `Sumber-Sira` | GitHub Actions menjalankan lint + build Next.js + analyze/test Flutter |
| `Sumber-Sira` | Vercel deploy web admin (integrasi Git) |
| `Sumber-Sira` | GitHub Pages deploy Flutter web (workflow) |
| `SumberSira-backend` | GitHub Actions mengecek TypeScript |
| `SumberSira-backend` | Render deploy API (integrasi Git / `render.yaml`) |

Pull Request tetap mendapat preview Vercel, jadi perubahan bisa dicoba sebelum masuk `main`.

Jika ingin deploy dipicu dari GitHub Actions (bukan integrasi Git), isi secret:
`VERCEL_DEPLOY_HOOK_URL` di repo frontend dan `RENDER_DEPLOY_HOOK_URL` di repo backend.
Hook dibuat di dashboard masing-masing platform.

---

## 5. Menjalankan di laptop tim (LAN)

Agar satu tim bisa memakai backend di satu laptop:

1. Backend: `npm run dev` (port 4000).
2. Web admin: `npm run dev` (port 3000).
3. Anggota tim membuka `http://<IP-LAPTOP>:3000`. Backend mengizinkan IP LAN saat `NODE_ENV=development`.
4. Flutter web dari HP: `flutter run -d edge --web-hostname 0.0.0.0 --web-port 8080
   --dart-define=API_URL=http://<IP-LAPTOP>:4000`, lalu buka `http://<IP-LAPTOP>:8080`.
5. HP fisik (APK): isi alamat server di **Profil → Server Backend**, atau build dengan
   `--dart-define=API_URL=http://<IP-LAPTOP>:4000`. HP dan laptop harus satu Wi-Fi.

Cek IP laptop dengan `ipconfig` (IPv4). Bila tetap gagal, matikan sementara firewall Windows untuk
port 4000/3000 atau izinkan Node.js di Windows Defender Firewall.

---

## 6. Kalau muncul "Server belum terjangkau"

1. Buka `http://localhost:4000/health` (lokal) atau `https://<alamat-render>/health` (produksi).
   Harus `{"ok":true}`.
2. Di aplikasi Flutter: **Profil → Server Backend → Tes Koneksi**. Alamat yang dipakai terlihat di situ.
3. Penyebab umum:
   - Android emulator memakai `http://10.0.2.2:4000`, HP fisik memakai IP laptop, web memakai `localhost`.
   - Backend belum dijalankan, atau berhenti karena error (lihat terminalnya).
   - `API_URL` di Vercel salah / belum diisi, atau `ADMIN_ORIGIN` belum diperbarui setelah URL Vercel berubah.
   - Flutter web produksi memakai `http` padahal halaman `https` (mixed content). Selalu pakai URL
     backend `https://` untuk Flutter web yang dideploy.
4. Setelah mengubah `.env`/Environment Variable, **redeploy** service-nya (Vercel/Render) karena nilai
   lama tidak terbaca ulang otomatis.

---

## 7. Checklist sebelum presentasi

- [ ] `https://<backend>/health` mengembalikan `{"ok":true}`.
- [ ] `https://<backend>/health/db` mengembalikan jumlah wahana.
- [ ] Login web admin berhasil sebagai admin dan petugas.
- [ ] Dashboard menampilkan data (bukan pesan "tidak bisa memuat").
- [ ] Chatbot menjawab "Jam buka?" dan pertanyaan acak tercatat di `/admin/faq`.
- [ ] Beli tiket di aplikasi → tiket muncul di `/admin/tiket` → check-in menaikkan Live Crowd.
- [ ] Push kecil ke `main` → Vercel dan Render sama-sama deploy tanpa error.
