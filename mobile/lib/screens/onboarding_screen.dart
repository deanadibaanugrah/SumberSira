import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Onboarding 3 halaman yang bisa digeser (PageView): air jernih, booking tanpa antre, foto AI.
// Tombol Kembali/Lanjut, titik penanda halaman, dan Lewati. Halaman terakhir: Mulai Jelajahi.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
  // State: halaman yang sedang tampil (0, 1, atau 2).
  int _page = 0;

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(page, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);

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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(children: [
                  SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _isLast ? null : TextButton(onPressed: _finish, child: Text('Lewati', style: TextStyle(color: AppColors.white(.8)))),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (_, i) => _OnboardingPage(page: _pages[i], dots: _dots()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    // Halaman pertama tidak punya tombol Kembali, jadi diganti ruang kosong.
                    Expanded(
                      child: _page == 0
                          ? const SizedBox()
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.white(.1),
                                side: BorderSide(color: AppColors.white(.3)),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () => _goTo(_page - 1),
                              child: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                    ),
                    const SizedBox(width: 18),
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

  // Titik penanda: titik halaman aktif lebih panjang dan berwarna Hijau Daun.
  Widget _dots() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < _pages.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _page ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(color: i == _page ? AppColors.leaf : AppColors.white(.3), borderRadius: BorderRadius.circular(4)),
          ),
      ]);
}

// Isi satu halaman onboarding: foto, titik penanda, judul, dan penjelasan.
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
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(page.image, height: box.maxHeight * .58, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 22),
          dots,
          const SizedBox(height: 22),
          Text(page.title, textAlign: TextAlign.center, style: AppTheme.display(24)),
          const SizedBox(height: 12),
          Text(page.text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.white(.75), height: 1.4)),
        ]),
      ),
    );
  }
}
