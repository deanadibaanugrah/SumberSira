import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'gallery_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'tickets_tab.dart';

// Kerangka utama aplikasi: 4 tab dengan navigasi bawah (tanpa menu samping).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // State: tab yang sedang dibuka (0 Beranda, 1 Tiket & Booking, 2 Galeri, 3 Profil).
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Semua tab punya header hijau tua, jadi ikon status bar dibuat putih.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AppBackground(
          // IndexedStack menjaga isi tiap tab tetap tersimpan saat berpindah tab.
          child: IndexedStack(index: _index, children: const [
            HomeTab(),
            TicketsTab(),
            GalleryTab(),
            ProfileTab(),
          ]),
        ),
        // [P5 Navigasi Tab] Navigasi bawah untuk berpindah antar tab.
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: AppShadows.bar),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.pale,
            elevation: 0,
            height: 68,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            // Label aktif hijau tua dan tebal, label lain abu-abu. Ukuran 11 supaya "Tiket & Booking" muat satu baris.
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                  fontSize: 11,
                  fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
                  color: states.contains(WidgetState.selected) ? AppColors.forest : AppColors.muted,
                )),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined, color: AppColors.muted), selectedIcon: Icon(Icons.home_rounded, color: AppColors.forest), label: 'Beranda'),
              NavigationDestination(
                  icon: Icon(Icons.confirmation_number_outlined, color: AppColors.muted),
                  selectedIcon: Icon(Icons.confirmation_number_rounded, color: AppColors.forest),
                  label: 'Tiket & Booking'),
              NavigationDestination(
                  icon: Icon(Icons.photo_library_outlined, color: AppColors.muted), selectedIcon: Icon(Icons.photo_library_rounded, color: AppColors.forest), label: 'Galeri'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded, color: AppColors.muted), selectedIcon: Icon(Icons.person_rounded, color: AppColors.forest), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
