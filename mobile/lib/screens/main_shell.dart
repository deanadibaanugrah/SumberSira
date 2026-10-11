import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'crowd_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'tickets_tab.dart';

// Kerangka setelah login: 4 tab dengan navigasi bawah (Beranda, Tiket, Live Crowd, Profil).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Dipakai tab Beranda untuk pindah ke tab lain, mis. "Lihat prediksi" ke Live Crowd.
  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        // IndexedStack menjaga isi tiap tab tetap tersimpan saat berpindah tab.
        child: IndexedStack(index: _index, children: [
          HomeTab(onOpenTab: _goTo),
          const TicketsTab(),
          const CrowdTab(),
          const ProfileTab(),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        backgroundColor: AppColors.ink,
        indicatorColor: AppColors.leaf,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number), label: 'Tiket'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Live Crowd'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
