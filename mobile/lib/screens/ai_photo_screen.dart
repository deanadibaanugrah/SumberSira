import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';

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
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(title: 'AI Underwater Photo Studio'),
      body: AppBackground(
        child: ResponsiveBody(children: [
          // Hero: foto sebelum dan sesudah.
          if (_compare)
            Row(children: [
              Expanded(child: _photo('Sebelum', _dull)),
              const SizedBox(width: 12),
              Expanded(child: _photo('Sesudah', _enhanced(), badge: true)),
            ])
          else
            _photo('Sesudah', _enhanced(), badge: true),
          GroupedList(top: 20, indent: 16, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
              child: Column(children: [
                Row(children: [
                  const Icon(CupertinoIcons.slider_horizontal_3, size: 20, color: AppColors.leaf),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('Kekuatan enhance', style: AppText.body)),
                  Text('${_strength.round()}%', style: AppText.number(17, color: AppColors.forest)),
                ]),
                // onChanged dijalankan selama Slider digeser; setState() memperbarui foto.
                Slider(
                  value: _strength,
                  max: 100,
                  divisions: 20,
                  label: '${_strength.round()}%',
                  onChanged: (value) => setState(() => _strength = value),
                ),
              ]),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 2, 12, 2),
              value: _compare,
              onChanged: (value) => setState(() => _compare = value),
              secondary: const Icon(CupertinoIcons.square_split_2x1, size: 20, color: AppColors.leaf),
              title: const Text('Bandingkan dengan foto asli', style: AppText.body),
            ),
          ]),
          const SectionTitle('Galeri Komunitas'),
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
          GroupedList(
            header: 'Rencana fitur AI',
            footer: 'Belum diimplementasikan. Tahap berikutnya: model image enhancement bawah air yang dipanggil lewat API.',
            children: [
              for (final (i, step) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 20, child: Text('${i + 1}', style: AppText.number(17, weight: FontWeight.w700, color: AppColors.forest))),
                    const SizedBox(width: 16),
                    Expanded(child: Text(step, style: AppText.subheadline.copyWith(color: AppColors.ink))),
                  ]),
                ),
            ],
          ),
        ]),
      ),
    );
  }

  // [P3 Stack + Positioned] Foto dengan label kaca yang ditumpuk di pojok bawah dan badge di pojok atas.
  Widget _photo(String label, ColorFilter filter, {bool badge = false}) => ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 161 / 210,
          child: Stack(fit: StackFit.expand, children: [
            ColorFiltered(colorFilter: filter, child: Image.asset('assets/images/onboarding-bawah-air.jpg', fit: BoxFit.cover)),
            Positioned(
              left: 10,
              bottom: 10,
              child: Glass(
                radius: 14,
                shadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(label, style: AppText.caption.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
              ),
            ),
            if (badge)
              Positioned(
                right: 8,
                top: 8,
                child: Glass(
                  radius: 14,
                  shadow: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(CupertinoIcons.sparkles, size: 12, color: AppColors.leaf),
                    const SizedBox(width: 4),
                    Text('AI Enhanced', style: AppText.caption.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
          ]),
        ),
      );
}
