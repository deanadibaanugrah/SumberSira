import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/dummy_data.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'glass.dart';

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
  Widget build(BuildContext context) => FadeTransition(opacity: _controller, child: StatusDot(widget.color, size: 9));
}

// Warna tiap tingkat keramaian sesuai palet: Sepi Hijau Daun, Sedang Putih, Ramai Coral.
Color crowdColor(String label) => switch (label) {
      'Sepi' => AppColors.leaf,
      'Ramai' => AppColors.coral,
      _ => Colors.white,
    };

// Warna batang grafik di kartu putih: Sedang memakai Hijau Daun 30% (track grafik) supaya tetap terlihat.
Color crowdBarColor(String label) => switch (label) {
      'Sepi' => AppColors.leaf,
      'Ramai' => AppColors.coral,
      _ => AppColors.leaf30,
    };

// Hero Beranda: kartu kaca di header gelap berisi persen kapasitas (angka besar), tingkat keramaian,
// jumlah orang di dalam, dan garis kapasitas. Hanya info, tidak bisa diketuk.
// ListenableBuilder membangun ulang widget setiap AppState memanggil notifyListeners().
class CrowdHero extends StatelessWidget {
  const CrowdHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final color = crowdColor(s.crowdLabel);
        return Glass(
          tone: GlassTone.dark,
          radius: 24,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              LiveDot(color: color),
              const SizedBox(width: 8),
              Text('Crowd saat ini', style: AppText.footnote.copyWith(color: AppColors.putih72)),
              const Spacer(),
              Text('${s.inside}/${AppState.capacity} orang', style: AppText.number(13, weight: FontWeight.w500, color: AppColors.putih72)),
            ]),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${s.percent}%', style: AppText.hero(52, color: Colors.white)),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  StatusChip(label: s.crowdLabel, dot: color, onDark: true),
                  const SizedBox(height: 4),
                  Text('kapasitas terisi', style: AppText.footnote.copyWith(color: AppColors.putih72)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: (s.percent / 100).clamp(0, 1).toDouble(), minHeight: 8, backgroundColor: AppColors.kaca, color: color),
            ),
          ]),
        );
      },
    );
  }
}

// Grafik batang prediksi jumlah pengunjung per jam (Beranda).
// Sumbu bawah = jam (08 sampai 16), sumbu kiri = jumlah pengunjung (0 sampai kapasitas 300).
// Warna batang mengikuti tingkat keramaian; batang jam sekarang disorot Hijau Tua.
class HourlyCrowdChart extends StatelessWidget {
  const HourlyCrowdChart({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    final peak = DummyData.hourlyForecast.reduce((a, b) => a.$2 >= b.$2 ? a : b);
    return Semantics(
      label: 'Grafik prediksi pengunjung per jam, paling ramai pukul ${peak.$1}.00 sekitar ${peak.$2} orang',
      // [P3 CustomPaint] Menggambar grafik sendiri dengan Canvas lewat CustomPainter.
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 800),
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

  // 0 sampai 1: batang tumbuh pelan saat grafik pertama tampil.
  final double progress;
  final int nowHour;

  static const _left = 30.0, _bottom = 22.0, _top = 22.0;
  static const _yTicks = [0, 100, 200, 300];

  // Menulis teks kecil (label sumbu) di kanvas.
  void _text(Canvas canvas, String s, Offset at, {TextAlign align = TextAlign.center, Color color = AppColors.abu, FontWeight weight = FontWeight.w500}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: AppText.number(11, weight: weight, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) { TextAlign.right => at.dx - tp.width, TextAlign.center => at.dx - tp.width / 2, _ => at.dx };
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final data = DummyData.hourlyForecast;
    final chartW = size.width - _left;
    final chartH = size.height - _bottom - _top;
    final step = chartW / data.length;
    final barW = step * .58;
    double cx(int i) => _left + step * (i + .5);

    // Garis bantu dan angka jumlah pengunjung di sumbu kiri.
    final grid = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    for (final v in _yTicks) {
      final gy = _top + chartH - chartH * v / AppState.capacity;
      canvas.drawLine(Offset(_left, gy), Offset(size.width, gy), grid);
      _text(canvas, '$v', Offset(_left - 6, gy), align: TextAlign.right);
    }

    final nowIndex = data.indexWhere((d) => int.parse(d.$1) == nowHour);
    for (var i = 0; i < data.length; i++) {
      final label = AppState.labelFor((data[i].$2 * 100 / AppState.capacity).round());
      final h = chartH * data[i].$2 / AppState.capacity * progress;
      final rect = Rect.fromLTWH(cx(i) - barW / 2, _top + chartH - h, barW, h);
      final isNow = i == nowIndex;
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: Radius.circular(barW / 2), topRight: Radius.circular(barW / 2), bottomLeft: const Radius.circular(3), bottomRight: const Radius.circular(3)),
        Paint()..color = isNow ? AppColors.forest : crowdBarColor(label),
      );
      if (isNow) _text(canvas, 'Sekarang', Offset(cx(i), _top + chartH - h - 11), color: AppColors.forest, weight: FontWeight.w700);
      _text(canvas, data[i].$1, Offset(cx(i), size.height - _bottom / 2), color: isNow ? AppColors.forest : AppColors.abu, weight: isNow ? FontWeight.w700 : FontWeight.w500);
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
          StatusDot(crowdBarColor(label), size: 10),
          const SizedBox(width: 6),
          Text(label, style: AppText.footnote),
        ]),
    ]);
  }
}

// Label status tiket: Belum masuk, Di dalam (Hijau Daun 12%), atau Keluar (Abu).
class TicketStatusChip extends StatelessWidget {
  const TicketStatusChip(this.status, {super.key});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) => switch (status) {
        TicketStatus.inside => StatusChip(label: status.label, dot: AppColors.leaf, tinted: true),
        TicketStatus.waiting => StatusChip(label: status.label, dot: AppColors.leaf),
        TicketStatus.out => StatusChip(label: status.label, dot: AppColors.abu, muted: true),
      };
}
