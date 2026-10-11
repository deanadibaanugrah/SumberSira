import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Latar semua layar: gradasi Hijau Tua ke Ink dengan cahaya Hijau Daun di kiri bawah (sama dengan desain).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.forest, AppColors.ink]),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(center: const Alignment(-1, .5), radius: 1.1, colors: [AppColors.leaf.withValues(alpha: .35), Colors.transparent]),
        ),
        child: child,
      ),
    );
  }
}

// Isi halaman yang bisa digulir dan tetap rapi di semua ukuran layar:
// lebar maksimal 480 di tengah (tablet/web), padding samping 20, aman dari notch (SafeArea).
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.children, this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24)});

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(padding: padding, children: children),
        ),
      ),
    );
  }
}
