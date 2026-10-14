import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';
import '../widgets/logo_mark.dart';

// Tab Beranda: header, banner foto, status keramaian, tombol beli tiket, menu cepat,
// rekomendasi jam kunjungan, dan promo rencana fitur AI.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBody(children: [
      _header(context),
      const SizedBox(height: 18),
      _hero(),
      const SizedBox(height: 14),
      CrowdPill(onTap: () => onOpenTab(2)),
      const SizedBox(height: 10),
      _buyTicketCard(context),
      const SizedBox(height: 16),
      _quickMenu(context),
      const SizedBox(height: 26),
      Text('Rekomendasi Kunjungan', style: AppTheme.display(16)),
      const SizedBox(height: 10),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const ForecastBars(height: 70),
          const SizedBox(height: 8),
          Text('Jam sepi terbaik: 08.00-09.00', style: TextStyle(fontSize: 11, color: AppColors.white(.9))),
        ]),
      ),
      const SizedBox(height: 16),
      GlassCard(
        onTap: () => Navigator.pushNamed(context, AppRoutes.aiPhoto),
        child: Row(children: [
          ClipOval(child: Image.asset('assets/images/onboarding-bawah-air.jpg', width: 44, height: 44, fit: BoxFit.cover)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('AI Underwater Photo Studio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Belum ada fotografer? Coba enhance otomatis.', style: TextStyle(fontSize: 10, color: AppColors.white(.65))),
              const SizedBox(height: 6),
              const Text('Lihat rencana fitur AI ->', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ),
    ]);
  }

  Widget _header(BuildContext context) => Row(children: [
        // [P5 Drawer] Tombol menu membuka menu samping milik Scaffold induk (MainShell).
        IconButton(tooltip: 'Menu', icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        const LogoMark(size: 32, ring: true),
        const SizedBox(width: 10),
        Expanded(child: Text('Sumber Sira', style: AppTheme.display(20))),
        // Lonceng notifikasi dengan titik coral, sama dengan desain Figma.
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () => _showNotifications(context),
          icon: const Badge(smallSize: 8, backgroundColor: AppColors.coral, child: Icon(Icons.notifications_none)),
        ),
      ]);

  // [P5 Modal Bottom Sheet] Lembar notifikasi yang muncul dari bawah layar.
  void _showNotifications(BuildContext context) {
    final s = AppState.instance;
    final items = [
      (Icons.bar_chart, 'Crowd sekarang ${s.crowdLabel} (${s.percent}%)', 'Jam sepi terbaik 08.00-09.00 atau setelah 15.00'),
      (Icons.chat_outlined, 'E-tiket dikirim lewat WhatsApp', 'Riwayat tiket dicari dengan nomor WhatsApp di Tiket Saya'),
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

  Widget _hero() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 170,
          child: Stack(fit: StackFit.expand, children: [
            // [P4 Image.asset] Foto dari folder assets yang didaftarkan di pubspec.yaml.
            Image.asset('assets/images/hero-sawah.jpg', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.ink.withValues(alpha: .7), AppColors.ink.withValues(alpha: .25)]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SUMBER SIRA', style: AppTheme.mono(9)),
                const SizedBox(height: 8),
                Text('Kunjungan Jernih\nTanpa Antre', style: AppTheme.display(22)),
                const Spacer(),
                const Text('Booking wahana, cek keramaian, & foto AI dalam satu app', style: TextStyle(fontSize: 11)),
              ]),
            ),
          ]),
        ),
      );

  Widget _buyTicketCard(BuildContext context) => GlassCard(
        color: AppColors.leaf.withValues(alpha: .45),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => Navigator.pushNamed(context, AppRoutes.buyTicket),
        child: Row(children: [
          const CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.confirmation_number_outlined, color: AppColors.forest, size: 20)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Beli Tiket Masuk Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('Rp5.000/orang · tunjukkan QR di pintu, tanpa antre', style: TextStyle(fontSize: 10)),
            ]),
          ),
          const Icon(Icons.arrow_forward, size: 18),
        ]),
      );

  // [P3 Row + Expanded] Empat menu cepat dibagi rata, lebarnya menyesuaikan layar.
  Widget _quickMenu(BuildContext context) {
    final items = [
      (Icons.calendar_month_outlined, 'Sewa & Booking', () => Navigator.pushNamed(context, AppRoutes.booking)),
      (Icons.bar_chart, 'Live Crowd', () => onOpenTab(2)),
      (Icons.photo_camera_outlined, 'AI Photo Studio', () => Navigator.pushNamed(context, AppRoutes.aiPhoto)),
      (Icons.confirmation_number_outlined, 'Tiket Saya', () => onOpenTab(1)),
    ];
    return Row(children: [
      for (final (icon, label, onTap) in items)
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
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
    ]);
  }
}
