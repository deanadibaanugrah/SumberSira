import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/logo_mark.dart';

// Layar pembuka: foto bergerak pelan, riak air dari logo, chip keunggulan, dan garis loading.
// Setelah 3,2 detik pindah otomatis ke Login (atau Home kalau sudah login). Ketuk untuk lewati.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 3200);
  late final AnimationController _progress = AnimationController(vsync: this, duration: _duration)..forward();
  late final AnimationController _ripple = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  late final AnimationController _zoom = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat(reverse: true);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_duration, _next);
  }

  // Pindah ke layar berikutnya (dipanggil timer atau saat layar diketuk).
  void _next() {
    _timer?.cancel();
    // Hanya pindah kalau Splash masih layar paling atas (mis. tidak tertutup layar lain dari link langsung).
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    Navigator.pushReplacementNamed(context, AppState.instance.isLoggedIn ? AppRoutes.main : AppRoutes.login);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    _ripple.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _next,
        child: Stack(fit: StackFit.expand, children: [
          // Foto latar yang pelan-pelan membesar.
          ScaleTransition(
            scale: Tween(begin: 1.05, end: 1.18).animate(_zoom),
            child: Image.asset('assets/images/splash-sumber-sira.jpg', fit: BoxFit.cover),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.forest.withValues(alpha: .6), AppColors.forest.withValues(alpha: .25), AppColors.ink.withValues(alpha: .9)],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              // Tinggi minimal 560 supaya di layar pendek / landscape bisa digulir, tidak overflow.
              builder: (context, box) => SingleChildScrollView(
                child: SizedBox(
                  height: max(box.maxHeight, 560),
                  child: Column(children: [
                    const SizedBox(height: 24),
                    _locationPill(),
                    const Spacer(flex: 2),
                    _rippleLogo(),
                    const SizedBox(height: 28),
                    Text('Sumber Sira', style: AppTheme.display(34)),
                    const SizedBox(height: 6),
                    Text('Kunjungan Jernih Tanpa Antre', style: TextStyle(fontSize: 13, color: AppColors.white(.85))),
                    const SizedBox(height: 18),
                    Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                      for (final chip in const ['Air jernih', 'Tanpa antre', 'Live Crowd']) _chip(chip),
                    ]),
                    const Spacer(flex: 3),
                    _loadingBar(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _locationPill() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: AppColors.white(.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.white(.25))),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.place_outlined, size: 13),
          SizedBox(width: 6),
          Text('Desa Putukrejo, Malang', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ]),
      );

  // Logo dengan tiga riak air yang bergantian melebar lalu hilang.
  Widget _rippleLogo() => SizedBox.square(
        dimension: 96,
        child: AnimatedBuilder(
          animation: _ripple,
          builder: (_, child) => Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
            for (var i = 0; i < 3; i++)
              Builder(builder: (_) {
                final t = (_ripple.value + i / 3) % 1;
                return Transform.scale(
                  scale: 1 + 1.3 * t,
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.white(.5 * (1 - t)), width: 2)),
                  ),
                );
              }),
            child!,
          ]),
          child: const LogoMark(size: 96, ring: true),
        ),
      );

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: AppColors.white(.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.white(.25))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.leaf, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ]),
      );

  // Garis loading yang terisi penuh tepat saat pindah layar.
  Widget _loadingBar() => Column(children: [
        SizedBox(
          width: 160,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (_, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: _progress.value, minHeight: 6, backgroundColor: AppColors.white(.2), color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('Menyiapkan kunjunganmu...', style: TextStyle(fontSize: 10, color: AppColors.white(.75))),
        const SizedBox(height: 4),
        Text('Ketuk di mana saja untuk lanjut', style: TextStyle(fontSize: 9, color: AppColors.white(.5))),
      ]);
}
