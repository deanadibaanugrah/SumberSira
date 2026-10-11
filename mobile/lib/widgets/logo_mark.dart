import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Logo Sumber Sira yang bergerak: tetes air naik turun, riak air melebar, sawah bergoyang.
// Digambar dengan CustomPainter (bukan gambar), jadi tajam di semua ukuran.
class LogoMark extends StatefulWidget {
  const LogoMark({super.key, this.size = 40, this.ring = false, this.animated = true});

  final double size;
  final bool ring;
  final bool animated;

  @override
  State<LogoMark> createState() => _LogoMarkState();
}

class _LogoMarkState extends State<LogoMark> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    if (widget.animated) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo Sumber Sira',
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, _) => CustomPaint(painter: _LogoPainter(_controller.value, widget.ring)),
        ),
      ),
    );
  }
}

// Menggambar logo di kanvas 120 x 120 lalu diskalakan sesuai ukuran widget.
class _LogoPainter extends CustomPainter {
  _LogoPainter(this.t, this.ring);

  final double t; // posisi animasi 0..1
  final bool ring;

  // Satu lapisan sawah, digeser ke samping sejauh dx.
  Path _terrace(double dx, double y, double a, double b, double c, double d) {
    return Path()
      ..moveTo(-16 + dx, y)
      ..cubicTo(10 + dx, y - 10, 46 + dx, y - a, 60 + dx, y - b)
      ..cubicTo(76 + dx, y - b, 110 + dx, y - c, 136 + dx, y - d)
      ..lineTo(136 + dx, 124)
      ..lineTo(-16 + dx, 124)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final wave = sin(t * 2 * pi);
    canvas.save();
    canvas.scale(size.width / 120);
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, 120, 120)));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 120, 120), Paint()..color = AppColors.forest);

    final leaf = AppColors.leaf;
    canvas.drawPath(_terrace(-8 * wave, 74, 4, 4, 12, 4), Paint()..color = leaf.withValues(alpha: .45));
    canvas.drawPath(_terrace(8 * wave, 88, 2, 3, 12, 4), Paint()..color = leaf.withValues(alpha: .72));
    canvas.drawPath(_terrace(-6 * wave, 102, 2, 3, 10, 4), Paint()..color = leaf);

    // Riak air: melebar lalu memudar.
    final scale = .3 + 1.4 * t;
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: (1 - t) * .85);
    canvas.drawOval(Rect.fromCenter(center: const Offset(60, 74), width: 32 * scale, height: 7 * scale), ripple);

    // Tetes air naik turun.
    final dy = -6 * (.5 - .5 * cos(2 * pi * t));
    canvas.translate(0, dy);
    final drop = Path()
      ..moveTo(60, 17)
      ..cubicTo(60, 17, 43, 37, 43, 50)
      ..arcToPoint(const Offset(77, 50), radius: const Radius.circular(17), clockwise: false)
      ..cubicTo(77, 37, 60, 17, 60, 17)
      ..close();
    canvas.drawPath(drop, Paint()..color = Colors.white);
    final shine = Path()
      ..moveTo(53, 49)
      ..arcToPoint(const Offset(58, 58), radius: const Radius.circular(8), clockwise: false);
    canvas.drawPath(shine, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = leaf);
    canvas.translate(0, -dy);

    if (ring) {
      canvas.drawCircle(const Offset(60, 60), 58, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white.withValues(alpha: .4));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.t != t || old.ring != ring;
}
