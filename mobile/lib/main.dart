import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/app_state.dart';
import 'models/booking.dart';
import 'screens/about_screen.dart';
import 'screens/ai_photo_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/eticket_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/ticket_form_screen.dart';
import 'screens/voucher_screen.dart';
import 'theme/app_theme.dart';
import 'utils/routes.dart';

// Titik awal aplikasi pengunjung Sumber Sira.
// [P6] main() dibuat async: menyiapkan format tanggal Indonesia (intl) dan membaca pengaturan
// serta riwayat yang tersimpan di perangkat (shared_preferences) sebelum aplikasi tampil.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await AppState.instance.loadSettings();
  runApp(const SumberSiraApp());
}

// Akar aplikasi: tema, daftar rute (navigasi antar layar), dan layar pertama (Splash).
class SumberSiraApp extends StatelessWidget {
  const SumberSiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sumber Sira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      // [P5 Named Route] initialRoute = layar pertama, routes = daftar nama rute dan halamannya.
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.main: (_) => const MainShell(),
        AppRoutes.buyTicket: (_) => const TicketFormScreen(),
        AppRoutes.booking: (_) => const BookingScreen(),
        AppRoutes.aiPhoto: (_) => const AiPhotoScreen(),
        AppRoutes.chatbot: (_) => const ChatbotScreen(),
        AppRoutes.reviews: (_) => const ReviewsScreen(),
      },
      // Rute yang membawa data lewat arguments: kode tiket, isi booking, atau kode booking.
      // Kode juga bisa dikirim lewat tautan, mis. /tiket/detail?kode=TK-1019.
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        final args = settings.arguments ?? uri.queryParameters['kode'];
        return switch (uri.path) {
          AppRoutes.eticket when args is String => MaterialPageRoute(builder: (_) => ETicketScreen(code: args)),
          AppRoutes.checkout when args is BookingDraft => MaterialPageRoute(builder: (_) => CheckoutScreen(draft: args)),
          AppRoutes.voucher when args is String => MaterialPageRoute(builder: (_) => VoucherScreen(code: args)),
          _ => null,
        };
      },
      // Rute tidak dikenal atau datanya tidak ada: kembali ke Beranda.
      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }
}
