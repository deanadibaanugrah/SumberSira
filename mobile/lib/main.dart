import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/app_state.dart';
import 'features/chat/viewmodel/chat_controller.dart';
import 'models/booking.dart';
import 'features/about/view/about_screen.dart';
import 'features/ai_photo/view/ai_photo_screen.dart';
import 'features/booking/view/checkout_screen.dart';
import 'features/tickets/view/eticket_screen.dart';
import 'features/booking/view/invoice_screen.dart';
import 'features/shell/view/main_shell.dart';
import 'features/onboarding/view/onboarding_screen.dart';
import 'features/booking/view/payment_screen.dart';
import 'features/reviews/view/reviews_screen.dart';
import 'features/splash/view/splash_screen.dart';
import 'features/tickets/view/ticket_form_screen.dart';
import 'theme/app_theme.dart';
import 'utils/routes.dart';

// Import praktikum Clean Architecture & MVVM (Modul Pertemuan 10)
import 'mahasiswa/data/repositories/mahasiswa_repository_memory.dart';
import 'mahasiswa/domain/usecases/ambil_mahasiswa.dart';
import 'mahasiswa/domain/usecases/hapus_mahasiswa.dart';
import 'mahasiswa/domain/usecases/tambah_mahasiswa.dart';
import 'mahasiswa/presentation/viewmodels/mahasiswa_viewmodel.dart';
import 'mahasiswa/presentation/views/mahasiswa_page.dart';
import 'mahasiswa_mvvm/views/mahasiswa_page.dart' as mvvm;

// Titik awal aplikasi pengunjung Sumber Sira.
// [P6] main() dibuat async: menyiapkan format tanggal Indonesia (intl) dan membaca pengaturan
// serta riwayat yang tersimpan di perangkat (shared_preferences) sebelum aplikasi tampil.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Setiap langkah persiapan dibungkus try/catch: kegagalan kecil (format tanggal atau
  // penyimpanan lokal) tidak boleh membuat aplikasi berhenti sebelum runApp sehingga layar putih.
  try {
    await initializeDateFormatting('id_ID');
  } catch (e) {
    debugPrint('initializeDateFormatting gagal: $e');
  }
  try {
    await AppState.instance.loadSettings();
  } catch (e) {
    debugPrint('loadSettings gagal: $e');
  }
  runApp(const SumberSiraApp());
  // Data awal dimuat setelah UI tampil. Bila server belum terjangkau, daftar tetap kosong
  // dan layar menampilkan status belum terhubung (tidak ada data bawaan).
  unawaited(AppState.instance.refreshPricing());
  unawaited(ChatController.instance.init());
}

// Akar aplikasi: tema, daftar rute (navigasi antar layar), dan layar pertama (Splash).
class SumberSiraApp extends StatelessWidget {
  const SumberSiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sumber Sira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // [P5 Named Route] initialRoute = layar pertama, routes = daftar nama rute dan halamannya.
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.main: (_) => const MainShell(),
        AppRoutes.buyTicket: (_) => const TicketFormScreen(),
        AppRoutes.aiPhoto: (_) => const AiPhotoScreen(),
        AppRoutes.reviews: (_) => const ReviewsScreen(),
      },
      // Rute yang membawa data lewat arguments: kode tiket, isi booking, pesanan yang dibayar, atau kode booking.
      // Kode juga bisa dikirim lewat tautan, mis. /tiket/detail?kode=TK-1019.
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        final args = settings.arguments ?? uri.queryParameters['kode'];
        return switch (uri.path) {
          AppRoutes.eticket when args is String => MaterialPageRoute(
            settings: settings,
            builder: (_) => ETicketScreen(code: args),
          ),
          AppRoutes.checkout when args is BookingDraft => MaterialPageRoute(
            settings: settings,
            builder: (_) => CheckoutScreen(draft: args),
          ),
          AppRoutes.payment when args is Booking => MaterialPageRoute(
            settings: settings,
            builder: (_) => PaymentScreen(booking: args),
          ),
          AppRoutes.invoice when args is String => MaterialPageRoute(
            settings: settings,
            builder: (_) => InvoiceScreen(code: args),
          ),
          AppRoutes.praktikumClean => MaterialPageRoute(
            settings: settings,
            builder: (_) {
              final repo = MahasiswaRepositoryMemory();
              final vm = MahasiswaViewModel(
                ambilMahasiswa: AmbilMahasiswa(repo),
                tambahMahasiswa: TambahMahasiswa(repo),
                hapusMahasiswa: HapusMahasiswa(repo),
              );
              return MahasiswaPage(vm: vm);
            },
          ),
          AppRoutes.praktikumMvvm => MaterialPageRoute(
            settings: settings,
            builder: (_) => const mvvm.MahasiswaPage(),
          ),
          _ => null,
        };
      },
      // Rute tidak dikenal atau datanya tidak ada: kembali ke Beranda.
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }
}
