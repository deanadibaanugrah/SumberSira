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

// Warna tiap tingkat keramaian, sama dengan keterangan grafik: Sepi hijau, Sedang putih, Ramai coral.
Color crowdColor(String label) => switch (label) {
      'Sepi' => const Color(0xFF7FD1A8),
      'Ramai' => AppColors.coral,
      _ => Colors.white,
    };

// Pill di Beranda: "Crowd saat ini: Sedang (62%)" dan jumlah orang di dalam (hanya info, tidak bisa diklik).
// ListenableBuilder membangun ulang widget setiap AppState memanggil notifyListeners().
class CrowdPill extends StatelessWidget {
  const CrowdPill({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return GlassCard(
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            LiveDot(color: crowdColor(s.crowdLabel)),
            const SizedBox(width: 8),
            Expanded(child: Text('Crowd saat ini: ${s.crowdLabel} (${s.percent}%)', style: const TextStyle(fontSize: 12))),
            Text('${s.inside}/${AppState.capacity} orang', style: AppTheme.mono(11, color: AppColors.white(.8))),
          ]),
        );
      },
    );
  }
}

// Grafik garis prediksi jumlah pengunjung per jam (Beranda).
// Sumbu bawah = jam (08 sampai 16), sumbu kiri = jumlah pengunjung (0 sampai kapasitas 300).
// Warna titik mengikuti tingkat keramaian, pita terang = jam sekarang.
class HourlyCrowdChart extends StatelessWidget {
  const HourlyCrowdChart({super.key, this.height = 220});

  final double height;

  @override
  Widget build(BuildContext context) {
    final peak = DummyData.hourlyForecast.reduce((a, b) => a.$2 >= b.$2 ? a : b);
    return Semantics(
      label: 'Grafik prediksi pengunjung per jam, paling ramai pukul ${peak.$1}.00 sekitar ${peak.$2} orang',
      // [P3 CustomPaint] Menggambar grafik sendiri dengan Canvas lewat CustomPainter.
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, t, _) => SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _HourlyChartPainter(progress: t, nowHour: DateTime.now().hour)),
        ),
      ),
    );
  }
}

class _HourlyChartPainter extends CustomPainter {
  _HourlyChartPainter({required this.progress, required this.nowHour});

  // 0 sampai 1: garis naik pelan saat grafik pertama tampil.
  final double progress;
  final int nowHour;

  static const _left = 34.0, _bottom = 24.0, _top = 18.0;
  static const _yTicks = [0, 100, 200, 300];

  // Menulis teks kecil (label sumbu) di kanvas.
  void _text(Canvas canvas, String s, Offset at, {TextAlign align = TextAlign.center, Color? color}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: AppTheme.mono(9, color: color ?? AppColors.white(.65))),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) { TextAlign.right => at.dx - tp.width, TextAlign.center => at.dx - tp.width / 2, _ => at.dx };
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final data = DummyData.hourlyForecast;
    final chartW = size.width - _left - 8;
    final chartH = size.height - _bottom - _top;
    final step = chartW / (data.length - 1);
    double x(int i) => _left + i * step;
    double y(int v) => _top + chartH - chartH * v / AppState.capacity * progress;

    // Garis bantu dan angka jumlah pengunjung di sumbu kiri.
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .12)
      ..strokeWidth = 1;
    for (final v in _yTicks) {
      final gy = _top + chartH - chartH * v / AppState.capacity;
      canvas.drawLine(Offset(_left, gy), Offset(size.width - 8, gy), grid);
      _text(canvas, '$v', Offset(_left - 8, gy), align: TextAlign.right);
    }

    // Pita jam sekarang (kalau masih di jam buka).
    final nowIndex = data.indexWhere((d) => int.parse(d.$1) == nowHour);
    if (nowIndex >= 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x(nowIndex) - step / 2, _top - 6, step, chartH + 6), const Radius.circular(8)),
        Paint()..color = Colors.white.withValues(alpha: .08),
      );
      _text(canvas, 'Sekarang', Offset(x(nowIndex), _top - 12), color: Colors.white);
    }

    // Area lembut di bawah garis, lalu garisnya.
    final points = [for (var i = 0; i < data.length; i++) Offset(x(i), y(data[i].$2))];
    final area = Path()..moveTo(points.first.dx, _top + chartH);
    for (final p in points) {
      area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(points.last.dx, _top + chartH)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.leaf.withValues(alpha: .45), AppColors.leaf.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, _top, size.width, chartH)),
    );
    canvas.drawPath(
      Path()..addPolygon(points, false),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Titik berwarna sesuai tingkat keramaian, dan jam di sumbu bawah.
    for (var i = 0; i < data.length; i++) {
      final label = AppState.labelFor((data[i].$2 * 100 / AppState.capacity).round());
      canvas.drawCircle(points[i], 5, Paint()..color = AppColors.ink);
      canvas.drawCircle(points[i], 3.5, Paint()..color = crowdColor(label));
      _text(canvas, data[i].$1, Offset(x(i), size.height - _bottom / 2));
    }
  }

  @override
  bool shouldRepaint(_HourlyChartPainter old) => old.progress != progress || old.nowHour != nowHour;
}

// Keterangan warna grafik: Sepi, Sedang, Ramai.
class CrowdLegend extends StatelessWidget {
  const CrowdLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 16, runSpacing: 6, children: [
      for (final label in ['Sepi', 'Sedang', 'Ramai'])
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(color: crowdColor(label), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10)),
        ]),
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
