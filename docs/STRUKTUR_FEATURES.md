# Struktur Baru `lib/features/` — Sumber Sira Mobile

Dibuat setelah refactor pada 18 November 2026. **Status: `flutter analyze` → No issues found.**
Kode yang diubah hanya pemindahan file, pemecahan `BookingController`, dan perbaikan import.
Logika bisnis tidak diubah.

## 1. Pola folder

Setiap fitur berada di `lib/features/<nama_fitur>/` dengan dua anak:

- `view/` → widget/halaman yang dilihat pengguna.
- `viewmodel/` → state holder (jika ada). Untuk fitur yang memakai state bersama
  `AppState`, folder ini berisi `README.md` penjelas, bukan kode palsu.

Folder bersama tetap di root `lib/`:

```text
lib/
├── main.dart                       Titik awal + daftar rute
├── data/                           api_client.dart, app_state.dart (dipakai banyak fitur)
├── models/                         Ticket, Booking, CrowdInfo, dll
├── theme/                          AppColors, AppText
├── utils/                          routes, format, waktu, validator, launcher, photo_upload
├── widgets/                        common, glass, app_background, logo_mark, photo_form
├── features/
│   ├── splash/view/                splash_screen.dart
│   ├── about/view/                 about_screen.dart
│   ├── onboarding/view/            onboarding_screen.dart
│   ├── shell/view/                 main_shell.dart (kerangka 4 tab)
│   ├── home/view/                  home_tab.dart
│   ├── tickets/view/               tickets_tab.dart, ticket_form_screen.dart, eticket_screen.dart
│   ├── booking/view/               booking_section.dart, checkout_screen.dart,
│   │                               payment_screen.dart, invoice_screen.dart
│   │   └── viewmodel/              booking_controller.dart
│   ├── gallery/view/               gallery_tab.dart
│   ├── profile/view/               profile_tab.dart
│   ├── reviews/view/               reviews_screen.dart
│   ├── ai_photo/view/              ai_photo_screen.dart
│   ├── chat/view/                  floating_chat.dart
│   │   └── viewmodel/              chat_controller.dart
│   └── crowd/view/                 crowd_widgets.dart
│       └── viewmodel/              crowd_state.dart
├── mahasiswa_mvvm/                 Contoh MVVM klasik (praktikum, tetap di tempat)
└── mahasiswa/                      Contoh Clean Architecture (praktikum, tetap di tempat)
```

## 2. Daftar pemindahan (lama → baru)

| Sebelumnya | Sekarang |
|---|---|
| `lib/screens/splash_screen.dart` | `lib/features/splash/view/splash_screen.dart` |
| `lib/screens/about_screen.dart` | `lib/features/about/view/about_screen.dart` |
| `lib/screens/onboarding_screen.dart` | `lib/features/onboarding/view/onboarding_screen.dart` |
| `lib/screens/main_shell.dart` | `lib/features/shell/view/main_shell.dart` |
| `lib/screens/home_tab.dart` | `lib/features/home/view/home_tab.dart` |
| `lib/screens/tickets_tab.dart` | `lib/features/tickets/view/tickets_tab.dart` |
| `lib/screens/ticket_form_screen.dart` | `lib/features/tickets/view/ticket_form_screen.dart` |
| `lib/screens/eticket_screen.dart` | `lib/features/tickets/view/eticket_screen.dart` |
| `lib/screens/checkout_screen.dart` | `lib/features/booking/view/checkout_screen.dart` |
| `lib/screens/payment_screen.dart` | `lib/features/booking/view/payment_screen.dart` |
| `lib/screens/invoice_screen.dart` | `lib/features/booking/view/invoice_screen.dart` |
| `lib/screens/gallery_tab.dart` | `lib/features/gallery/view/gallery_tab.dart` |
| `lib/screens/profile_tab.dart` | `lib/features/profile/view/profile_tab.dart` |
| `lib/screens/reviews_screen.dart` | `lib/features/reviews/view/reviews_screen.dart` |
| `lib/screens/ai_photo_screen.dart` | `lib/features/ai_photo/view/ai_photo_screen.dart` |
| `lib/widgets/floating_chat.dart` | `lib/features/chat/view/floating_chat.dart` |
| `lib/data/chat_controller.dart` | `lib/features/chat/viewmodel/chat_controller.dart` |
| `lib/widgets/crowd_widgets.dart` | `lib/features/crowd/view/crowd_widgets.dart` |
| `lib/data/crowd_state.dart` | `lib/features/crowd/viewmodel/crowd_state.dart` |
| `lib/widgets/booking_section.dart` | dipecah menjadi `lib/features/booking/view/booking_section.dart` + `lib/features/booking/viewmodel/booking_controller.dart` |

`lib/main.dart`, `test/backend_e2e_test.dart`, dan `test/widget_test.dart` juga diperbarui
import-nya. Folder `lib/screens/` sekarang sudah kosong dan dihapus.

## 3. Kenapa `booking_section.dart` dipecah?

File lama berisi dua tanggung jawab sekaligus:

- `BookingController` (state: daftar wahana, jam, jumlah item, `notifyListeners()`).
- `BookingSection` + `BookingBar` (widget tampilan).

Setelah dipecah, `BookingController` ada di `viewmodel/`, sedangkan widgetnya di `view/`.
Itu persis pola yang diminta: **view di atas, viewmodel di bawah**.

## 4. Perbaikan tambahan

File `lib/mahasiswa_mvvm/views/mahasiswa_page.dart` sudah terhapus sebelum refactor
dan membuat `flutter analyze` gagal. Saya kembalikan dari `HEAD` Git
(`git checkout HEAD -- mobile/lib/mahasiswa_mvvm/views/mahasiswa_page.dart`),
sehingga contoh MVVM klasik bisa dijalankan lagi:

```bash
flutter run -t lib/mahasiswa_mvvm/main_mvvm.dart -d chrome
```

## 5. Cara menjelaskan di depan kelas

1. Tunjukkan `lib/features/` di VS Code: tiap fitur punya `view/` dan `viewmodel/`.
2. Katakan: "Shared seperti `ApiClient`, model, tema, dan widget umum sengaja
   diletakkan di root `lib/` supaya tidak duplikat di tiap fitur."
3. Tunjukkan `features/booking/` sebagai contoh paling jelas: widget di `view/`,
   `BookingController` di `viewmodel/`.
4. Sebutkan `flutter analyze` → **No issues found** sebagai bukti refactor aman.

> Catatan untuk presentasi: `docs/MVVM_DEEP_DIVE.md` memakai nomor baris dari
> snapshot **sebelum** refactor. Untuk struktur terkini, pakai dokumen ini.
