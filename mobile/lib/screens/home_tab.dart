import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';
import '../widgets/floating_chat.dart';
import '../widgets/logo_mark.dart';

// Tab Beranda: header hijau tua berisi logo, lokasi, lonceng notifikasi, dan status keramaian,
// lalu banner foto yang bisa digeser, menu cepat, rekomendasi kunjungan per jam,
// dan chatbot Tanya Sira yang mengambang.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        // [P3 Stack] Chatbot mengambang ditumpuk di atas isi Beranda.
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _header(context),
              const SizedBox(height: 20),
              const _HeroCarousel(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const SectionTitle('Jelajahi', top: 24),
                  _quickMenu(context),
                  const SectionTitle('Rekomendasi Kunjungan', subtitle: 'Prediksi jumlah pengunjung per jam hari ini'),
                  _recommendation(),
                ]),
              ),
            ],
          ),
          const Positioned.fill(child: SafeArea(child: FloatingChat())),
        ]),
      ),
    );
  }

  // Header hijau tua yang ikut tergulir: logo, nama, lokasi, lonceng, dan kartu Crowd saat ini.
  Widget _header(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 14, 12, 22),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.forest, Color(0xFF245A43)]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const LogoMark(size: 42, ring: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sumber Sira', style: AppTheme.display(21, color: Colors.white)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.place_outlined, size: 14, color: AppColors.white(.75)),
                  const SizedBox(width: 4),
                  Text('Desa Putukrejo, Malang', style: TextStyle(fontSize: 12.5, color: AppColors.white(.75))),
                ]),
              ]),
            ),
            // Lonceng notifikasi dengan titik coral.
            IconButton(
              tooltip: 'Notifikasi',
              style: IconButton.styleFrom(backgroundColor: AppColors.white(.12), fixedSize: const Size(44, 44)),
              onPressed: () => _showNotifications(context),
              icon: const Badge(smallSize: 9, backgroundColor: AppColors.coral, child: Icon(Icons.notifications_none_rounded, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 18),
          const Padding(padding: EdgeInsets.only(right: 8), child: CrowdPill()),
        ]),
      );

  // [P5 Modal Bottom Sheet] Lembar notifikasi yang muncul dari bawah layar.
  void _showNotifications(BuildContext context) {
    final s = AppState.instance;
    final items = [
      (Icons.bar_chart_rounded, 'Crowd sekarang ${s.crowdLabel} (${s.percent}%)', 'Jam sepi terbaik 08.00-09.00 atau setelah 15.00'),
      (Icons.chat_outlined, 'E-tiket dan invoice dikirim lewat WhatsApp', 'Riwayat dicari dengan nomor WhatsApp di Tiket & Booking'),
      (Icons.notifications_active_outlined, s.quietReminder ? 'Pengingat jam sepi aktif' : 'Pengingat jam sepi nonaktif', 'Atur di menu Profil'),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Notifikasi', style: AppTheme.display(20)),
            const SizedBox(height: 8),
            for (final (i, (icon, title, text)) in items.indexed) ...[
              if (i > 0) const Divider(),
              InfoRow(icon: icon, title: title, text: text),
            ],
          ]),
        ),
      ),
    );
  }

  // [P3 Row + Expanded] Menu cepat dibagi rata. Isinya pengganti menu samping (garis tiga) yang dihapus.
  Widget _quickMenu(BuildContext context) {
    final items = [
      (Icons.photo_camera_outlined, 'AI Photo Studio', AppRoutes.aiPhoto),
      (Icons.star_outline_rounded, 'Ulasan & Rating', AppRoutes.reviews),
      (Icons.info_outline_rounded, 'Tentang Sumber Sira', AppRoutes.about),
    ];
    return Row(children: [
      for (final (i, (icon, label, route)) in items.indexed) ...[
        if (i > 0) const SizedBox(width: 10),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
            onTap: () => Navigator.pushNamed(context, route),
            child: Column(children: [
              IconBadge(icon, size: 50),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: Text(label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.3)),
              ),
            ]),
          ),
        ),
      ],
    ]);
  }

  // Rekomendasi kunjungan: grafik garis jumlah pengunjung per jam (isi menu Live Crowd yang dipindah ke sini).
  Widget _recommendation() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(12, 16, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Pengunjung (orang)', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
            const SizedBox(height: 6),
            const HourlyCrowdChart(height: 230),
            const SizedBox(height: 6),
            Row(children: const [
              SizedBox(width: 4),
              Expanded(child: CrowdLegend()),
              Text('Jam', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        const AppCard(
          color: AppColors.mint,
          borderColor: AppColors.pale,
          shadow: false,
          child: Row(children: [
            IconBadge(Icons.timer_outlined, background: Colors.white, color: AppColors.leaf),
            SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Waktu terbaik berkunjung', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.forest)),
                SizedBox(height: 2),
                Text('08.00-09.00 atau setelah 15.00', style: TextStyle(fontSize: 13)),
              ]),
            ),
          ]),
        ),
      ]);
}

// Banner foto yang bisa digeser kiri-kanan (PageView), tiap foto punya teks sendiri.
// Kartu berikutnya sedikit terlihat di tepi supaya jelas bisa digeser.
// Berganti otomatis setiap 5 detik, titik di bawah menandai foto yang sedang tampil.
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController(viewportFraction: .9);
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final next = (_page + 1) % DummyData.slides.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
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
    return Column(children: [
      SizedBox(
        height: 200,
        child: PageView.builder(
          controller: _controller,
          itemCount: DummyData.slides.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) {
            final s = DummyData.slides[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(fit: StackFit.expand, children: [
                  // [P4 Image.asset] Foto dari folder assets yang didaftarkan di pubspec.yaml.
                  Image.asset(s.image, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.ink.withValues(alpha: .05), AppColors.ink.withValues(alpha: .8)],
                        stops: const [.25, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.white(.22), borderRadius: BorderRadius.circular(20)),
                        child: Text(s.label, style: AppTheme.mono(10, weight: FontWeight.w600, color: Colors.white)),
                      ),
                      const Spacer(),
                      Text(s.title, style: AppTheme.display(21, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(s.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.white(.88))),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < DummyData.slides.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _page ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(color: i == _page ? AppColors.leaf : AppColors.pale, borderRadius: BorderRadius.circular(4)),
          ),
      ]),
    ]);
  }
}
