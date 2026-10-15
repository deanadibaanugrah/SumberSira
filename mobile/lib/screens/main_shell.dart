import 'package:flutter/material.dart';

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
    return Scaffold(
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.ink,
        indicatorColor: AppColors.leaf,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        // Teks label sedikit kecil supaya "Tiket & Booking" muat satu baris.
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number), label: 'Tiket & Booking'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: 'Galeri'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
