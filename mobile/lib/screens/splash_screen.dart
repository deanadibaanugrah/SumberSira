import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/glass.dart';
import '../widgets/logo_mark.dart';

// Layar pembuka: foto bergerak pelan di atas, lembar gelap berisi logo dengan riak air, nama, chip keunggulan,
// dan garis loading. Setelah 3,2 detik pindah otomatis (Tentang saat pertama kali, berikutnya Beranda). Ketuk untuk lewati.
// [P3 StatefulWidget] Punya state (animasi dan timer) yang berubah selama layar tampil.
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
    // Pertama kali dibuka: kenalan dulu lewat Tentang dan Onboarding. Berikutnya langsung Beranda.
    Navigator.pushReplacementNamed(context, AppState.instance.onboardingDone ? AppRoutes.main : AppRoutes.about);
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
    final inset = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: GestureDetector(
          onTap: _next,
          child: LayoutBuilder(builder: (context, box) {
            // Tinggi minimal 640 supaya di layar pendek / landscape bisa digulir, tidak overflow.
            final h = max(box.maxHeight, 640.0);
            final photoH = h * .5;
            return SingleChildScrollView(
              child: SizedBox(
                height: h,
                child: Stack(children: [
                  // Foto latar yang pelan-pelan membesar.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: photoH + 40,
                    child: ClipRect(
                      child: ScaleTransition(
                        scale: Tween(begin: 1.05, end: 1.18).animate(_zoom),
                        child: Image.asset('assets/images/splash-sumber-sira.jpg', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Positioned(top: inset.top + 16, left: 0, right: 0, child: Center(child: _locationPill())),
                  // Lembar gelap (gradien Latar Mobile) yang menumpuk sedikit di atas foto.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: photoH,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.only(bottom: inset.bottom),
                      decoration: const BoxDecoration(gradient: AppColors.headerGradient, borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
                      child: Column(children: [
                        // Ruang untuk separuh logo yang menumpuk di tepi lembar ditambah ruang kosong logo.
                        const SizedBox(height: 86),
                        Text('Sumber Sira', style: AppText.largeTitle()),
                        const SizedBox(height: 4),
                        Text('Kunjungan Jernih Tanpa Antre', style: AppText.subheadline.copyWith(color: AppColors.putih72)),
                        const SizedBox(height: 18),
                        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                          for (final chip in const ['Air jernih', 'Tanpa antre', 'Live Crowd']) _chip(chip),
                        ]),
                        const Spacer(),
                        _loadingBar(),
                        const SizedBox(height: 36),
                      ]),
                    ),
                  ),
                  // Logo di tepi atas lembar, dengan riak air di luar ruang kosongnya.
                  Positioned(top: photoH - 150, left: 0, right: 0, child: Center(child: _rippleLogo())),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _locationPill() => Glass(
        radius: 18,
        shadow: false,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(CupertinoIcons.location_solid, size: 14, color: AppColors.leaf),
          const SizedBox(width: 6),
          Text('Desa Putukrejo, Malang', style: AppText.footnote.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
        ]),
      );

  // Logo dengan tiga riak air yang bergantian melebar lalu hilang. Riak dimulai di luar ruang kosong logo (25%).
  Widget _rippleLogo() => SizedBox.square(
        dimension: 300,
        child: AnimatedBuilder(
          animation: _ripple,
          builder: (_, child) => Stack(alignment: Alignment.center, children: [
            for (var i = 0; i < 3; i++)
              Builder(builder: (_) {
                final t = (_ripple.value + i / 3) % 1;
                return Opacity(
                  opacity: 1 - t,
                  child: Container(
                    width: 144 + 150 * t,
                    height: 144 + 150 * t,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.kaca, width: 2)),
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
        decoration: BoxDecoration(color: AppColors.kaca, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.kaca)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.leaf, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: AppText.footnote.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
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
              child: LinearProgressIndicator(value: _progress.value, minHeight: 6, backgroundColor: AppColors.kaca, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('Menyiapkan kunjunganmu...', style: AppText.footnote.copyWith(color: AppColors.putih72)),
        const SizedBox(height: 2),
        Text('Ketuk di mana saja untuk lanjut', style: AppText.caption.copyWith(color: AppColors.putih72)),
      ]);
}
