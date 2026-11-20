import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'glass.dart';
import 'motion.dart';

// Latar semua layar: Abu Muda, supaya kartu putih terlihat jelas.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: AppColors.abuMuda, child: child);
}

// Isi halaman turunan yang bisa digulir: lebar maksimal 480 (HP), 600 (tablet), 720 (desktop) di tengah, margin 20.
// Isi boleh lewat di belakang nav bar dan bar bawah kaca, jadi jaraknya diambil dari MediaQuery.padding.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 28),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width >= 1000 ? 720 : (width >= 700 ? 600 : 480),
        ),
        child: ListView(
          padding:
              padding + EdgeInsets.only(top: inset.top, bottom: inset.bottom),
          children: children,
        ),
      ),
    );
  }
}

// Kerangka tab utama: header gelap ikut tergulir; setelah judul besar lewat,
// muncul bar kaca dengan judul kecil (seperti large title iOS yang mengecil).
// overlay = elemen mengambang di atas isi (mis. chatbot atau CTA), bottomExtra = ruang tambahan di bawah isi.
class TabPage extends StatefulWidget {
  const TabPage({
    super.key,
    required this.title,
    required this.header,
    required this.children,
    this.overlay,
    this.bottomExtra = 0,
    this.lightHeader = false,
  });

  final String title;
  final Widget header;
  final List<Widget> children;
  final Widget? overlay;
  final double bottomExtra;
  // true bila header berlatar terang (ikon status bar gelap sejak awal).
  final bool lightHeader;

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final _scroll = ScrollController();
  final _headerKey = GlobalKey();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      // Bar kaca muncul saat bagian bawah header sudah sampai di bawah bar (tinggi bar 44 + status bar).
      final header = _headerKey.currentContext?.size?.height ?? 160;
      final bar = MediaQuery.paddingOf(context).top + 44;
      final collapsed = _scroll.offset > header - bar - 8;
      if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context);
    // Ikon status bar putih di atas header gelap, gelap saat bar kaca terang muncul.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (_collapsed || widget.lightHeader)
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                controller: _scroll,
                padding: EdgeInsets.only(
                  bottom: inset.bottom + 28 + widget.bottomExtra,
                ),
                children: [
                  KeyedSubtree(key: _headerKey, child: widget.header),
                  // Tiap isi diberi margin 20, kecuali yang dibungkus FullBleed (mis. carousel selebar layar).
                  for (final child in widget.children)
                    child is FullBleed
                        ? child.child
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.margin,
                            ),
                            child: child,
                          ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_collapsed,
              child: AnimatedOpacity(
                opacity: _collapsed ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: _CollapsedBar(title: widget.title),
              ),
            ),
          ),
          ?widget.overlay,
        ],
      ),
    );
  }
}

// Penanda isi TabPage yang tampil selebar layar tanpa margin samping.
class FullBleed extends StatelessWidget {
  const FullBleed({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

// Bar kaca terang dengan judul kecil di tengah (muncul saat isi tab digulir).
class _CollapsedBar extends StatelessWidget {
  const _CollapsedBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final solid = MediaQuery.highContrastOf(context);
    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: solid ? Colors.white : AppColors.glass,
        border: const Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 44,
          child: Center(child: Text(title, style: AppText.headline)),
        ),
      ),
    );
    return ClipRect(
      child: solid
          ? bar
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: bar,
            ),
    );
  }
}

// Header tab utama: gradien Latar Mobile (Hijau Tua ke Ink), judul besar serif,
// keterangan satu baris, dan isi tambahan (opsional). Tingginya menyesuaikan isi tiap tab.
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.child,
    this.photo,
    this.light = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;
  // Foto latar header (aset). Tanpa foto, header memakai gradien hijau.
  final String? photo;
  // light = judul langsung di atas latar Abu Muda tanpa blok berwarna (mis. Galeri).
  final bool light;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 16;
    if (light) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpace.margin,
          top + 8,
          AppSpace.margin,
          4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text(title, style: AppText.display(32))),
                ?trailing,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.subheadline,
              ),
            ],
            if (child != null) ...[const SizedBox(height: 16), child!],
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: photo == null ? AppColors.heroGradient : null,
        color: photo == null ? null : AppColors.forest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          if (photo != null) ...[
            Positioned.fill(child: Image.asset(photo!, fit: BoxFit.cover)),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.photoScrimTop),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.margin,
              top,
              AppSpace.margin,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppText.display(32, color: Colors.white),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.footnote.copyWith(color: AppColors.putih72),
                  ),
                ],
                if (child != null) ...[const SizedBox(height: 20), child!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kontrol bersegmen gaya iOS di atas header gelap: track kaca, pilihan aktif putih dengan teks Hijau Tua.
// Kapsul putih meluncur dengan pegas ke segmen yang dipilih.
class HeaderSegments extends StatelessWidget {
  const HeaderSegments({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 24,
      shadow: false,
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 40,
        child: Stack(
          children: [
            Positioned.fill(
              child: LiquidPill(
                index: index,
                count: labels.length,
                decoration: BoxDecoration(
                  color: AppColors.forest,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Row(
              children: [
                for (final (i, label) in labels.indexed)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == index,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: PressScale(
                          scale: .94,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              style: AppText.footnote.copyWith(
                                fontWeight: FontWeight.w600,
                                color: i == index
                                    ? Colors.white
                                    : AppColors.abu,
                              ),
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
