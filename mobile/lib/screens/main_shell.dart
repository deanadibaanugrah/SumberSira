import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/logo_mark.dart';
import 'crowd_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'tickets_tab.dart';

// Kerangka utama aplikasi: 4 tab dengan navigasi bawah dan menu samping (Drawer).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // State: tab yang sedang dibuka (0 Beranda, 1 Tiket, 2 Live Crowd, 3 Profil).
  int _index = 0;

  // Pindah tab. Dipakai navigasi bawah, menu samping, dan tombol di Beranda.
  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [P5 Navigasi Drawer] Menu samping, dibuka dari tombol menu di kiri atas Beranda.
      drawer: _AppDrawer(onSelectTab: _goTo),
      body: AppBackground(
        // IndexedStack menjaga isi tiap tab tetap tersimpan saat berpindah tab.
        child: IndexedStack(index: _index, children: [
          HomeTab(onOpenTab: _goTo),
          const TicketsTab(),
          const CrowdTab(),
          const ProfileTab(),
        ]),
      ),
      // [P5 Navigasi Tab] Navigasi bawah untuk berpindah antar tab.
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

// Isi menu samping: pindah tab atau membuka halaman lain.
class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    // Tutup drawer dulu (Navigator.pop), lalu pindah tab atau buka halaman (pushNamed).
    void tab(int index) {
      Navigator.pop(context);
      onSelectTab(index);
    }

    void page(String route) {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    }

    return Drawer(
      backgroundColor: AppColors.forest,
      child: SafeArea(
        child: ListView(padding: const EdgeInsets.symmetric(vertical: 16), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(children: [
              const LogoMark(size: 40, ring: true),
              const SizedBox(width: 12),
              Text('Sumber Sira', style: AppTheme.display(20)),
            ]),
          ),
          _item(Icons.home_outlined, 'Beranda', () => tab(0)),
          _item(Icons.confirmation_number_outlined, 'Tiket Saya', () => tab(1)),
          _item(Icons.bar_chart, 'Live Crowd', () => tab(2)),
          _item(Icons.calendar_month_outlined, 'Sewa & Booking', () => page(AppRoutes.booking)),
          _item(Icons.auto_awesome, 'Rencana Fitur AI', () => page(AppRoutes.aiPhoto)),
          _item(Icons.smart_toy_outlined, 'Tanya Sira (Chatbot)', () => page(AppRoutes.chatbot)),
          _item(Icons.star_outline_rounded, 'Ulasan & Rating', () => page(AppRoutes.reviews)),
          _item(Icons.info_outline, 'Tentang Sumber Sira', () => page(AppRoutes.about)),
          _item(Icons.person_outline, 'Profil', () => tab(3)),
        ]),
      ),
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) =>
      ListTile(leading: Icon(icon, color: Colors.white), title: Text(label, style: const TextStyle(fontSize: 13)), onTap: onTap);
}
