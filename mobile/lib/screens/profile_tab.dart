import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Tab Profil: ringkasan pengunjung, pengaturan pengingat, info wisata, dan tautan ke peta.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const _maps = 'https://www.google.com/maps/search/?api=1&query=Sumber+Sira+Putukrejo+Malang';
  static const _route = 'https://www.google.com/maps/dir/?api=1&destination=Sumber+Sira+Putukrejo+Malang';

  // [P6 Plugin url_launcher] Meminta sistem membuka tautan di aplikasi lain (Google Maps / browser).
  Future<void> _open(BuildContext context, String url) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tautan tidak bisa dibuka di perangkat ini.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const info = [
      (Icons.schedule, 'Jam buka', 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
      (Icons.confirmation_number_outlined, 'Tiket masuk', 'Rp5.000 per orang (usia 3 tahun ke atas)'),
      (Icons.local_parking, 'Parkir', 'Motor 3rb · Mobil 10rb · Bus 20rb'),
      (Icons.payments_outlined, 'Pembayaran', 'Tunai & QRIS'),
      (Icons.place_outlined, 'Lokasi', 'Desa Putukrejo, Malang'),
    ];
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return ResponsiveBody(children: [
          Text('Profil', style: AppTheme.display(22)),
          const SizedBox(height: 18),
          GlassCard(
            child: Row(children: [
              const CircleAvatar(radius: 26, backgroundColor: AppColors.leaf, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pengunjung', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('${s.myTickets.length} tiket dibeli hari ini', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            // [P4 Switch + P6 shared_preferences] Pilihan ON/OFF yang tersimpan di perangkat.
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: s.quietReminder,
              onChanged: s.setQuietReminder,
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Ingatkan saat sepi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              subtitle: Text(s.quietReminder ? 'Aktif, tersimpan di perangkat' : 'Nonaktif', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
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
          const SizedBox(height: 16),
          PrimaryButton(label: 'Buka Lokasi di Google Maps', icon: Icons.map_outlined, height: 46, onPressed: () => _open(context, _maps)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              foregroundColor: Colors.white,
              side: BorderSide(color: AppColors.white(.3)),
              shape: const StadiumBorder(),
            ),
            onPressed: () => _open(context, _route),
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: const Text('Petunjuk Arah'),
          ),
        ]);
      },
    );
  }
}
