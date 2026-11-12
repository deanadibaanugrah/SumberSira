import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass.dart';
import 'gallery_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'tickets_tab.dart';

// Kerangka utama aplikasi: 4 tab dengan tab bar kaca yang mengambang (tanpa menu samping).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // State: tab yang sedang dibuka (0 Beranda, 1 Tiket & Booking, 2 Galeri, 3 Profil).
  int _index = 0;

  // Ikon garis untuk tab biasa, ikon penuh (fill) untuk tab aktif.
  static const _tabs = [
    (CupertinoIcons.house, CupertinoIcons.house_fill, 'Beranda'),
    (CupertinoIcons.ticket, CupertinoIcons.ticket_fill, 'Tiket & Booking'),
    (CupertinoIcons.photo_on_rectangle, CupertinoIcons.photo_fill_on_rectangle_fill, 'Galeri'),
    (CupertinoIcons.person_crop_circle, CupertinoIcons.person_crop_circle_fill, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: isi tab tetap terlihat (samar) di belakang tab bar kaca.
      extendBody: true,
      body: AppBackground(
        // IndexedStack menjaga isi tiap tab tetap tersimpan saat berpindah tab.
        child: IndexedStack(index: _index, children: const [
          HomeTab(),
          TicketsTab(),
          GalleryTab(),
          ProfileTab(),
        ]),
      ),
      // [P5 Navigasi Tab] Tab bar bawah untuk berpindah antar tab.
      bottomNavigationBar: _GlassTabBar(index: _index, onChanged: (i) => setState(() => _index = i)),
    );
  }
}

// Tab bar Liquid Glass: kapsul kaca mengambang. Tab aktif = ikon penuh Hijau Daun di atas pill Hijau Daun 12%.
class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpace.tabGap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Glass(
              radius: 32,
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                height: AppSpace.tabBar - 12,
                child: Row(children: [
                  for (final (i, (icon, activeIcon, label)) in _MainShellState._tabs.indexed)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: i == index,
                        label: label,
                        excludeSemantics: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: AnimatedContainer(
                            duration: still ? Duration.zero : const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(color: i == index ? AppColors.leaf12 : Colors.transparent, borderRadius: BorderRadius.circular(26)),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(i == index ? activeIcon : icon, size: 23, color: i == index ? AppColors.leaf : AppColors.abu),
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(label, maxLines: 1, style: AppText.tabLabel.copyWith(color: i == index ? AppColors.forest : AppColors.abu)),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
