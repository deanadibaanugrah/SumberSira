# ViewModel

Fitur ini tidak punya ViewModel lokal. State yang dipakai berasal dari:
- `lib/data/app_state.dart` (AppState: tiket, booking, tarif, ulasan, pengaturan).
- `lib/features/crowd/viewmodel/crowd_state.dart` (jika menampilkan keramaian).
- `lib/features/chat/viewmodel/chat_controller.dart` (jika menampilkan chat).

Pola ini sengaja dipertahankan supaya tidak mengubah logika aplikasi.

