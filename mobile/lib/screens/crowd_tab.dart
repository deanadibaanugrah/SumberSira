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
      Text('Live Crowd Tracker (AI)', style: AppTheme.display(22)),
      const SizedBox(height: 16),
      const CrowdStatusCard(),
      const SizedBox(height: 16),
      const GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Prediksi Keramaian Hari Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          SizedBox(height: 14),
          ForecastLine(height: 140),
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
      const SizedBox(height: 14),
      const CrowdLegend(),
    ]);
  }
}
