import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/app_state.dart';

import 'screens/ai_photo_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/eticket_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/ticket_form_screen.dart';
import 'theme/app_theme.dart';
import 'utils/routes.dart';

// Titik awal aplikasi pengunjung Sumber Sira.
// [P6] main() dibuat async: menyiapkan format tanggal Indonesia (intl) dan membaca pengaturan
// yang tersimpan di perangkat (shared_preferences) sebelum aplikasi tampil.
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
        AppRoutes.main: (_) => const MainShell(),
        AppRoutes.buyTicket: (_) => const TicketFormScreen(),
        AppRoutes.booking: (_) => const BookingScreen(),
        AppRoutes.aiPhoto: (_) => const AiPhotoScreen(),
      },
      // Rute yang membawa data: halaman e-tiket menerima kode tiket.
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.eticket) {
          final code = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => ETicketScreen(code: code));
        }
        return null;
      },
    );
  }
}
