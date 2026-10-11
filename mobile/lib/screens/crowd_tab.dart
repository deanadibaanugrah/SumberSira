import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';

// Tab Live Crowd: status keramaian sekarang (dari tiket yang discan) dan prediksi per jam.
class CrowdTab extends StatelessWidget {
  const CrowdTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBody(children: [
      Text('Live Crowd Tracker', style: AppTheme.display(22)),
      const SizedBox(height: 16),
      const CrowdStatusCard(),
      const SizedBox(height: 16),
      GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Prediksi Keramaian Hari Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          const ForecastBars(height: 120),
          const SizedBox(height: 10),
          Row(children: [
            for (final (label, color) in [('Sepi', AppColors.leaf), ('Ramai', Colors.white)]) ...[
              Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 10)),
              const SizedBox(width: 16),
            ],
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      GlassCard(
        color: AppColors.leaf.withValues(alpha: .2),
        child: const Row(children: [
          CircleAvatar(radius: 16, backgroundColor: AppColors.leaf, child: Icon(Icons.timer_outlined, size: 16, color: Colors.white)),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Waktu terbaik berkunjung', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('08.00-09.00 atau setelah 15.00', style: TextStyle(fontSize: 11)),
            ]),
          ),
        ]),
      ),
    ]);
  }
}
