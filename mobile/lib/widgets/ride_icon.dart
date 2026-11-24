import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Ikon wahana di daftar Sewa & Wahana. Sebagian memakai ikon Material biasa;
// loker, ATV, dan bebek gayung digambar sendiri supaya bentuknya sesuai benda aslinya
// (bukan ikon kunci, motor, atau dayung).
class RideIcon extends StatelessWidget {
  const RideIcon({
    super.key,
    required this.id,
    required this.fallback,
    this.size = 20,
    this.color = AppColors.leaf,
  });

  final String id;
  final IconData fallback;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => switch (id) {
    'loker' => _LokerIcon(size: size, color: color),
    'atv' => _AtvIcon(size: size, color: color),
    'bebek-gayung' => _DuckIcon(size: size, color: color),
    _ => Icon(fallback, size: size, color: color),
  };
}

// Laci/loker: lemari tiga tingkat dengan gagang di tiap laci.
class _LokerIcon extends StatelessWidget {
  const _LokerIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _LokerPainter(color),
  );
}

class _LokerPainter extends CustomPainter {
  const _LokerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color);
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    final body = RRect.fromLTRBR(
      5,
      2.5,
      19,
      21.5,
      const Radius.circular(2.4),
    );
    canvas.drawRRect(body, p);
    canvas.drawLine(const Offset(5, 8.8), const Offset(19, 8.8), p);
    canvas.drawLine(const Offset(5, 14.9), const Offset(19, 14.9), p);
    // Gagang tiap laci.
    canvas.drawLine(const Offset(10.3, 5.7), const Offset(13.7, 5.7), p);
    canvas.drawLine(const Offset(10.3, 11.8), const Offset(13.7, 11.8), p);
    canvas.drawLine(const Offset(10.3, 18.0), const Offset(13.7, 18.0), p);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LokerPainter old) => old.color != color;
}

// ATV: empat roda besar, rangka rendah, setang tinggi, dan spatbor di atas roda.
class _AtvIcon extends StatelessWidget {
  const _AtvIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _AtvPainter(color),
  );
}

class _AtvPainter extends CustomPainter {
  const _AtvPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color);
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    const rear = Offset(6.1, 17.2);
    const front = Offset(17.9, 17.2);
    const wheel = 3.35;

    // Dua roda besar dengan poros di tengah.
    canvas.drawCircle(rear, wheel, p);
    canvas.drawCircle(front, wheel, p);
    canvas.drawCircle(rear, 1.05, p);
    canvas.drawCircle(front, 1.05, p);

    // Rangka dan dek antara roda.
    final frame = Path()
      ..moveTo(4.2, 12.3)
      ..lineTo(9.6, 12.3)
      ..lineTo(11.6, 14.1)
      ..lineTo(14.2, 14.1)
      ..lineTo(16.1, 12.3)
      ..lineTo(19.7, 12.3);
    canvas.drawPath(frame, p);

    // Suspensi depan dan setang.
    canvas.drawLine(const Offset(15.6, 13.9), const Offset(16.7, 8.7), p);
    canvas.drawLine(const Offset(15.3, 8.2), const Offset(18.7, 8.2), p);

    // Tempat duduk dan rak belakang.
    canvas.drawLine(const Offset(7.4, 10.6), const Offset(10.9, 10.6), p);
    canvas.drawLine(const Offset(3.6, 10.6), const Offset(5.6, 10.6), p);

    // Spatbor di atas kedua roda.
    canvas.drawArc(
      Rect.fromCircle(center: rear, radius: 4.35),
      math.pi,
      math.pi,
      false,
      p,
    );
    canvas.drawArc(
      Rect.fromCircle(center: front, radius: 4.35),
      math.pi,
      math.pi,
      false,
      p,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_AtvPainter old) => old.color != color;
}

// Bebek gayung: badan bulat, kepala, paruh, dan garis air.
class _DuckIcon extends StatelessWidget {
  const _DuckIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _DuckPainter(color),
  );
}

class _DuckPainter extends CustomPainter {
  const _DuckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color);
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    // Badan dan ekor.
    canvas.drawOval(const Rect.fromLTWH(2.8, 9.8, 12.8, 8.2), p);
    final tail = Path()
      ..moveTo(3.2, 11.6)
      ..lineTo(1.3, 9.9)
      ..lineTo(4.1, 10.4);
    canvas.drawPath(tail, p);

    // Kepala dan paruh.
    canvas.drawCircle(const Offset(16.1, 8.1), 3.05, p);
    final beak = Path()
      ..moveTo(18.8, 7.7)
      ..lineTo(21.6, 9.0)
      ..lineTo(18.6, 10.2);
    canvas.drawPath(beak, p);

    // Mata dan sayap.
    canvas.drawCircle(
      const Offset(16.8, 7.5),
      0.55,
      Paint()..color = color,
    );
    canvas.drawArc(
      const Rect.fromLTWH(5.2, 11.3, 6.8, 4.8),
      math.pi * .12,
      math.pi * .95,
      false,
      p,
    );

    // Garis air.
    canvas.drawLine(const Offset(2.2, 20.2), const Offset(11.8, 20.2), p);
    canvas.drawLine(const Offset(13.4, 20.2), const Offset(21.8, 20.2), p);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_DuckPainter old) => old.color != color;
}

Paint _stroke(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.65
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;
