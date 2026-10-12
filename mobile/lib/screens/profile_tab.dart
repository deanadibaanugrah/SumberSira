import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Tab Profil: ringkasan pengunjung (tanpa login) dan info penting wisata Sumber Sira.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    const info = [
      (Icons.schedule, 'Jam buka', 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
      (Icons.confirmation_number_outlined, 'Tiket masuk', 'Rp5.000 per orang (usia 3 tahun ke atas)'),
      (Icons.local_parking, 'Parkir', 'Motor 3rb · Mobil 10rb · Bus 20rb'),
      (Icons.payments_outlined, 'Pembayaran', 'Tunai & QRIS'),
      (Icons.place_outlined, 'Lokasi', 'Desa Putukrejo, Malang'),
    ];
    return ResponsiveBody(children: [
      Text('Profil', style: AppTheme.display(22)),
      const SizedBox(height: 18),
      ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) => GlassCard(
          child: Row(children: [
            const CircleAvatar(radius: 26, backgroundColor: AppColors.leaf, child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Pengunjung', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('${AppState.instance.myTickets.length} tiket dibeli hari ini', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
              ]),
            ),
          ]),
        ),
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
    ]);
  }
}
