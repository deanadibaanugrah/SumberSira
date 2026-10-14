import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/logo_mark.dart';

// Layar Tentang Sumber Sira: tampil setelah Splash saat aplikasi pertama kali dibuka,
// dan bisa dibuka lagi dari menu samping. Lanjut = ke Onboarding, Lewati = langsung ke Beranda.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Lewati perkenalan: tandai onboarding selesai lalu buka Beranda dan hapus riwayat layar sebelumnya.
  void _skip(BuildContext context) {
    AppState.instance.finishOnboarding();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    const features = [
      (Icons.water_drop, 'Air jernih'),
      (Icons.set_meal_outlined, 'Ikan wader'),
      (Icons.pool, 'Kolam anak'),
      (Icons.cottage_outlined, 'Gazebo'),
    ];
    const info = [
      (Icons.schedule, 'Jam buka', 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
      (Icons.confirmation_number_outlined, 'Tiket masuk', 'Rp5.000 per orang (usia 3 tahun ke atas)'),
      (Icons.directions_car_outlined, 'Parkir', 'Motor 3rb · Mobil 10rb · Bus 20rb'),
      (Icons.account_balance_wallet_outlined, 'Pembayaran', 'Tunai & QRIS'),
    ];
    return Scaffold(
      body: AppBackground(
        child: ResponsiveBody(children: [
          Row(children: [
            const LogoMark(size: 32, ring: true),
            const SizedBox(width: 10),
            Expanded(child: Text('Sumber Sira', style: AppTheme.display(18))),
            TextButton(onPressed: () => _skip(context), child: Text('Lewati', style: TextStyle(color: AppColors.white(.8)))),
          ]),
          const SizedBox(height: 10),
          // [P3 Stack + Positioned] Label lokasi ditumpuk di atas foto.
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 200,
              child: Stack(fit: StackFit.expand, children: [
                Image.asset('assets/images/sawah-sumber-sira.jpg', fit: BoxFit.cover),
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: .55), borderRadius: BorderRadius.circular(14)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.place, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Desa Putukrejo, Malang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Text('Tentang Sumber Sira', style: AppTheme.display(26)),
          const SizedBox(height: 6),
          Text('Kolam mata air alami yang jernih dan sejuk, seru buat berenang, main air, dan foto bareng keluarga.',
              style: TextStyle(fontSize: 13, color: AppColors.white(.85), height: 1.4)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.white(.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.white(.25)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.groups_outlined, size: 15),
                SizedBox(width: 6),
                Text('Dikelola masyarakat Desa Putukrejo', style: TextStyle(fontSize: 11)),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Row(children: [
            for (final (icon, label) in features)
              Expanded(
                child: Column(children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: .7),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white(.3)),
                    ),
                    child: Icon(icon, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(label, style: const TextStyle(fontSize: 11)),
                ]),
              ),
          ]),
          const SizedBox(height: 18),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(children: [
              for (final (i, (icon, title, text)) in info.indexed) ...[
                if (i > 0) Divider(height: 1, color: AppColors.white(.15)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 16, backgroundColor: AppColors.leaf.withValues(alpha: .35), child: Icon(icon, size: 15, color: Colors.white)),
                  title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  subtitle: Text(text, style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 18),
          // [P5 Navigator.pushReplacementNamed] Ganti layar ini dengan Onboarding (tidak bisa kembali ke sini).
          PrimaryButton(label: 'Lanjut', onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.onboarding)),
        ]),
      ),
    );
  }
}
