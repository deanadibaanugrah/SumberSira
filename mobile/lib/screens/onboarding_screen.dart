import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Onboarding 3 halaman yang bisa digeser (PageView): air jernih, booking tanpa antre, foto AI.
// Tombol Kembali/Lanjut, titik penanda halaman, dan Lewati. Halaman terakhir: Mulai Jelajahi.
// Halaman pindah sendiri tiap 3 detik (titik aktif terisi sebagai penanda waktu) dan berhenti di halaman terakhir.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  static const _pages = [
    (
      image: 'assets/images/onboarding-air-jernih.jpg',
      title: 'Air Jernih dari Mata Air Asli',
      text: 'Nikmati kolam alami dengan air jernih langsung dari sumber, dikelilingi rumput ganggang & ikan wader lokal.',
    ),
    (
      image: 'assets/images/onboarding-kereta-sawah.jpg',
      title: 'Booking Wahana Tanpa Antre',
      text: 'Sewa ban, ATV, flying fox, & wahana lain dari rumah. Cek keramaian real-time sebelum berangkat.',
    ),
    (
      image: 'assets/images/onboarding-bawah-air.jpg',
      title: 'Foto Bawah Air Jadi Lebih Jernih',
      text: 'Belum ada fotografer di lokasi? AI Underwater Photo Studio bikin fotomu tetap estetik.',
    ),
  ];

  final _controller = PageController();
  // Lama tampil halaman sekarang (0 sampai 1). Saat penuh, pindah ke halaman berikutnya.
  late final _timer = AnimationController(vsync: this, duration: const Duration(seconds: 3))..addStatusListener(_onTimer);
  // State: halaman yang sedang tampil (0, 1, atau 2).
  int _page = 0;
  // Selama halaman digeser jari, hitungan waktu berhenti dulu.
  bool _dragging = false;

  bool get _isLast => _page == _pages.length - 1;

  // Tidak pindah sendiri di halaman terakhir, juga kalau animasi dikurangi di pengaturan HP.
  bool get _autoOff => _isLast || MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restartTimer());
  }

  @override
  void dispose() {
    _timer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(page, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);

  void _onTimer(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isLast) _goTo(_page + 1);
  }

  // Hitung 3 detik dari awal untuk halaman yang baru tampil.
  void _restartTimer() {
    if (!mounted) return;
    _timer.value = 0;
    if (!_autoOff && !_dragging) _timer.forward();
  }

  // Digeser jari: waktu berhenti. Kalau batal pindah halaman, waktu dilanjutkan dari posisi tadi.
  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _dragging = true;
      _timer.stop();
    } else if (n is ScrollEndNotification && _dragging) {
      _dragging = false;
      if (!_autoOff && !_timer.isAnimating) _timer.forward();
    }
    return false;
  }

  // Selesai onboarding: simpan tandanya (shared_preferences) lalu ke Beranda tanpa bisa kembali.
  void _finish() {
    AppState.instance.finishOnboarding();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.margin, 4, AppSpace.margin, 20),
                child: Column(children: [
                  SizedBox(
                    height: 48,
                    child: Row(children: [
                      // Penanda halaman ke berapa dari 3.
                      Text('${_page + 1} / ${_pages.length}', style: AppText.number(13, weight: FontWeight.w600, color: AppColors.abu)),
                      const Spacer(),
                      if (!_isLast)
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: AppColors.forest, minimumSize: const Size(44, 44)),
                          onPressed: _finish,
                          child: const Text('Lewati', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                        ),
                    ]),
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScroll,
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _pages.length,
                        onPageChanged: (i) {
                          setState(() => _page = i);
                          _restartTimer();
                        },
                        itemBuilder: (_, i) => _OnboardingPage(page: _pages[i], dots: _dots()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    // Halaman pertama tidak punya tombol Kembali, jadi diganti ruang kosong.
                    Expanded(
                      child: _page == 0
                          ? const SizedBox()
                          : TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                foregroundColor: AppColors.forest,
                                backgroundColor: AppColors.leaf12,
                                shape: const StadiumBorder(),
                                textStyle: AppText.headline,
                              ),
                              onPressed: () => _goTo(_page - 1),
                              child: const Text('Kembali'),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: PrimaryButton(
                        label: _isLast ? 'Mulai Jelajahi' : 'Lanjut',
                        onPressed: _isLast ? _finish : () => _goTo(_page + 1),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Titik penanda: titik halaman aktif lebih panjang dan terisi Hijau Daun selama 3 detik sebelum pindah halaman.
  Widget _dots() => AnimatedBuilder(
        animation: _timer,
        builder: (context, _) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < _pages.length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == _page ? 24 : 8,
              height: 8,
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: AppColors.leaf30, borderRadius: BorderRadius.circular(4)),
              child: i == _page
                  ? FractionallySizedBox(
                      widthFactor: _autoOff ? 1 : _timer.value,
                      heightFactor: 1,
                      child: DecoratedBox(decoration: BoxDecoration(color: AppColors.leaf, borderRadius: BorderRadius.circular(4))),
                    )
                  : null,
            ),
        ]),
      );
}

// Isi satu halaman onboarding: foto (hero), titik penanda, judul, dan penjelasan.
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page, required this.dots});

  final ({String image, String title, String text}) page;
  final Widget dots;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(page.image, height: box.maxHeight * .58, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          dots,
          const SizedBox(height: 20),
          Text(page.title, textAlign: TextAlign.center, style: AppText.title2.copyWith(fontSize: 26, height: 32 / 26)),
          const SizedBox(height: 10),
          Text(page.text, textAlign: TextAlign.center, style: AppText.subheadline.copyWith(height: 1.45)),
        ]),
      ),
    );
  }
}
