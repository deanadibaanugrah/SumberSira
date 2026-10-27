import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Rancangan fitur AI (belum diimplementasikan): AI Underwater Photo Studio.
// Tampilan "Sesudah" masih simulasi dengan filter warna; model AI dikerjakan pada tahap berikutnya.
class AiPhotoScreen extends StatefulWidget {
  const AiPhotoScreen({super.key});

  @override
  State<AiPhotoScreen> createState() => _AiPhotoScreenState();
}

class _AiPhotoScreenState extends State<AiPhotoScreen> {
  // [P4 Slider] Kekuatan enhance 0 sampai 100 (nilai double).
  double _strength = 60;
  // [P4 Switch] Tampilkan perbandingan dengan foto asli (true) atau hanya hasilnya (false).
  bool _compare = true;

  static const _repo = 'https://raw.githubusercontent.com/deanadibaanugrah/SumberSira/main/mobile/assets/images';

  // Filter warna foto asli yang kusam (sebelum di-enhance).
  static const _dull = ColorFilter.matrix([
    .45, .3, .1, 0, 0, //
    .2, .55, .15, 0, 0,
    .2, .3, .45, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  // Filter warna hasil: makin besar nilai Slider, warna makin cerah dan jernih (simulasi hasil AI).
  ColorFilter _enhanced() {
    final k = _strength / 100;
    return ColorFilter.matrix([
      1 + .3 * k, 0, 0, 0, -12 * k, //
      0, 1 + .2 * k, 0, 0, -6 * k,
      0, 0, 1 + .15 * k, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Pengunjung mengunggah foto bawah air dari galeri HP.',
      'Model AI memperbaiki warna yang kebiruan, mengurangi kabut air, dan menajamkan detail.',
      'Hasil tampil berdampingan dengan foto asli dan bisa dibagikan ke Galeri Komunitas.',
    ];
    return Scaffold(
      appBar: const PageAppBar(title: 'AI Underwater Photo Studio'),
      body: AppBackground(
        child: ResponsiveBody(children: [
          if (_compare)
            Row(children: [
              Expanded(child: _photo('Sebelum', _dull)),
              const SizedBox(width: 12),
              Expanded(child: _photo('Sesudah', _enhanced(), badge: true)),
            ])
          else
            _photo('Sesudah', _enhanced(), badge: true),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.tune_rounded, size: 19, color: AppColors.leaf),
                const SizedBox(width: 8),
                const Text('Kekuatan enhance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)),
                  child: Text('${_strength.round()}%', style: AppTheme.price(13)),
                ),
              ]),
              // onChanged dijalankan selama Slider digeser; setState() memperbarui foto.
              Slider(
                value: _strength,
                max: 100,
                divisions: 20,
                label: '${_strength.round()}%',
                onChanged: (value) => setState(() => _strength = value),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _compare,
                onChanged: (value) => setState(() => _compare = value),
                title: const Text('Bandingkan dengan foto asli', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const SectionTitle('Galeri Komunitas', top: 24),
          Row(children: [
            for (var i = 1; i <= 3; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 1 ? 0 : 6, right: i == 3 ? 0 : 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      // [P4 Image.network] Foto diambil langsung dari internet (repo GitHub proyek).
                      // Kalau gagal dimuat (mis. tanpa internet), errorBuilder memakai foto lokal (Image.asset).
                      child: Image.network(
                        '$_repo/komunitas-$i.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset('assets/images/komunitas-$i.jpg', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 18),
          AppCard(
            color: AppColors.mint,
            borderColor: AppColors.pale,
            shadow: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const IconBadge(Icons.auto_awesome, size: 38, background: Colors.white, color: AppColors.leaf),
                const SizedBox(width: 10),
                Text('Rencana Fitur AI', style: AppTheme.display(18)),
              ]),
              const SizedBox(height: 14),
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(radius: 12, backgroundColor: AppColors.forest, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(steps[i], style: const TextStyle(fontSize: 13.5, height: 1.4))),
                  ]),
                ),
              const Text('Belum diimplementasikan. Tahap berikutnya: model image enhancement bawah air yang dipanggil lewat API.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
            ]),
          ),
        ]),
      ),
    );
  }

  // [P3 Stack + Positioned] Foto dengan label yang ditumpuk di pojok bawah dan badge di pojok atas.
  Widget _photo(String label, ColorFilter filter, {bool badge = false}) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 161 / 200,
          child: Stack(fit: StackFit.expand, children: [
            ColorFiltered(colorFilter: filter, child: Image.asset('assets/images/onboarding-bawah-air.jpg', fit: BoxFit.cover)),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: .65), borderRadius: BorderRadius.circular(12)),
                child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (badge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Text('AI Enhanced', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.forest)),
                ),
              ),
          ]),
        ),
      );
}
