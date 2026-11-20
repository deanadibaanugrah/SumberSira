import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/routes.dart';
import '../../../widgets/common.dart';
import '../../../widgets/glass.dart';
import '../../../widgets/motion.dart';

// Onboarding 3 halaman yang bisa digeser (PageView): air jernih, booking tanpa antre, foto AI.
// Foto memenuhi layar, lembar kaca di bawah berisi titik penanda, judul, penjelasan, dan tombol Kembali/Lanjut.
// Halaman terakhir: Mulai Jelajahi. Lewati ada di pojok kanan atas.
// Halaman pindah sendiri tiap 3 detik (titik aktif terisi sebagai penanda waktu) dan berhenti di halaman terakhir.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
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
  late final _timer = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..addStatusListener(_onTimer);
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

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );

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
    final page = _pages[_page];
    return Scaffold(
      backgroundColor: AppColors.forest,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // Foto memenuhi layar dan bisa digeser kiri-kanan.
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) {
                    setState(() => _page = i);
                    _restartTimer();
                  },
                  itemBuilder: (_, i) => _OnboardingPhoto(_pages[i].image),
                ),
              ),
            ),
            // Penanda halaman ke berapa dari 3 dan tombol Lewati, di atas foto.
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.margin,
                  8,
                  AppSpace.margin,
                  0,
                ),
                child: Row(
                  children: [
                    Glass(
                      tone: GlassTone.dark,
                      radius: 22,
                      shadow: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        '${_page + 1} / ${_pages.length}',
                        style: AppText.number(
                          13,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (!_isLast)
                      Pressable(
                        onTap: _finish,
                        semanticLabel: 'Lewati',
                        child: Glass(
                          tone: GlassTone.dark,
                          radius: 22,
                          shadow: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          child: const Text(
                            'Lewati',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Lembar kaca di bawah: titik penanda, judul, penjelasan, tombol.
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Glass(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                  shadow: false,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _dots(),
                            const SizedBox(height: 18),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Column(
                                key: ValueKey(_page),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(page.title, style: AppText.display(28)),
                                  const SizedBox(height: 10),
                                  Text(
                                    page.text,
                                    style: AppText.subheadline.copyWith(
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                // Halaman pertama tidak punya tombol Kembali, jadi diganti ruang kosong.
                                if (_page != 0) ...[
                                  Expanded(
                                    child: PressScale(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size.fromHeight(
                                            50,
                                          ),
                                          foregroundColor: AppColors.forest,
                                          backgroundColor: AppColors.leaf12,
                                          shape: const StadiumBorder(),
                                          textStyle: AppText.headline,
                                        ),
                                        onPressed: () => _goTo(_page - 1),
                                        child: const Text('Kembali'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                ],
                                Expanded(
                                  flex: 2,
                                  child: PrimaryButton(
                                    label: _isLast
                                        ? 'Mulai Jelajahi'
                                        : 'Lanjut',
                                    onPressed: _isLast
                                        ? _finish
                                        : () => _goTo(_page + 1),
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
            ),
          ],
        ),
      ),
    );
  }

  // Titik penanda: titik halaman aktif lebih panjang dan terisi Hijau Daun selama 3 detik sebelum pindah halaman.
  Widget _dots() => AnimatedBuilder(
    animation: _timer,
    builder: (context, _) => Row(
      children: [
        for (var i = 0; i < _pages.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 6),
            width: i == _page ? 26 : 8,
            height: 8,
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.leaf30,
              borderRadius: BorderRadius.circular(4),
            ),
            child: i == _page
                ? FractionallySizedBox(
                    widthFactor: _autoOff ? 1 : _timer.value,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.leaf,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : null,
          ),
      ],
    ),
  );
}

// Foto satu halaman onboarding, memenuhi layar dengan peredam Hijau Tua di atas dan bawah.
class _OnboardingPhoto extends StatelessWidget {
  const _OnboardingPhoto(this.image);

  final String image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, .3, .6, 1],
              colors: [
                Color(0x801B4332),
                Color(0x001B4332),
                Color(0x001B4332),
                Color(0x8C1B4332),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
