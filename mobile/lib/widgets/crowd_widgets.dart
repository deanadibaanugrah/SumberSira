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

// Grafik garis prediksi keramaian per jam (layar Live Crowd), sama dengan desain Figma:
// garis putih dengan titik, dan pita terang di jam paling ramai.
class ForecastLine extends StatelessWidget {
  const ForecastLine({super.key, this.height = 150});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // [P3 CustomPaint] Menggambar grafik sendiri dengan Canvas lewat CustomPainter.
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (_, t, _) => SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: _ForecastPainter(t))),
      ),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (final (hour, _) in DummyData.forecast) Text(hour, style: AppTheme.mono(9, color: AppColors.white(.7))),
      ]),
    ]);
  }
}

class _ForecastPainter extends CustomPainter {
  _ForecastPainter(this.progress);

  // 0 sampai 1: tinggi garis naik pelan saat layar dibuka.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final data = DummyData.forecast;
    final step = size.width / (data.length - 1);
    final points = [
      for (var i = 0; i < data.length; i++) Offset(i * step, size.height - 8 - (size.height - 16) * data[i].$2 / 100 * progress),
    ];
    // Pita jam paling ramai, selebar satu jarak antar titik di sekitar puncak.
    final peak = data.indexWhere((d) => d.$2 == data.map((e) => e.$2).reduce((a, b) => a > b ? a : b));
    canvas.drawRect(
      Rect.fromLTWH(points[peak].dx - step / 2, 0, step, size.height),
      Paint()..color = Colors.white.withValues(alpha: .1),
    );
    // Garis bantu horizontal tipis.
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .12)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final line = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()..addPolygon(points, false), line);
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_ForecastPainter old) => old.progress != progress;
}

// Keterangan warna grafik: Sepi, Sedang, Ramai.
class CrowdLegend extends StatelessWidget {
  const CrowdLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final (label, color) in [('Sepi', AppColors.leaf), ('Sedang', Colors.white), ('Ramai', AppColors.coral)]) ...[
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 16),
      ],
    ]);
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
