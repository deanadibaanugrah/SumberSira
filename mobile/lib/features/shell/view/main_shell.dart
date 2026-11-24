import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/app_state.dart';
import '../../chat/viewmodel/chat_controller.dart';
import '../../crowd/viewmodel/crowd_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/glass.dart';
import '../../../widgets/motion.dart';
import '../../gallery/view/gallery_tab.dart';
import '../../home/view/home_tab.dart';
import '../../profile/view/profile_tab.dart';
import '../../tickets/view/tickets_tab.dart';

// Kerangka utama aplikasi: 4 tab dengan tab bar kaca yang mengambang (tanpa menu samping).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  // State: tab yang sedang dibuka (0 Beranda, 1 Tiket & Booking, 2 Galeri, 3 Profil).
  int _index = 0;

  // Sinkronisasi latar belakang: perubahan dari admin (harga, wahana, galeri, ulasan, status
  // tiket/booking, pertanyaan cepat chat) ikut tampil tanpa perlu menarik layar atau membuka ulang tab.
  Timer? _syncTimer;
  bool _syncing = false;

  // Live Crowd diperbarui dari server tiap 30 detik selama kerangka utama terbuka.
  // Tarif juga dimuat sekali di awal supaya info harga di Beranda/Tiket/Profil bukan angka bawaan.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CrowdState.instance.startLive();
    AppState.instance.refreshPricing();
    _startSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopSync();
    CrowdState.instance.stopLive();
    super.dispose();
  }

  // Berhenti sebentar saat aplikasi tidak terlihat, lalu langsung menyegarkan ketika dibuka lagi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startSync();
      _syncNow();
      CrowdState.instance.refresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopSync();
    }
  }

  void _startSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) => _syncNow());
  }

  void _stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Satu putaran sinkronisasi. Tiap permintaan diberi penjaga sendiri supaya satu endpoint yang
  // gagal (mis. server sedang mati) tidak menghentikan pembaruan bagian lain.
  Future<void> _syncNow() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final s = AppState.instance;
      final wa = s.savedWhatsapp;
      await Future.wait([
        _guard(s.refreshPricing(silent: true)),
        _guard(s.refreshReviews(silent: true)),
        _guard(ChatController.instance.init()),
        if (wa.isNotEmpty) _guard(s.syncHistory(wa, silent: true)),
      ]);
      if (!mounted) return;
      // Daftar wahana dan galeri dicek ulang oleh pemilik layarnya masing-masing.
      s.tandaiWahanaStale();
      s.tandaiGaleriStale();
    } finally {
      _syncing = false;
    }
  }

  Future<void> _guard(Future<void> future) async {
    try {
      await future;
    } catch (_) {
      // Data terakhir tetap dipakai; putaran berikutnya mencoba lagi.
    }
  }

  // Membuka tab: tampilan berganti dengan animasi, dan data tab itu dimuat ulang dari server (seperti hard refresh).
  void _openTab(int i) {
    final same = i == _index;
    setState(() => _index = i);
    if (same) return;
    CrowdState.instance.refresh();
    AppState.instance.refreshPricing();
    if (i == 1) {
      final wa = AppState.instance.savedWhatsapp;
      if (wa.isNotEmpty) AppState.instance.syncHistory(wa).catchError((_) {});
    }
    if (i == 2) AppState.instance.tandaiGaleriStale();
    if (i == 3) AppState.instance.refreshReviews();
  }

  // Ikon garis untuk tab biasa, ikon penuh (fill) untuk tab aktif.
  static const _tabs = [
    (CupertinoIcons.house, CupertinoIcons.house_fill, 'Beranda'),
    (CupertinoIcons.ticket, CupertinoIcons.ticket_fill, 'Tiket & Booking'),
    (
      CupertinoIcons.photo_on_rectangle,
      CupertinoIcons.photo_fill_on_rectangle_fill,
      'Galeri',
    ),
    (
      CupertinoIcons.person_crop_circle,
      CupertinoIcons.person_crop_circle_fill,
      'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: isi tab tetap terlihat (samar) di belakang tab bar kaca.
      extendBody: true,
      body: AppBackground(
        // IndexedStack menjaga isi tiap tab tetap tersimpan saat berpindah tab.
        child: _TabFader(
          index: _index,
          child: IndexedStack(
            index: _index,
            children: const [
              HomeTab(),
              TicketsTab(),
              GalleryTab(),
              ProfileTab(),
            ],
          ),
        ),
      ),
      // [P5 Navigasi Tab] Tab bar bawah untuk berpindah antar tab.
      bottomNavigationBar: _GlassTabBar(index: _index, onChanged: _openTab),
    );
  }
}

// Tab bar Liquid Glass: kapsul kaca mengambang. Kapsul penanda meluncur dengan pegas ke tab yang dipilih dan
// memanjang saat bergerak. Ikon tab aktif berganti ke ikon penuh Hijau Daun dan melonjak kecil.
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
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: LiquidPill(
                        index: index,
                        count: _MainShellState._tabs.length,
                        decoration: BoxDecoration(
                          color: AppColors.leaf12,
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final (i, (icon, activeIcon, label))
                            in _MainShellState._tabs.indexed)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: i == index,
                              label: label,
                              excludeSemantics: true,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (i != index) AppMotion.tick();
                                  onChanged(i);
                                },
                                child: PressScale(
                                  scale: .92,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedScale(
                                        scale: i == index ? 1.12 : 1,
                                        duration: still
                                            ? Duration.zero
                                            : const Duration(milliseconds: 360),
                                        curve: Curves.easeOutBack,
                                        child: TweenAnimationBuilder<Color?>(
                                          tween: ColorTween(
                                            end: i == index
                                                ? AppColors.leaf
                                                : AppColors.abu,
                                          ),
                                          duration: still
                                              ? Duration.zero
                                              : const Duration(
                                                  milliseconds: 220,
                                                ),
                                          builder: (_, color, _) => Icon(
                                            i == index ? activeIcon : icon,
                                            size: 23,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: AnimatedDefaultTextStyle(
                                          duration: still
                                              ? Duration.zero
                                              : const Duration(
                                                  milliseconds: 220,
                                                ),
                                          style: AppText.tabLabel.copyWith(
                                            color: i == index
                                                ? AppColors.forest
                                                : AppColors.abu,
                                          ),
                                          child: Text(label, maxLines: 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Memudarkan dan menggeser tipis isi tab setiap kali tab berganti. Isi semua tab tetap tersimpan (IndexedStack),
// jadi pilihan dan pencarian di tab lain tidak hilang.
class _TabFader extends StatefulWidget {
  const _TabFader({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_TabFader> createState() => _TabFaderState();
}

class _TabFaderState extends State<_TabFader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void didUpdateWidget(_TabFader old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !MediaQuery.disableAnimationsOf(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, .025),
        end: Offset.zero,
      ).animate(_curve),
      child: widget.child,
    ),
  );
}
