import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Jenis kaca: light = di atas latar terang (Putih 72%), dark = di atas header gelap atau foto
// (Putih 12%), tint = CTA primer (Hijau Tua 85%).
enum GlassTone { light, dark, tint }

// Liquid Glass hanya untuk lapisan navigasi: tab bar, nav bar, CTA mengambang, sheet, toolbar.
// Kartu, list, foto, dan form tetap permukaan solid.
// Bila "tingkatkan kontras" aktif di perangkat, kaca diganti warna solid tanpa blur
// (pengganti Reduce Transparency): putih di latar terang, Hijau Tua di latar gelap.
class Glass extends StatelessWidget {
  const Glass({super.key, required this.child, this.tone = GlassTone.light, this.radius = 28, this.borderRadius, this.padding = EdgeInsets.zero, this.shadow = true});

  final Widget child;
  final GlassTone tone;
  final double radius;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final solid = MediaQuery.highContrastOf(context);
    final shape = borderRadius ?? BorderRadius.circular(radius);
    final (fill, edge) = switch (tone) {
      GlassTone.light => (solid ? Colors.white : AppColors.glass, AppColors.glassEdge),
      GlassTone.dark => (solid ? AppColors.forest : AppColors.kaca, AppColors.kaca),
      GlassTone.tint => (solid ? AppColors.forest : AppColors.glassTint, AppColors.kaca),
    };
    Widget box = DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: shape, border: Border.all(color: edge)),
      child: Padding(padding: padding, child: child),
    );
    if (!solid) box = BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: box);
    box = ClipRRect(borderRadius: shape, child: box);
    // Bayangan hanya di luar bentuk kaca, supaya kacanya tetap bening.
    if (shadow && tone != GlassTone.dark) {
      box = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: const [BoxShadow(color: AppColors.line, blurRadius: 24, offset: Offset(0, 8), blurStyle: BlurStyle.outer)],
        ),
        child: box,
      );
    }
    return box;
  }
}

// Tombol ikon bulat dari kaca (kembali, notifikasi, tutup). Ukuran sentuh 44 x 44.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed, this.tone = GlassTone.light, this.badge = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final GlassTone tone;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final color = tone == GlassTone.light ? AppColors.forest : Colors.white;
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: tooltip,
        child: Glass(
          tone: tone,
          radius: 22,
          shadow: false,
          child: SizedBox.square(
            dimension: 44,
            child: Stack(alignment: Alignment.center, children: [
              Icon(icon, size: 21, color: color),
              if (badge)
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: AppColors.leaf, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// Efek tekan gaya iOS: elemen sedikit mengecil saat ditekan. Mati bila animasi dikurangi.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap, this.semanticLabel, this.scale = .97});

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: AnimatedScale(
          scale: _down && !still ? widget.scale : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

// Bar kaca yang mengambang di bawah layar (total + tombol, atau satu tombol aksi).
class FloatingBar extends StatelessWidget {
  const FloatingBar({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(18, 12, 12, 12)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Glass(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

// Lembar dari bawah (sheet) berbahan kaca dengan pegangan di atas. Tinggi mengikuti isi;
// detents = titik henti tinggi (persen layar) bila isinya panjang dan perlu ditarik.
Future<T?> showGlassSheet<T>(BuildContext context, {required WidgetBuilder builder, List<double>? detents}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.line,
    builder: (ctx) {
      if (detents == null) return _SheetBody(child: builder(ctx));
      return DraggableScrollableSheet(
        expand: false,
        snap: true,
        initialChildSize: detents.first,
        minChildSize: detents.first * .6,
        maxChildSize: detents.last,
        snapSizes: detents,
        builder: (c, controller) => _SheetBody(controller: controller, child: builder(c)),
      );
    },
  );
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.child, this.controller});

  final Widget child;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final grabber = Center(
      child: Container(width: 36, height: 5, margin: const EdgeInsets.only(top: 8, bottom: 14), decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(3))),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Glass(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            shadow: false,
            child: controller == null
                ? SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [grabber, child])))
                : ListView(controller: controller, padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [grabber, child]),
          ),
        ),
      ),
    );
  }
}
