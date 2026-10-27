import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/launcher.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Tab Profil: ringkasan pengunjung, pengaturan pengingat, info wisata, dan tautan ke peta.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const _maps = 'https://www.google.com/maps/search/?api=1&query=Sumber+Sira+Putukrejo+Malang';
  static const _route = 'https://www.google.com/maps/dir/?api=1&destination=Sumber+Sira+Putukrejo+Malang';

  @override
  Widget build(BuildContext context) {
    const info = [
      (Icons.schedule_rounded, 'Jam buka', 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
      (Icons.confirmation_number_outlined, 'Tiket masuk', 'Rp5.000 per orang (usia 3 tahun ke atas)'),
      (Icons.local_parking_rounded, 'Parkir', 'Motor 3rb · Mobil 10rb · Bus 20rb'),
      (Icons.payments_outlined, 'Pembayaran', 'Tunai & QRIS'),
      (Icons.place_outlined, 'Lokasi', 'Desa Putukrejo, Malang'),
    ];
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return TabBody(
          header: TabHeader(
            title: 'Profil',
            child: Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.white(.15),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pengunjung', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 3),
                  // Tanpa login: identitas pengunjung cukup nomor WhatsApp terakhir yang dipakai.
                  Text(s.savedWhatsapp.isEmpty ? 'Belum ada nomor WhatsApp tersimpan' : 'WhatsApp ${s.savedWhatsapp}',
                      style: TextStyle(fontSize: 13, color: AppColors.white(.85))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.white(.14), borderRadius: BorderRadius.circular(14)),
                    child: Text('${s.myTickets.length} tiket dibeli dari perangkat ini',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ]),
              ),
            ]),
          ),
          children: [
            const SectionTitle('Pengaturan', top: 4),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
              // [P4 Switch + P6 shared_preferences] Pilihan ON/OFF yang tersimpan di perangkat.
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: s.quietReminder,
                onChanged: s.setQuietReminder,
                secondary: const IconBadge(Icons.notifications_active_outlined, size: 40),
                title: const Text('Ingatkan saat sepi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(s.quietReminder ? 'Aktif, tersimpan di perangkat' : 'Nonaktif', style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
              ),
            ),
            const SectionTitle('Info Kunjungan'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(children: [
                for (final (i, (icon, title, text)) in info.indexed) ...[
                  if (i > 0) const Divider(),
                  InfoRow(icon: icon, title: title, text: text),
                ],
              ]),
            ),
            const SectionTitle('Lokasi & Arah'),
            // Kartu lokasi: foto Sumber Sira lalu tombol ke Google Maps.
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(
                  height: 130,
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset('assets/images/hero-sawah.jpg', fit: BoxFit.cover),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.place_rounded, size: 15, color: AppColors.coral),
                          SizedBox(width: 4),
                          Text('Desa Putukrejo, Malang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    PrimaryButton(label: 'Buka Lokasi di Google Maps', icon: Icons.map_outlined, height: 50, onPressed: () => bukaTautan(context, _maps)),
                    const SizedBox(height: 10),
                    OutlineAction(label: 'Petunjuk Arah', icon: Icons.directions_outlined, onPressed: () => bukaTautan(context, _route)),
                  ]),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}
