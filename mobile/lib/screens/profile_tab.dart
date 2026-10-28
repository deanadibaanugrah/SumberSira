import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/launcher.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';

// Tab Profil: identitas pengunjung (tanpa login), pengaturan pengingat, info wisata, dan tautan ke peta.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const _maps = 'https://www.google.com/maps/search/?api=1&query=Sumber+Sira+Putukrejo+Malang';
  static const _route = 'https://www.google.com/maps/dir/?api=1&destination=Sumber+Sira+Putukrejo+Malang';

  @override
  Widget build(BuildContext context) {
    const info = [
      (CupertinoIcons.clock, 'Jam buka', 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
      (CupertinoIcons.ticket, 'Tiket masuk', 'Rp5.000 per orang (usia 3 tahun ke atas)'),
      (CupertinoIcons.car_detailed, 'Parkir', 'Motor 3rb · Mobil 10rb · Bus 20rb'),
      (CupertinoIcons.creditcard, 'Pembayaran', 'Tunai & QRIS'),
      (CupertinoIcons.location_solid, 'Lokasi', 'Desa Putukrejo, Malang'),
    ];
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return TabPage(
          title: 'Profil',
          header: TabHeader(
            title: 'Profil',
            child: Row(children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: AppColors.kaca, shape: BoxShape.circle, border: Border.all(color: AppColors.kaca)),
                child: const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pengunjung', style: AppText.headline.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  // Tanpa login: identitas pengunjung cukup nomor WhatsApp terakhir yang dipakai.
                  Text(s.savedWhatsapp.isEmpty ? 'Belum ada nomor WhatsApp tersimpan' : 'WhatsApp ${s.savedWhatsapp}',
                      style: AppText.footnote.copyWith(color: AppColors.putih72)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.kaca, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.kaca)),
                    child: Text('${s.myTickets.length} tiket dibeli dari perangkat ini', style: AppText.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ]),
          ),
          children: [
            GroupedList(header: 'Pengaturan', top: 20, children: [
              // [P4 Switch + P6 shared_preferences] Pilihan ON/OFF yang tersimpan di perangkat.
              SwitchListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 2, 12, 2),
                value: s.quietReminder,
                onChanged: s.setQuietReminder,
                secondary: const Icon(CupertinoIcons.bell, color: AppColors.leaf, size: 20),
                title: const Text('Ingatkan saat sepi', style: AppText.body),
                subtitle: Text(s.quietReminder ? 'Aktif, tersimpan di perangkat' : 'Nonaktif', style: AppText.footnote),
              ),
            ]),
            GroupedList(header: 'Info kunjungan', children: [
              for (final (icon, title, text) in info) ListRow(icon: icon, title: title, subtitle: text),
            ]),
            const SectionTitle('Lokasi & Arah'),
            // Kartu lokasi: foto Sumber Sira lalu tombol ke Google Maps.
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpace.radius)),
                  child: SizedBox(
                    height: 160,
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset('assets/images/hero-sawah.jpg', fit: BoxFit.cover),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Glass(
                          radius: 16,
                          shadow: false,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(CupertinoIcons.location_solid, size: 15, color: AppColors.leaf),
                            const SizedBox(width: 5),
                            Text('Desa Putukrejo, Malang', style: AppText.footnote.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.card),
                  child: Column(children: [
                    PrimaryButton(label: 'Buka Lokasi di Google Maps', icon: CupertinoIcons.map, onPressed: () => bukaTautan(context, _maps)),
                    const SizedBox(height: 10),
                    TintedButton(label: 'Petunjuk Arah', icon: CupertinoIcons.arrow_up_right, onPressed: () => bukaTautan(context, _route)),
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
