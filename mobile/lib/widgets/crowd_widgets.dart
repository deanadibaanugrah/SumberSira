import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/dummy_data.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import 'common.dart';

// Titik hijau berkedip tanda data live.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.color = Colors.white});

  final Color color;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900), lowerBound: .35)..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _controller,
        child: Container(width: 8, height: 8, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
      );
}

// Pill di Home: "Crowd saat ini: Sedang". Angkanya ikut berubah saat ada tiket yang discan.
// ListenableBuilder membangun ulang widget setiap AppState memanggil notifyListeners().
class CrowdPill extends StatelessWidget {
  const CrowdPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => GlassCard(
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: onTap,
        child: Row(children: [
          const LiveDot(),
          const SizedBox(width: 8),
          Expanded(child: Text('Crowd saat ini: ${AppState.instance.crowdLabel}', style: const TextStyle(fontSize: 12))),
          const Text('Lihat prediksi >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// Kartu status keramaian di layar Live Crowd: persen, label, batang kapasitas, jumlah orang.
class CrowdStatusCard extends StatelessWidget {
  const CrowdStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final busy = s.crowdLabel == 'Ramai';
        return GlassCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const LiveDot(color: AppColors.leaf),
              const SizedBox(width: 8),
              Text('Status Saat Ini', style: TextStyle(fontSize: 12, color: AppColors.white(.75))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: Text('${s.percent}%', style: AppTheme.display(38))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(color: busy ? AppColors.coral : Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Text(s.crowdLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: busy ? Colors.white : AppColors.forest)),
              ),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: s.percent / 100,
                minHeight: 12,
                backgroundColor: AppColors.white(.15),
                color: busy ? AppColors.coral : AppColors.white(.9),
              ),
            ),
            const SizedBox(height: 10),
            Text('${s.inside} orang di dalam dari kapasitas ${AppState.capacity}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Dihitung dari tiket online yang sudah discan di pintu masuk',
                style: TextStyle(fontSize: 10, color: AppColors.white(.65))),
          ]),
        );
      },
    );
  }
}

// Grafik batang prediksi keramaian per jam. Batang paling ramai berwarna putih.
class ForecastBars extends StatelessWidget {
  const ForecastBars({super.key, this.height = 80});

  final double height;

  @override
  Widget build(BuildContext context) {
    final busiest = DummyData.forecast.map((d) => d.$2).reduce((a, b) => a > b ? a : b);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (hour, value) in DummyData.forecast)
          Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 18 + value * (height - 18) / 100),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, h, _) => Container(
                width: 24,
                height: h,
                decoration: BoxDecoration(
                  color: value == busiest ? AppColors.white(.9) : AppColors.leaf.withValues(alpha: .7),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(hour, style: AppTheme.mono(9, color: AppColors.white(.7))),
          ]),
      ],
    );
  }
}

// Label status tiket: Belum masuk, Di dalam, atau Keluar.
class TicketStatusChip extends StatelessWidget {
  const TicketStatusChip(this.status, {super.key});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final bg = switch (status) {
      TicketStatus.inside => AppColors.leaf,
      TicketStatus.waiting => AppColors.white(.15),
      TicketStatus.out => AppColors.white(.1),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
