import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/app_state.dart';
import '../../crowd/viewmodel/crowd_state.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/routes.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/common.dart';
import '../../crowd/view/crowd_widgets.dart';
import '../../chat/view/floating_chat.dart';
import '../../../widgets/glass.dart';
import '../../../widgets/logo_mark.dart';

// Banner geser Beranda: konten promosi tetap dengan foto asli Sumber Sira (bukan data operasional).
// Harga tidak ditulis di sini supaya tidak berbeda dari tarif yang diatur di server.
const _homeSlides = [
  (
    image: 'assets/images/hero-sawah.jpg',
    label: 'SUMBER SIRA',
    title: 'Kunjungan Jernih Tanpa Antre',
    text: 'Wisata mata air di tengah sawah Desa Putukrejo, Malang.',
  ),
  (
    image: 'assets/images/onboarding-air-jernih.jpg',
    label: 'MATA AIR ALAMI',
    title: 'Air Jernih dari Sumber Asli',
    text: 'Berenang dan main air bareng ikan wader lokal.',
  ),
  (
    image: 'assets/images/onboarding-kereta-sawah.jpg',
    label: 'WAHANA',
    title: 'Kereta Sawah & Wahana Seru',
    text: 'Sewa ban, ATV, dan flying fox lewat menu Tiket & Booking.',
  ),
  (
    image: 'assets/images/onboarding-bawah-air.jpg',
    label: 'AI PHOTO STUDIO',
    title: 'Foto Lebih Jernih dan Berwarna',
    text: 'Perbagus warna foto dari galeri HP secara otomatis.',
  ),
  (
    image: 'assets/images/komunitas-2.jpg',
    label: 'TIKET ONLINE',
    title: 'Beli Tiket, Tanpa Antre',
    text: 'Beli tiket online, tunjukkan QR di pintu masuk.',
  ),
];

// Tab Beranda: header gelap berisi logo, lokasi, notifikasi, dan hero keramaian (angka besar),
// lalu menu cepat, carousel foto, grafik rekomendasi kunjungan per jam,
// dan chatbot Tanya Sira yang mengambang.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TabPage(
      title: 'Sumber Sira',
      header: _header(context),
      // [P3 Stack] Chatbot mengambang ditumpuk di atas isi Beranda.
      overlay: const Positioned.fill(child: SafeArea(child: FloatingChat())),
      children: [
        const SizedBox(height: 20),
        _quickMenu(context),
        const SectionTitle('Jelajahi'),
        const FullBleed(child: _HeroCarousel()),
        const SectionTitle(
          'Keramaian Hari Ini',
          subtitle: 'Jumlah orang di dalam per jam, dari tiket yang discan',
        ),
        _recommendation(),
      ],
    );
  }

  // Header gelap yang ikut tergulir: logo, nama, lokasi, lonceng, lalu hero Crowd saat ini.
  Widget _header(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: EdgeInsets.fromLTRB(
      AppSpace.margin,
      MediaQuery.paddingOf(context).top + 12,
      16,
      20,
    ),
    decoration: const BoxDecoration(
      gradient: AppColors.headerGradient,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const LogoMark(size: 42, ring: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sumber Sira',
                    style: AppText.headline.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        size: 13,
                        color: AppColors.putih72,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Desa Putukrejo, Malang',
                        style: AppText.footnote.copyWith(
                          color: AppColors.putih72,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Lonceng notifikasi dengan titik Hijau Daun.
            GlassIconButton(
              icon: CupertinoIcons.bell,
              tooltip: 'Notifikasi',
              tone: GlassTone.dark,
              badge: true,
              onPressed: () => _showNotifications(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const CrowdHero(),
      ],
    ),
  );

  // [P5 Modal Bottom Sheet] Lembar kaca notifikasi yang muncul dari bawah layar.
  void _showNotifications(BuildContext context) {
    final s = AppState.instance;
    final c = CrowdState.instance;
    final items = [
      (
        CupertinoIcons.chart_bar,
        c.ready
            ? 'Crowd sekarang ${c.crowdLabel} (${c.percent}%)'
            : 'Data keramaian belum tersedia',
        c.ready
            ? 'Dari tiket yang discan petugas di pintu masuk'
            : 'Server belum terjangkau. Coba lagi nanti.',
      ),
      (
        CupertinoIcons.chat_bubble_text,
        'E-tiket dan invoice dikirim lewat WhatsApp',
        'Riwayat dicari dengan nomor WhatsApp di Tiket & Booking',
      ),
      (
        CupertinoIcons.bell,
        s.quietReminder
            ? 'Pengingat jam sepi aktif'
            : 'Pengingat jam sepi nonaktif',
        'Atur di menu Profil',
      ),
    ];
    showGlassSheet<void>(
      context,
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Notifikasi', style: AppText.title2),
          const SizedBox(height: 14),
          GroupedList(
            children: [
              for (final (icon, title, text) in items)
                ListRow(
                  icon: icon,
                  title: title,
                  subtitle: text,
                  titleStyle: AppText.subheadline.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // [P3 Row + Expanded] Menu cepat dibagi rata. Satu-satunya grup ikon berwadah (Hijau Daun 12%) di layar ini.
  Widget _quickMenu(BuildContext context) {
    final items = [
      (CupertinoIcons.camera, 'AI Photo Studio', AppRoutes.aiPhoto),
      (CupertinoIcons.star, 'Ulasan & Rating', AppRoutes.reviews),
      (CupertinoIcons.info_circle, 'Tentang Sumber Sira', AppRoutes.about),
    ];
    return Row(
      children: [
        for (final (i, (icon, label, route)) in items.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
              onTap: () => Navigator.pushNamed(context, route),
              child: Column(
                children: [
                  IconBadge(icon),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: AppText.footnote.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Grafik batang prakiraan jumlah pengunjung per jam dari server dan saran waktu terbaik berkunjung.
  Widget _recommendation() => AppCard(
    padding: const EdgeInsets.fromLTRB(14, 16, 16, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Text('Pengunjung (orang)', style: AppText.caption),
        ),
        const SizedBox(height: 4),
        const HourlyCrowdChart(height: 200),
        const SizedBox(height: 10),
        const Padding(padding: EdgeInsets.only(left: 2), child: CrowdLegend()),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(),
        ),
        // Saran umum: server tidak menyediakan jam paling sepi dari riwayat.
        Row(
          children: [
            const SizedBox(width: 2),
            const Icon(CupertinoIcons.clock, size: 20, color: AppColors.leaf),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waktu terbaik berkunjung',
                    style: AppText.subheadline.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '08.00-09.00 atau setelah 15.00',
                    style: AppText.number(
                      15,
                      weight: FontWeight.w500,
                      color: AppColors.abu,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Carousel foto yang bisa digeser kiri-kanan (PageView), tiap foto punya teks sendiri di panel kaca.
// Kartu berikutnya sedikit terlihat di tepi supaya jelas bisa digeser.
// Berganti otomatis setiap 5 detik, titik di bawah menandai foto yang sedang tampil.
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController(viewportFraction: .86);
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final next = (_page + 1) % _homeSlides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 236,
          child: PageView.builder(
            controller: _controller,
            itemCount: _homeSlides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final s = _homeSlides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // [P4 Image.asset] Foto dari folder assets yang didaftarkan di pubspec.yaml.
                      Image.asset(s.image, fit: BoxFit.cover),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        // Kaca terang + teks Ink supaya tetap terbaca di foto yang terang.
                        child: Glass(
                          radius: 18,
                          shadow: false,
                          padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.label,
                                style: AppText.caption.copyWith(
                                  color: AppColors.forest,
                                  letterSpacing: .6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                s.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.headline,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.footnote,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _homeSlides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.leaf : AppColors.leaf30,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
