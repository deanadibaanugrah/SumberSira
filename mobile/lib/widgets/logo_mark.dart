import 'package:flutter/material.dart';

// Logo Sumber Sira baru (sesuai logo resmi tetesan air & riak Sumber Sira).
// Digambar dengan CustomPainter (bukan gambar), tajam di semua resolusi dan mendukung animasi.
class LogoMark extends StatefulWidget {
  const LogoMark({super.key, this.size = 40, this.ring = false, this.animated = true});

  final double size;
  final bool ring;
  final bool animated;

  @override
  State<LogoMark> createState() => _LogoMarkState();
}

class _LogoMarkState extends State<LogoMark> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

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
          builder: (_, _) => CustomPaint(
            painter: _LogoPainter(_controller.value, widget.ring),
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.t, this.ring);

  final double t; // 0..1 (9 detik siklus)
  final bool ring;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Skala kanvas dari ukuran asli viewBox (370x370 diatur dari offset 8, 19.5)
    canvas.scale(size.width / 370);
    canvas.translate(-8, -19.5);

    // Lingkaran Hijau Tua dasar logo
    final bgPaint = Paint()..color = const Color(0xFF1A3E2F);
    canvas.drawCircle(const Offset(193, 204.5), 180, bgPaint);

    // 1. Tetes air (Drop)
    // 0..2% opacity 0, 4%..14% turun ke posisi asli, 16.5% squash/stretch, 23%..100% normal
    double dropDy = 0;
    double dropScaleY = 1.0;
    double dropScaleX = 1.0;
    double dropOpacity = 1.0;

    if (t < 0.02) {
      dropOpacity = 0.0;
    } else if (t < 0.04) {
      final p = (t - 0.02) / 0.02;
      dropOpacity = p;
      dropDy = -95.0 + 7.0 * p;
      dropScaleX = 0.85 + 0.05 * p;
      dropScaleY = 1.15 - 0.05 * p;
    } else if (t < 0.14) {
      final p = (t - 0.04) / 0.10;
      dropDy = -88.0 * (1 - p);
      dropScaleX = 0.90 + 0.02 * p;
      dropScaleY = 1.10 + 0.04 * p;
    } else if (t < 0.165) {
      final p = (t - 0.14) / 0.025;
      dropDy = 0;
      dropScaleX = 0.92 + 0.18 * p;
      dropScaleY = 1.14 - 0.24 * p;
    } else if (t < 0.20) {
      final p = (t - 0.165) / 0.035;
      dropScaleX = 1.10 - 0.13 * p;
      dropScaleY = 0.90 + 0.14 * p;
    } else if (t < 0.23) {
      final p = (t - 0.20) / 0.03;
      dropScaleX = 0.97 + 0.03 * p;
      dropScaleY = 1.04 - 0.04 * p;
    }

    if (dropOpacity > 0) {
      canvas.save();
      // Pusat tetes air 193.5, 191
      canvas.translate(193.5, 191.0);
      canvas.scale(dropScaleX, dropScaleY);
      canvas.translate(-193.5, -191.0 + dropDy);

      final dropPath = Path()
        ..moveTo(193.25, 104.50)
        ..lineTo(190.88, 110.00)
        ..lineTo(177.12, 131.00)
        ..lineTo(169.50, 144.75)
        ..lineTo(167.25, 150.12)
        ..lineTo(165.25, 157.50)
        ..lineTo(165.00, 165.50)
        ..lineTo(166.50, 171.88)
        ..lineTo(168.12, 175.75)
        ..lineTo(171.12, 180.25)
        ..lineTo(174.25, 183.50)
        ..lineTo(177.50, 186.12)
        ..lineTo(182.62, 188.88)
        ..lineTo(186.38, 190.00)
        ..lineTo(194.12, 190.88)
        ..lineTo(200.62, 190.00)
        ..lineTo(204.25, 188.88)
        ..lineTo(209.88, 185.75)
        ..lineTo(214.50, 181.62)
        ..lineTo(217.00, 178.50)
        ..lineTo(219.88, 173.25)
        ..lineTo(221.50, 167.12)
        ..lineTo(221.88, 161.62)
        ..lineTo(221.12, 155.62)
        ..lineTo(219.88, 150.75)
        ..lineTo(215.75, 141.38)
        ..lineTo(210.00, 131.50)
        ..lineTo(196.12, 110.25)
        ..lineTo(193.88, 104.88)
        ..close()
        // Inner highlight
        ..moveTo(211.12, 141.62)
        ..lineTo(212.75, 143.38)
        ..lineTo(216.00, 150.50)
        ..lineTo(217.50, 155.75)
        ..lineTo(218.25, 162.12)
        ..lineTo(218.00, 167.25)
        ..lineTo(217.00, 171.62)
        ..lineTo(214.38, 176.50)
        ..lineTo(211.50, 179.75)
        ..lineTo(210.75, 179.62)
        ..lineTo(210.62, 178.50)
        ..lineTo(211.75, 173.25)
        ..lineTo(212.62, 165.75)
        ..lineTo(212.88, 158.38)
        ..lineTo(211.75, 147.25)
        ..lineTo(210.75, 142.75)
        ..close();
      dropPath.fillType = PathFillType.evenOdd;
      canvas.drawPath(dropPath, Paint()..color = Colors.white.withValues(alpha: dropOpacity));
      canvas.restore();
    }

    // 2. Percikan Kiri (Splash L)
    double spLOpacity = (t < 0.14) ? 0.0 : ((t < 0.16) ? (t - 0.14) / 0.02 : 1.0);
    double spLScale = (t < 0.14) ? 0.15 : ((t < 0.24) ? 0.15 + 0.85 * ((t - 0.14) / 0.10) : 1.0);
    double spLDx = (t < 0.14) ? 26.0 : ((t < 0.24) ? 26.0 * (1 - (t - 0.14) / 0.10) : 0.0);
    double spLDy = (t < 0.14) ? 10.0 : ((t < 0.24) ? 10.0 * (1 - (t - 0.14) / 0.10) : 0.0);

    if (spLOpacity > 0) {
      canvas.save();
      canvas.translate(spLDx, spLDy);
      if (spLScale != 1.0) {
        canvas.translate(169.12, 193.38);
        canvas.scale(spLScale);
        canvas.translate(-169.12, -193.38);
      }
      final spLPath = Path()
        ..moveTo(138.62, 174.12)
        ..lineTo(137.88, 177.25)
        ..lineTo(138.38, 180.00)
        ..lineTo(142.00, 183.62)
        ..lineTo(145.50, 185.75)
        ..lineTo(152.25, 188.88)
        ..lineTo(163.12, 192.75)
        ..lineTo(169.12, 193.38)
        ..lineTo(163.50, 189.12)
        ..lineTo(158.75, 184.88)
        ..lineTo(147.00, 172.00)
        ..lineTo(144.75, 171.25)
        ..lineTo(142.50, 171.25)
        ..lineTo(140.25, 172.12)
        ..close()
        ..moveTo(141.88, 172.00)
        ..lineTo(142.38, 171.62)
        ..lineTo(145.00, 171.62)
        ..lineTo(146.12, 172.88)
        ..lineTo(147.25, 173.25)
        ..lineTo(147.50, 173.88)
        ..lineTo(146.50, 174.12)
        ..lineTo(144.75, 173.38)
        ..lineTo(142.38, 173.12)
        ..close()
        ..moveTo(156.62, 165.12)
        ..lineTo(155.62, 166.38)
        ..lineTo(155.62, 167.75)
        ..lineTo(154.75, 169.12)
        ..lineTo(155.00, 171.00)
        ..lineTo(160.75, 178.88)
        ..lineTo(163.88, 182.00)
        ..lineTo(165.25, 182.75)
        ..lineTo(162.88, 176.00)
        ..lineTo(160.75, 167.12)
        ..lineTo(159.00, 165.12)
        ..close();
      spLPath.fillType = PathFillType.evenOdd;
      canvas.drawPath(spLPath, Paint()..color = Colors.white.withValues(alpha: spLOpacity));
      canvas.restore();
    }

    // 3. Percikan Kanan (Splash R)
    double spROpacity = (t < 0.14) ? 0.0 : ((t < 0.16) ? (t - 0.14) / 0.02 : 1.0);
    double spRScale = (t < 0.14) ? 0.15 : ((t < 0.24) ? 0.15 + 0.85 * ((t - 0.14) / 0.10) : 1.0);
    double spRDx = (t < 0.14) ? -26.0 : ((t < 0.24) ? -26.0 * (1 - (t - 0.14) / 0.10) : 0.0);
    double spRDy = (t < 0.14) ? 10.0 : ((t < 0.24) ? 10.0 * (1 - (t - 0.14) / 0.10) : 0.0);

    if (spROpacity > 0) {
      canvas.save();
      canvas.translate(spRDx, spRDy);
      if (spRScale != 1.0) {
        canvas.translate(217.75, 193.38);
        canvas.scale(spRScale);
        canvas.translate(-217.75, -193.38);
      }
      final spRPath = Path()
        ..moveTo(247.88, 173.50)
        ..lineTo(246.50, 172.25)
        ..lineTo(245.75, 172.12)
        ..lineTo(244.88, 173.00)
        ..lineTo(239.62, 174.00)
        ..lineTo(239.25, 173.38)
        ..lineTo(240.50, 172.88)
        ..lineTo(240.88, 171.88)
        ..lineTo(239.88, 172.00)
        ..lineTo(228.88, 184.12)
        ..lineTo(223.50, 189.00)
        ..lineTo(217.75, 193.38)
        ..lineTo(223.62, 192.75)
        ..lineTo(234.62, 188.88)
        ..lineTo(244.88, 183.62)
        ..lineTo(247.62, 181.25)
        ..lineTo(248.75, 179.25)
        ..lineTo(249.00, 176.50)
        ..close()
        ..moveTo(230.50, 165.00)
        ..lineTo(229.25, 165.25)
        ..lineTo(227.25, 167.62)
        ..lineTo(226.62, 172.12)
        ..lineTo(223.12, 182.00)
        ..lineTo(223.38, 182.62)
        ..lineTo(226.25, 180.38)
        ..lineTo(228.88, 177.38)
        ..lineTo(233.38, 170.88)
        ..lineTo(233.50, 168.50)
        ..lineTo(232.25, 166.00)
        ..close();
      spRPath.fillType = PathFillType.evenOdd;
      canvas.drawPath(spRPath, Paint()..color = Colors.white.withValues(alpha: spROpacity));
      canvas.restore();
    }

    // 4. Riak Tengah (Ripple Mid)
    double midOpacity = (t < 0.145) ? 0.0 : ((t < 0.18) ? (t - 0.145) / 0.035 : 1.0);
    double midScale = (t < 0.145) ? 0.08 : ((t < 0.26) ? 0.08 + 0.92 * ((t - 0.145) / 0.115) : 1.0);

    if (midOpacity > 0) {
      canvas.save();
      canvas.translate(193.5, 206.0);
      canvas.scale(midScale);
      canvas.translate(-193.5, -206.0);
      final midPath = Path()
        ..moveTo(128.88, 201.50)
        ..lineTo(129.25, 205.25)
        ..lineTo(133.00, 209.62)
        ..lineTo(138.38, 212.75)
        ..lineTo(144.75, 215.38)
        ..lineTo(152.75, 217.75)
        ..lineTo(162.75, 219.62)
        ..lineTo(167.12, 220.00)
        ..lineTo(169.12, 220.75)
        ..lineTo(188.50, 221.88)
        ..lineTo(198.38, 221.88)
        ..lineTo(216.62, 220.88)
        ..lineTo(219.75, 220.00)
        ..lineTo(231.75, 218.25)
        ..lineTo(237.88, 216.75)
        ..lineTo(245.88, 214.00)
        ..lineTo(252.25, 210.75)
        ..lineTo(255.88, 207.62)
        ..lineTo(257.75, 204.75)
        ..lineTo(258.00, 203.12)
        ..lineTo(257.50, 200.12)
        ..lineTo(254.50, 196.38)
        ..lineTo(250.62, 193.62)
        ..lineTo(244.88, 191.38)
        ..lineTo(249.50, 196.00)
        ..lineTo(250.12, 198.12)
        ..lineTo(249.88, 201.00)
        ..lineTo(248.62, 203.12)
        ..lineTo(246.50, 205.12)
        ..lineTo(239.88, 208.88)
        ..lineTo(231.62, 211.75)
        ..lineTo(223.12, 213.12)
        ..lineTo(220.75, 214.00)
        ..lineTo(207.75, 215.50)
        ..lineTo(190.88, 215.88)
        ..lineTo(179.00, 215.50)
        ..lineTo(166.12, 214.00)
        ..lineTo(163.75, 213.12)
        ..lineTo(155.25, 211.75)
        ..lineTo(146.88, 208.88)
        ..lineTo(140.00, 204.88)
        ..lineTo(138.25, 203.12)
        ..lineTo(136.88, 200.88)
        ..lineTo(136.62, 198.62)
        ..lineTo(137.12, 196.38)
        ..lineTo(138.12, 194.88)
        ..lineTo(141.75, 191.38)
        ..lineTo(136.50, 193.50)
        ..lineTo(132.50, 196.25)
        ..lineTo(130.12, 198.75)
        ..close();
      canvas.drawPath(midPath, Paint()..color = Colors.white.withValues(alpha: midOpacity));
      canvas.restore();
    }

    // 5. Riak Luar (Ripple Out)
    double outOpacity = (t < 0.17) ? 0.0 : ((t < 0.21) ? (t - 0.17) / 0.04 : 1.0);
    double outScale = (t < 0.17) ? 0.08 : ((t < 0.31) ? 0.08 + 0.92 * ((t - 0.17) / 0.14) : 1.0);

    if (outOpacity > 0) {
      canvas.save();
      canvas.translate(193.5, 220.0);
      canvas.scale(outScale);
      canvas.translate(-193.5, -220.0);
      final outPath = Path()
        ..moveTo(290.38, 214.00)
        ..lineTo(289.50, 210.25)
        ..lineTo(286.00, 205.88)
        ..lineTo(279.50, 201.25)
        ..lineTo(270.38, 197.00)
        ..lineTo(270.00, 197.50)
        ..lineTo(273.38, 199.88)
        ..lineTo(277.38, 204.12)
        ..lineTo(278.88, 207.75)
        ..lineTo(279.00, 209.62)
        ..lineTo(277.88, 212.88)
        ..lineTo(276.50, 215.00)
        ..lineTo(273.62, 217.88)
        ..lineTo(269.50, 220.75)
        ..lineTo(260.50, 224.88)
        ..lineTo(251.75, 227.75)
        ..lineTo(244.75, 229.12)
        ..lineTo(242.38, 230.00)
        ..lineTo(234.25, 231.50)
        ..lineTo(227.38, 232.12)
        ..lineTo(223.88, 233.00)
        ..lineTo(214.00, 233.88)
        ..lineTo(199.12, 234.50)
        ..lineTo(181.62, 234.38)
        ..lineTo(163.00, 233.00)
        ..lineTo(159.50, 232.12)
        ..lineTo(152.75, 231.50)
        ..lineTo(144.50, 230.00)
        ..lineTo(142.12, 229.12)
        ..lineTo(134.62, 227.62)
        ..lineTo(123.50, 223.75)
        ..lineTo(117.50, 220.88)
        ..lineTo(113.12, 217.75)
        ..lineTo(110.12, 214.75)
        ..lineTo(108.12, 210.75)
        ..lineTo(108.12, 207.25)
        ..lineTo(110.00, 203.38)
        ..lineTo(112.62, 200.62)
        ..lineTo(116.50, 197.88)
        ..lineTo(116.62, 197.12)
        ..lineTo(115.75, 197.12)
        ..lineTo(114.88, 197.88)
        ..lineTo(109.12, 200.25)
        ..lineTo(101.12, 205.62)
        ..lineTo(98.25, 208.88)
        ..lineTo(97.12, 210.88)
        ..lineTo(96.62, 213.00)
        ..lineTo(96.88, 217.75)
        ..lineTo(98.25, 220.62)
        ..lineTo(101.50, 224.00)
        ..lineTo(106.62, 227.62)
        ..lineTo(110.75, 229.88)
        ..lineTo(117.50, 232.75)
        ..lineTo(130.25, 236.75)
        ..lineTo(144.62, 239.75)
        ..lineTo(168.88, 242.62)
        ..lineTo(183.75, 243.25)
        ..lineTo(203.12, 243.25)
        ..lineTo(218.00, 242.62)
        ..lineTo(242.25, 239.75)
        ..lineTo(256.12, 236.88)
        ..lineTo(266.88, 233.62)
        ..lineTo(276.50, 229.62)
        ..lineTo(281.25, 227.00)
        ..lineTo(285.50, 223.88)
        ..lineTo(288.25, 220.88)
        ..lineTo(289.75, 218.50)
        ..close();
      canvas.drawPath(outPath, Paint()..color = Colors.white.withValues(alpha: outOpacity));
      canvas.restore();
    }

    // 6. Tulisan SUMBER SIRA (Text)
    double txtOpacity = (t < 0.33) ? 0.0 : ((t < 0.47) ? (t - 0.33) / 0.14 : 1.0);

    if (txtOpacity > 0) {
      canvas.save();
      final txtPath = Path()
        ..moveTo(255.88, 268.75)..lineTo(255.50, 269.38)..lineTo(256.25, 270.38)..lineTo(256.38, 270.88)..lineTo(256.38, 282.00)..lineTo(255.75, 282.75)..lineTo(254.88, 283.25)..lineTo(254.88, 283.62)..lineTo(255.88, 284.12)..lineTo(259.38, 284.12)..lineTo(260.75, 283.75)..lineTo(260.88, 283.50)..lineTo(260.75, 283.12)..lineTo(259.62, 282.75)..lineTo(259.12, 282.25)..lineTo(259.12, 277.38)..lineTo(259.38, 276.75)..lineTo(259.88, 276.25)..lineTo(260.12, 276.25)..lineTo(261.62, 277.75)..lineTo(261.88, 278.38)..lineTo(264.75, 282.25)..lineTo(266.38, 283.88)..lineTo(267.00, 284.12)..lineTo(269.75, 284.12)..lineTo(270.50, 283.88)..lineTo(270.75, 283.62)..lineTo(270.75, 283.25)..lineTo(270.25, 282.88)..lineTo(268.88, 282.50)..lineTo(266.25, 280.12)..lineTo(263.62, 276.38)..lineTo(263.50, 275.88)..lineTo(263.75, 275.38)..lineTo(264.75, 274.50)..lineTo(265.75, 272.50)..lineTo(265.75, 271.25)..lineTo(265.12, 269.88)..lineTo(264.25, 269.00)..lineTo(262.75, 268.50)..lineTo(261.75, 268.50)..lineTo(261.00, 268.75)..lineTo(256.88, 268.50)..close()
        ..moveTo(261.00, 269.62)..lineTo(262.25, 270.25)..lineTo(262.75, 271.00)..lineTo(262.88, 273.50)..lineTo(262.62, 274.12)..lineTo(262.00, 274.75)..lineTo(260.12, 275.25)..lineTo(259.75, 275.12)..lineTo(259.12, 274.38)..lineTo(259.12, 270.62)..lineTo(259.25, 270.25)..lineTo(259.88, 269.62)..close()
        ..moveTo(244.38, 268.50)..lineTo(243.75, 268.62)..lineTo(243.25, 269.00)..lineTo(243.25, 269.50)..lineTo(243.88, 270.38)..lineTo(243.88, 282.25)..lineTo(243.50, 282.75)..lineTo(242.62, 283.00)..lineTo(242.38, 283.25)..lineTo(242.38, 283.62)..lineTo(242.62, 283.88)..lineTo(243.62, 284.12)..lineTo(247.00, 284.12)..lineTo(248.38, 283.62)..lineTo(248.25, 283.12)..lineTo(247.25, 282.75)..lineTo(246.75, 282.25)..lineTo(246.75, 270.62)..lineTo(247.50, 269.38)..lineTo(247.50, 269.00)..lineTo(247.25, 268.75)..lineTo(246.25, 268.50)..close()
        ..moveTo(195.62, 268.75)..lineTo(195.38, 269.00)..lineTo(195.38, 269.50)..lineTo(196.00, 270.50)..lineTo(196.00, 282.25)..lineTo(195.50, 282.75)..lineTo(194.75, 283.00)..lineTo(194.50, 283.25)..lineTo(194.50, 283.62)..lineTo(195.00, 284.00)..lineTo(195.75, 284.12)..lineTo(199.12, 284.12)..lineTo(200.50, 283.75)..lineTo(200.62, 283.50)..lineTo(200.50, 283.12)..lineTo(199.25, 282.62)..lineTo(198.88, 282.00)..lineTo(198.88, 277.62)..lineTo(199.25, 276.62)..lineTo(199.62, 276.25)..lineTo(200.12, 276.25)..lineTo(200.62, 276.75)..lineTo(203.38, 280.88)..lineTo(205.88, 283.75)..lineTo(206.62, 284.12)..lineTo(209.38, 284.12)..lineTo(210.12, 283.88)..lineTo(210.38, 283.62)..lineTo(210.38, 283.25)..lineTo(210.12, 283.00)..lineTo(208.38, 282.38)..lineTo(206.00, 280.25)..lineTo(205.75, 279.62)..lineTo(204.12, 277.62)..lineTo(203.25, 276.25)..lineTo(203.38, 275.50)..lineTo(204.38, 274.62)..lineTo(205.25, 273.12)..lineTo(205.38, 271.38)..lineTo(205.25, 270.62)..lineTo(204.88, 269.88)..lineTo(203.88, 269.00)..lineTo(202.38, 268.50)..lineTo(201.62, 268.50)..lineTo(200.75, 268.75)..lineTo(196.62, 268.50)..close()
        ..moveTo(199.75, 269.62)..lineTo(200.62, 269.62)..lineTo(201.88, 270.25)..lineTo(202.25, 270.62)..lineTo(202.75, 271.75)..lineTo(202.75, 273.12)..lineTo(202.25, 274.12)..lineTo(201.62, 274.75)..lineTo(200.25, 275.25)..lineTo(199.38, 275.00)..lineTo(198.88, 274.12)..lineTo(198.88, 270.88)..lineTo(199.00, 270.38)..close()
        ..moveTo(177.75, 268.88)..lineTo(177.50, 269.25)..lineTo(178.50, 270.12)..lineTo(178.75, 270.88)..lineTo(178.62, 271.62)..lineTo(178.62, 281.12)..lineTo(178.75, 282.00)..lineTo(178.38, 282.62)..lineTo(177.25, 283.00)..lineTo(177.00, 283.25)..lineTo(177.00, 283.62)..lineTo(177.50, 284.00)..lineTo(178.25, 284.12)..lineTo(187.50, 284.12)..lineTo(187.88, 284.00)..lineTo(188.38, 283.38)..lineTo(188.38, 282.12)..lineTo(188.50, 282.00)..lineTo(188.50, 280.75)..lineTo(187.88, 280.12)..lineTo(187.25, 280.25)..lineTo(186.50, 281.75)..lineTo(185.88, 282.38)..lineTo(185.12, 282.75)..lineTo(182.25, 282.75)..lineTo(181.88, 282.62)..lineTo(181.38, 282.00)..lineTo(181.38, 277.38)..lineTo(181.62, 276.75)..lineTo(182.00, 276.38)..lineTo(182.62, 276.12)..lineTo(184.00, 276.25)..lineTo(186.00, 278.00)..lineTo(186.38, 278.00)..lineTo(186.75, 277.62)..lineTo(186.88, 277.00)..lineTo(186.88, 274.88)..lineTo(186.38, 274.12)..lineTo(185.88, 274.12)..lineTo(183.88, 275.25)..lineTo(182.50, 275.25)..lineTo(181.88, 275.00)..lineTo(181.50, 274.62)..lineTo(181.38, 274.25)..lineTo(181.38, 270.75)..lineTo(181.88, 270.00)..lineTo(182.62, 269.62)..lineTo(184.12, 269.62)..lineTo(185.25, 270.00)..lineTo(186.00, 270.75)..lineTo(186.25, 271.38)..lineTo(186.62, 271.75)..lineTo(187.25, 271.88)..lineTo(187.62, 271.62)..lineTo(187.88, 270.75)..lineTo(187.88, 269.88)..lineTo(187.62, 269.12)..lineTo(187.12, 268.62)..lineTo(186.75, 268.50)..lineTo(185.00, 268.50)..lineTo(184.88, 268.62)..lineTo(178.88, 268.50)..close()
        ..moveTo(159.88, 268.75)..lineTo(159.50, 269.12)..lineTo(159.50, 269.38)..lineTo(160.38, 270.75)..lineTo(160.38, 282.12)..lineTo(160.00, 282.62)..lineTo(159.00, 283.00)..lineTo(158.75, 283.25)..lineTo(158.75, 283.62)..lineTo(159.25, 284.00)..lineTo(159.88, 284.12)..lineTo(163.75, 284.12)..lineTo(163.88, 284.00)..lineTo(166.62, 284.12)..lineTo(167.62, 283.88)..lineTo(168.50, 283.12)..lineTo(169.12, 282.88)..lineTo(169.88, 282.12)..lineTo(170.75, 279.75)..lineTo(170.75, 278.25)..lineTo(169.88, 276.25)..lineTo(168.88, 275.38)..lineTo(168.50, 275.25)..lineTo(167.88, 274.50)..lineTo(168.88, 273.25)..lineTo(169.25, 272.38)..lineTo(169.38, 271.25)..lineTo(169.00, 270.12)..lineTo(168.00, 269.12)..lineTo(166.88, 268.62)..lineTo(166.00, 268.50)..lineTo(164.88, 268.75)..lineTo(163.62, 268.75)..lineTo(162.62, 268.50)..lineTo(161.00, 268.50)..close()
        ..moveTo(163.75, 276.00)..lineTo(165.00, 275.88)..lineTo(166.12, 276.25)..lineTo(166.75, 276.75)..lineTo(167.75, 278.12)..lineTo(167.88, 278.62)..lineTo(167.75, 281.38)..lineTo(167.38, 282.00)..lineTo(166.38, 282.75)..lineTo(164.25, 282.88)..lineTo(163.62, 282.62)..lineTo(163.25, 282.12)..lineTo(163.25, 276.50)..close()
        ..moveTo(165.00, 269.62)..lineTo(166.00, 270.25)..lineTo(166.38, 270.75)..lineTo(166.50, 272.38)..lineTo(166.12, 273.25)..lineTo(165.25, 274.12)..lineTo(164.38, 274.75)..lineTo(163.88, 274.75)..lineTo(163.50, 274.50)..lineTo(163.25, 274.00)..lineTo(163.25, 270.50)..lineTo(163.88, 269.75)..close()
        ..moveTo(134.62, 268.88)..lineTo(134.50, 269.50)..lineTo(135.25, 270.25)..lineTo(135.50, 270.75)..lineTo(135.38, 274.00)..lineTo(135.25, 274.12)..lineTo(135.25, 276.25)..lineTo(135.38, 276.38)..lineTo(135.25, 281.38)..lineTo(135.00, 282.25)..lineTo(133.88, 283.12)..lineTo(133.75, 283.50)..lineTo(134.00, 283.88)..lineTo(134.75, 284.12)..lineTo(137.62, 284.12)..lineTo(138.62, 283.62)..lineTo(138.62, 283.25)..lineTo(137.25, 282.38)..lineTo(137.00, 281.50)..lineTo(137.00, 276.62)..lineTo(137.12, 276.50)..lineTo(137.12, 274.88)..lineTo(137.38, 274.50)..lineTo(137.88, 274.75)..lineTo(138.62, 276.62)..lineTo(140.75, 280.62)..lineTo(141.12, 281.88)..lineTo(141.88, 283.38)..lineTo(142.38, 283.88)..lineTo(143.12, 284.00)..lineTo(143.50, 283.88)..lineTo(144.00, 283.38)..lineTo(146.00, 278.25)..lineTo(147.25, 275.75)..lineTo(147.62, 275.38)..lineTo(147.88, 275.38)..lineTo(148.25, 275.88)..lineTo(148.62, 281.88)..lineTo(148.38, 282.50)..lineTo(147.25, 283.25)..lineTo(147.25, 283.62)..lineTo(147.75, 284.00)..lineTo(148.38, 284.12)..lineTo(151.62, 284.12)..lineTo(152.50, 284.00)..lineTo(153.00, 283.62)..lineTo(153.00, 283.25)..lineTo(152.75, 283.00)..lineTo(151.88, 282.75)..lineTo(151.25, 282.00)..lineTo(151.25, 278.12)..lineTo(151.12, 278.00)..lineTo(150.88, 270.50)..lineTo(152.00, 269.38)..lineTo(152.00, 269.12)..lineTo(151.62, 268.75)..lineTo(150.62, 268.50)..lineTo(149.62, 268.50)..lineTo(148.88, 268.75)..lineTo(148.25, 269.38)..lineTo(147.00, 272.12)..lineTo(146.75, 273.38)..lineTo(145.88, 274.62)..lineTo(145.75, 275.25)..lineTo(144.88, 276.75)..lineTo(143.88, 279.38)..lineTo(143.50, 279.62)..lineTo(142.75, 278.88)..lineTo(141.00, 274.75)..lineTo(140.25, 273.62)..lineTo(138.25, 269.38)..lineTo(137.62, 268.75)..lineTo(136.88, 268.50)..lineTo(135.62, 268.50)..close()
        ..moveTo(282.88, 268.25)..lineTo(282.12, 269.00)..lineTo(281.75, 270.12)..lineTo(280.88, 271.62)..lineTo(280.38, 273.38)..lineTo(279.88, 274.25)..lineTo(279.75, 275.12)..lineTo(277.88, 278.75)..lineTo(277.50, 280.00)..lineTo(276.62, 281.88)..lineTo(276.25, 282.38)..lineTo(275.00, 283.00)..lineTo(274.75, 283.25)..lineTo(274.75, 283.62)..lineTo(275.75, 284.12)..lineTo(279.25, 284.12)..lineTo(280.25, 283.88)..lineTo(280.50, 283.62)..lineTo(280.50, 283.25)..lineTo(280.25, 283.00)..lineTo(279.00, 282.62)..lineTo(278.62, 282.25)..lineTo(278.62, 281.38)..lineTo(280.12, 277.75)..lineTo(280.62, 277.25)..lineTo(281.50, 277.00)..lineTo(284.50, 277.00)..lineTo(285.25, 277.25)..lineTo(285.62, 277.62)..lineTo(287.50, 282.12)..lineTo(287.38, 282.50)..lineTo(286.50, 283.12)..lineTo(286.38, 283.38)..lineTo(286.50, 283.75)..lineTo(287.62, 284.12)..lineTo(291.25, 284.12)..lineTo(291.88, 283.88)..lineTo(292.12, 283.62)..lineTo(292.12, 283.25)..lineTo(291.00, 282.50)..lineTo(290.38, 281.75)..lineTo(288.75, 278.38)..lineTo(288.12, 277.50)..lineTo(287.88, 276.50)..lineTo(287.12, 275.12)..lineTo(286.75, 274.00)..lineTo(285.00, 270.88)..lineTo(284.75, 269.88)..lineTo(284.12, 268.62)..lineTo(283.50, 268.12)..close()
        ..moveTo(282.38, 272.38)..lineTo(282.88, 272.38)..lineTo(283.12, 272.62)..lineTo(284.25, 274.75)..lineTo(284.38, 275.25)..lineTo(284.00, 275.75)..lineTo(282.00, 275.88)..lineTo(281.62, 275.75)..lineTo(281.12, 275.25)..lineTo(281.12, 274.75)..close()
        ..moveTo(234.25, 268.00)..lineTo(233.25, 267.75)..lineTo(229.12, 267.88)..lineTo(228.38, 268.12)..lineTo(227.50, 268.75)..lineTo(226.88, 269.38)..lineTo(226.50, 270.12)..lineTo(226.38, 272.88)..lineTo(227.00, 274.25)..lineTo(228.62, 275.75)..lineTo(231.12, 277.12)..lineTo(232.62, 278.62)..lineTo(233.12, 279.62)..lineTo(233.12, 281.38)..lineTo(232.50, 282.50)..lineTo(232.00, 282.75)..lineTo(229.88, 282.75)..lineTo(229.00, 282.38)..lineTo(228.00, 281.38)..lineTo(227.25, 280.25)..lineTo(227.00, 279.50)..lineTo(226.38, 279.25)..lineTo(225.88, 280.00)..lineTo(226.00, 282.38)..lineTo(226.75, 283.38)..lineTo(227.75, 284.00)..lineTo(232.12, 284.12)..lineTo(233.00, 283.88)..lineTo(234.50, 282.88)..lineTo(235.12, 282.25)..lineTo(235.88, 280.88)..lineTo(236.00, 279.12)..lineTo(235.88, 278.50)..lineTo(235.12, 277.12)..lineTo(233.50, 275.62)..lineTo(231.75, 274.75)..lineTo(230.12, 273.50)..lineTo(229.12, 272.38)..lineTo(228.88, 271.62)..lineTo(228.88, 270.50)..lineTo(229.50, 269.25)..lineTo(230.00, 269.00)..lineTo(231.88, 269.00)..lineTo(232.50, 269.25)..lineTo(233.00, 269.75)..lineTo(234.00, 271.75)..lineTo(234.38, 272.00)..lineTo(234.75, 272.00)..lineTo(235.12, 271.38)..lineTo(235.12, 269.50)..lineTo(234.88, 268.62)..close()
        ..moveTo(112.62, 268.00)..lineTo(112.38, 268.25)..lineTo(112.38, 268.62)..lineTo(113.38, 269.38)..lineTo(113.62, 270.25)..lineTo(113.50, 271.00)..lineTo(113.62, 278.88)..lineTo(114.00, 280.50)..lineTo(115.12, 282.25)..lineTo(115.62, 282.75)..lineTo(117.38, 283.88)..lineTo(118.12, 284.12)..lineTo(122.25, 284.12)..lineTo(123.00, 283.88)..lineTo(123.75, 283.25)..lineTo(124.75, 282.75)..lineTo(125.88, 281.38)..lineTo(126.25, 280.38)..lineTo(126.25, 279.50)..lineTo(126.75, 277.25)..lineTo(126.75, 271.38)..lineTo(126.62, 271.25)..lineTo(126.88, 269.62)..lineTo(127.88, 268.62)..lineTo(127.88, 268.25)..lineTo(127.38, 267.88)..lineTo(126.62, 267.75)..lineTo(124.00, 267.88)..lineTo(123.38, 268.25)..lineTo(123.38, 268.62)..lineTo(124.50, 269.38)..lineTo(124.88, 270.25)..lineTo(124.75, 280.12)..lineTo(124.62, 280.50)..lineTo(123.25, 281.88)..lineTo(121.88, 282.62)..lineTo(120.50, 282.75)..lineTo(119.12, 282.38)..lineTo(117.75, 281.50)..lineTo(117.12, 280.75)..lineTo(116.50, 279.12)..lineTo(116.38, 278.38)..lineTo(116.38, 269.75)..lineTo(116.88, 269.12)..lineTo(117.75, 268.62)..lineTo(117.75, 268.25)..lineTo(117.00, 267.88)..lineTo(114.00, 267.75)..close()
        ..moveTo(104.25, 267.88)..lineTo(103.62, 267.75)..lineTo(99.38, 267.88)..lineTo(97.62, 268.88)..lineTo(96.75, 270.12)..lineTo(96.50, 272.12)..lineTo(96.88, 273.62)..lineTo(98.25, 275.25)..lineTo(101.62, 277.25)..lineTo(102.75, 278.38)..lineTo(103.25, 279.25)..lineTo(103.50, 280.62)..lineTo(103.38, 281.50)..lineTo(102.62, 282.62)..lineTo(100.12, 282.75)..lineTo(99.50, 282.50)..lineTo(98.38, 281.50)..lineTo(97.88, 280.38)..lineTo(97.25, 279.62)..lineTo(96.75, 279.38)..lineTo(96.38, 279.50)..lineTo(96.12, 280.00)..lineTo(96.50, 282.50)..lineTo(96.75, 283.00)..lineTo(97.75, 283.88)..lineTo(98.50, 284.12)..lineTo(103.00, 284.00)..lineTo(104.62, 283.00)..lineTo(105.50, 282.12)..lineTo(106.12, 281.00)..lineTo(106.38, 279.62)..lineTo(106.25, 278.88)..lineTo(105.62, 277.38)..lineTo(104.50, 276.12)..lineTo(100.38, 273.50)..lineTo(99.25, 272.12)..lineTo(99.00, 271.12)..lineTo(99.38, 269.75)..lineTo(99.88, 269.25)..lineTo(101.12, 268.88)..lineTo(102.75, 269.25)..lineTo(103.62, 270.25)..lineTo(104.12, 271.50)..lineTo(104.50, 271.88)..lineTo(104.88, 272.00)..lineTo(105.25, 271.88)..lineTo(105.62, 271.38)..lineTo(105.50, 269.38)..lineTo(104.88, 268.25)..close();
      txtPath.fillType = PathFillType.evenOdd;
      canvas.drawPath(txtPath, Paint()..color = Colors.white.withValues(alpha: txtOpacity));
      canvas.restore();
    }

    // Garis tepi / Ring putih tipis
    canvas.drawCircle(
      const Offset(193, 204.5),
      180,
      Paint()
        ..color = Colors.white.withValues(alpha: ring ? 0.8 : 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring ? 6 : 3,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.t != t || old.ring != ring;
}
