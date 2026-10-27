import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Latar semua layar: hijau sangat muda yang lembut, supaya kartu putih terlihat jelas.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(color: AppColors.surface, child: child);
}

// Isi halaman yang bisa digulir dan tetap rapi di semua ukuran layar:
// lebar maksimal 480 di tengah (tablet/web), padding samping 20, aman dari notch (SafeArea).
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.children, this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 28)});

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

// Isi tab (Tiket & Booking, Galeri, Profil): header hijau tua yang ikut tergulir, lalu isi berpadding 20.
// Lebar tetap maksimal 480 seperti ResponsiveBody.
class TabBody extends StatelessWidget {
  const TabBody({super.key, required this.header, required this.children});

  final Widget header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
          header,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ]),
      ),
    );
  }
}

// Header hijau tua dengan sudut bawah membulat: judul, keterangan, dan isi tambahan (opsional).
// Bagian atasnya memberi ruang status bar (notch).
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, this.subtitle, this.trailing, this.child, this.bottomGap = 20});

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomGap),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 18, 20, 24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.forest, Color(0xFF245A43)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTheme.display(26, color: Colors.white)),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: TextStyle(fontSize: 13, color: AppColors.white(.8), height: 1.4)),
              ],
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
        if (child != null) ...[const SizedBox(height: 18), child!],
      ]),
    );
  }
}
