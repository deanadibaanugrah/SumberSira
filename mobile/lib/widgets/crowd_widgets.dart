import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/dummy_data.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

// Titik berkedip tanda data live.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.color = AppColors.leaf});

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
        child: Container(width: 9, height: 9, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
      );
}

// Warna tiap tingkat keramaian, sama dengan keterangan grafik: Sepi hijau, Sedang kuning, Ramai coral.
// onDark = dipakai di atas latar hijau tua, hijaunya dibuat lebih muda supaya tetap terlihat.
Color crowdColor(String label, {bool onDark = false}) => switch (label) {
      'Sepi' => onDark ? AppColors.lightLeaf : AppColors.leaf,
      'Ramai' => AppColors.coral,
      _ => AppColors.sun,
    };

// Kartu status keramaian di header Beranda: "Crowd saat ini", tingkat keramaian, persen kapasitas,
// garis kapasitas, dan jumlah orang di dalam (hanya info, tidak bisa diklik).
// ListenableBuilder membangun ulang widget setiap AppState memanggil notifyListeners().
class CrowdPill extends StatelessWidget {
  const CrowdPill({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final color = crowdColor(s.crowdLabel, onDark: true);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.white(.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.white(.16)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              LiveDot(color: color),
              const SizedBox(width: 8),
              Text('Crowd saat ini', style: TextStyle(fontSize: 12.5, color: AppColors.white(.8))),
              const Spacer(),
              Text('${s.inside}/${AppState.capacity} orang', style: TextStyle(fontSize: 12.5, color: AppColors.white(.8))),
            ]),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(s.crowdLabel, style: AppTheme.display(26, color: Colors.white)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${s.percent}% kapasitas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
              ),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: (s.percent / 100).clamp(0, 1).toDouble(), minHeight: 8, backgroundColor: AppColors.white(.14), color: color),
            ),
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

  static const _left = 34.0, _bottom = 24.0, _top = 22.0;
  static const _yTicks = [0, 100, 200, 300];

  // Menulis teks kecil (label sumbu) di kanvas.
  void _text(Canvas canvas, String s, Offset at, {TextAlign align = TextAlign.center, Color color = AppColors.muted, FontWeight weight = FontWeight.w500}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: 10.5, color: color, fontWeight: weight)),
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
      ..color = AppColors.line
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
        Paint()..color = AppColors.mint,
      );
      _text(canvas, 'Sekarang', Offset(x(nowIndex), _top - 14), color: AppColors.forest, weight: FontWeight.w700);
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
          colors: [AppColors.leaf.withValues(alpha: .28), AppColors.leaf.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, _top, size.width, chartH)),
    );
    canvas.drawPath(
      Path()..addPolygon(points, false),
      Paint()
        ..color = AppColors.forest
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Titik berwarna sesuai tingkat keramaian, dan jam di sumbu bawah.
    for (var i = 0; i < data.length; i++) {
      final label = AppState.labelFor((data[i].$2 * 100 / AppState.capacity).round());
      canvas.drawCircle(points[i], 6, Paint()..color = Colors.white);
      canvas.drawCircle(points[i], 4.5, Paint()..color = crowdColor(label));
      _text(canvas, data[i].$1, Offset(x(i), size.height - _bottom / 2), color: i == nowIndex ? AppColors.forest : AppColors.muted);
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
          Container(width: 10, height: 10, decoration: BoxDecoration(color: crowdColor(label), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
    ]);
  }
}

// Label status tiket: Belum masuk (kuning), Di dalam (hijau), atau Keluar (abu-abu).
class TicketStatusChip extends StatelessWidget {
  const TicketStatusChip(this.status, {super.key});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      TicketStatus.inside => (AppColors.pale, AppColors.forest),
      TicketStatus.waiting => (AppColors.sun.withValues(alpha: .2), AppColors.sunDark),
      TicketStatus.out => (AppColors.line, AppColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(status.label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}
