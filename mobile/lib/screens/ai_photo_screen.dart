import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Rancangan fitur AI (belum diimplementasikan): AI Underwater Photo Studio.
// Tampilan "Sesudah" masih simulasi dengan filter warna; model AI dikerjakan pada tahap berikutnya.
class AiPhotoScreen extends StatelessWidget {
  const AiPhotoScreen({super.key});

  // Filter warna: foto bawah air yang kusam (sebelum) dan yang lebih jernih (simulasi sesudah).
  static const _dull = ColorFilter.matrix([
    .45, .3, .1, 0, 0, //
    .2, .55, .15, 0, 0,
    .2, .3, .45, 0, 0,
    0, 0, 0, 1, 0,
  ]);
  static const _vivid = ColorFilter.matrix([
    1.25, 0, 0, 0, -10, //
    0, 1.15, 0, 0, -5,
    0, 0, 1.1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Pengunjung mengunggah foto bawah air dari galeri HP.',
      'Model AI memperbaiki warna yang kebiruan, mengurangi kabut air, dan menajamkan detail.',
      'Hasil tampil berdampingan dengan foto asli dan bisa disimpan atau dibagikan ke Galeri Komunitas.',
    ];
    return Scaffold(
      body: AppBackground(
        child: ResponsiveBody(children: [
          const PageHeader(title: 'AI Underwater Photo Studio'),
          Row(children: [
            Expanded(child: _photo('Sebelum', _dull)),
            const SizedBox(width: 12),
            Expanded(child: _photo('Sesudah', _vivid, badge: true)),
          ]),
          const SizedBox(height: 16),
          GlassCard(
            color: AppColors.leaf.withValues(alpha: .2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.auto_awesome, size: 18),
                const SizedBox(width: 8),
                Text('Rencana Fitur AI', style: AppTheme.display(16)),
              ]),
              const SizedBox(height: 10),
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${i + 1}.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.leaf)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(steps[i], style: const TextStyle(fontSize: 12))),
                  ]),
                ),
              const SizedBox(height: 4),
              Text('Belum diimplementasikan. Tahap berikutnya: model image enhancement bawah air yang dipanggil lewat API.',
                  style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
            ]),
          ),
        ]),
      ),
    );
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: .6), borderRadius: BorderRadius.circular(12)),
                child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ),
            if (badge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Text('AI Enhanced', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.forest)),
                ),
              ),
          ]),
        ),
      );
}
