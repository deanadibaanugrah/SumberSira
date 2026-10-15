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

// Tab Beranda: bar atas dengan garis pembatas, banner foto yang bisa digeser, status keramaian,
// menu cepat, rekomendasi kunjungan per jam, dan chatbot Tanya Sira yang mengambang.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(children: [
            _topBar(context),
            Expanded(
              // [P3 Stack] Chatbot mengambang ditumpuk di atas isi Beranda.
              child: Stack(children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 90),
                  children: [
                    // Banner tanpa jarak kiri-kanan (mentok ke tepi layar).
                    const _HeroCarousel(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        const CrowdPill(),
                        const SizedBox(height: 16),
                        _quickMenu(context),
                        const SizedBox(height: 24),
                        _recommendation(),
                      ]),
                    ),
                  ],
                ),
                const Positioned.fill(child: FloatingChat()),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // Bar atas yang tetap di tempat saat isi digulir, dipisah garis tipis di bawahnya.
  Widget _topBar(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.white(.18)))),
        child: Row(children: [
          const LogoMark(size: 32, ring: true),
          const SizedBox(width: 10),
          Expanded(child: Text('Sumber Sira', style: AppTheme.display(20))),
          // Lonceng notifikasi dengan titik coral.
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => _showNotifications(context),
            icon: const Badge(smallSize: 8, backgroundColor: AppColors.coral, child: Icon(Icons.notifications_none)),
          ),
        ]),
      );

  // [P5 Modal Bottom Sheet] Lembar notifikasi yang muncul dari bawah layar.
  void _showNotifications(BuildContext context) {
    final s = AppState.instance;
    final items = [
      (Icons.bar_chart, 'Crowd sekarang ${s.crowdLabel} (${s.percent}%)', 'Jam sepi terbaik 08.00-09.00 atau setelah 15.00'),
      (Icons.chat_outlined, 'E-tiket dan invoice dikirim lewat WhatsApp', 'Riwayat dicari dengan nomor WhatsApp di Tiket & Booking'),
      (Icons.notifications_active_outlined, s.quietReminder ? 'Pengingat jam sepi aktif' : 'Pengingat jam sepi nonaktif', 'Atur di menu Profil'),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.forest,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Notifikasi', style: AppTheme.display(18)),
            const SizedBox(height: 8),
            for (final (icon, title, text) in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(radius: 16, backgroundColor: AppColors.leaf.withValues(alpha: .5), child: Icon(icon, size: 15, color: Colors.white)),
                title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                subtitle: Text(text, style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
              ),
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
      (Icons.info_outline, 'Tentang Sumber Sira', AppRoutes.about),
    ];
    return Row(children: [
      for (final (icon, label, route) in items)
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushNamed(context, route),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.leaf.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white(.25)),
                  ),
                  child: Icon(icon, size: 22),
                ),
                const SizedBox(height: 6),
                Text(label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 10)),
              ]),
            ),
          ),
        ),
    ]);
  }

  // Rekomendasi kunjungan: grafik garis jumlah pengunjung per jam (isi menu Live Crowd yang dipindah ke sini).
  Widget _recommendation() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Rekomendasi Kunjungan', style: AppTheme.display(17)),
        const SizedBox(height: 4),
        Text('Prediksi jumlah pengunjung per jam hari ini', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(12, 14, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Pengunjung (orang)', style: TextStyle(fontSize: 10, color: AppColors.white(.7))),
            const SizedBox(height: 6),
            const HourlyCrowdChart(height: 230),
            Row(children: [
              const Expanded(child: CrowdLegend()),
              Text('Jam', style: TextStyle(fontSize: 10, color: AppColors.white(.7))),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          color: AppColors.leaf.withValues(alpha: .2),
          child: const Row(children: [
            CircleAvatar(radius: 16, backgroundColor: AppColors.leaf, child: Icon(Icons.timer_outlined, size: 16, color: Colors.white)),
            SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Waktu terbaik berkunjung', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('08.00-09.00 atau setelah 15.00', style: TextStyle(fontSize: 11)),
              ]),
            ),
          ]),
        ),
      ]);
}

// Banner foto yang bisa digeser kiri-kanan (PageView), tiap foto punya teks sendiri.
// Berganti otomatis setiap 5 detik, titik di bawah menandai foto yang sedang tampil.
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController();
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
    return SizedBox(
      height: 210,
      child: Stack(children: [
        PageView.builder(
          controller: _controller,
          itemCount: DummyData.slides.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) {
            final s = DummyData.slides[i];
            return Stack(fit: StackFit.expand, children: [
              // [P4 Image.asset] Foto dari folder assets yang didaftarkan di pubspec.yaml.
              Image.asset(s.image, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.ink.withValues(alpha: .75), AppColors.ink.withValues(alpha: .15)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.label, style: AppTheme.mono(9)),
                  const SizedBox(height: 8),
                  SizedBox(width: 240, child: Text(s.title, style: AppTheme.display(22))),
                  const Spacer(),
                  Text(s.text, style: const TextStyle(fontSize: 11)),
                ]),
              ),
            ]);
          },
        ),
        Positioned(
          left: 20,
          bottom: 12,
          child: Row(children: [
            for (var i = 0; i < DummyData.slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 5),
                width: i == _page ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(color: i == _page ? Colors.white : AppColors.white(.45), borderRadius: BorderRadius.circular(3)),
              ),
          ]),
        ),
      ]),
    );
  }
}
