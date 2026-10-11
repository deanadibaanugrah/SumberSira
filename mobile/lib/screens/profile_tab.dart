import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Tab Profil: data akun yang sedang login, info wisata, dan tombol keluar.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Keluar: hapus sesi lalu kembali ke Login dan buang semua layar sebelumnya.
  void _logout(BuildContext context) {
    AppState.instance.logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final name = s.userName ?? 'Pengunjung';
    const info = [
      (Icons.schedule, 'Jam buka', 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
      (Icons.confirmation_number_outlined, 'Tiket masuk', 'Rp5.000 per orang (usia 3 tahun ke atas)'),
      (Icons.local_parking, 'Parkir', 'Motor 3rb · Mobil 10rb · Bus 20rb'),
      (Icons.place_outlined, 'Lokasi', 'Desa Putukrejo, Malang'),
    ];
    return ResponsiveBody(children: [
      Text('Profil', style: AppTheme.display(22)),
      const SizedBox(height: 18),
      GlassCard(
        child: Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.leaf,
            child: Text(name.split(' ').map((w) => w[0]).take(2).join(), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(s.userEmail ?? '-', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: [
          for (final (icon, title, text) in info)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 16, backgroundColor: AppColors.leaf.withValues(alpha: .35), child: Icon(icon, size: 15, color: Colors.white)),
              title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              subtitle: Text(text, style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
            ),
        ]),
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          foregroundColor: AppColors.coral,
          side: const BorderSide(color: AppColors.coral),
          shape: const StadiumBorder(),
        ),
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Keluar'),
      ),
    ]);
  }
}
