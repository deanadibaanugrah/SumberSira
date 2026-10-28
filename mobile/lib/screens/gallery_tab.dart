import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass.dart';

typedef _Photo = ({String image, String title, String owner, bool ai});

// Tab Galeri: foto kiriman pengunjung yang sudah disetujui admin (menu Galeri & Konten di web admin).
// Foto pertama tampil besar, sisanya grid dua kolom. Ketuk foto untuk melihat lebih besar dan bisa di-zoom.
class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  // Penampil foto layar penuh berlatar Ink: InteractiveViewer = bisa dicubit untuk zoom dan digeser.
  void _open(BuildContext context, _Photo photo) {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.ink,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: AppColors.ink,
        child: Stack(children: [
          Positioned.fill(child: InteractiveViewer(maxScale: 4, child: SizedBox.expand(child: Image.asset(photo.image, fit: BoxFit.contain)))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GlassIconButton(icon: CupertinoIcons.xmark, tooltip: 'Tutup', tone: GlassTone.dark, onPressed: () => Navigator.pop(context)),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 16),
              child: Glass(
                tone: GlassTone.dark,
                radius: 20,
                shadow: false,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(photo.title, style: AppText.headline.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Foto dari ${photo.owner}${photo.ai ? ' · AI Enhanced' : ''}', style: AppText.footnote.copyWith(color: AppColors.putih72)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = DummyData.gallery.first;
    final rest = DummyData.gallery.skip(1).toList();
    return TabPage(
      title: 'Galeri',
      header: TabHeader(
        title: 'Galeri',
        subtitle: 'Foto pengunjung dan suasana Sumber Sira',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: AppColors.kaca, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.kaca)),
          child: Text('${DummyData.gallery.length} foto', style: AppText.footnote.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
      children: [
        const SizedBox(height: 20),
        _hero(context, first),
        const SizedBox(height: 24),
        // [P3 GridView] Dua kolom foto; shrinkWrap karena berada di dalam ListView.
        LayoutBuilder(builder: (context, box) {
          final w = (box.maxWidth - 12) / 2;
          return GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 18,
            crossAxisSpacing: 12,
            childAspectRatio: w / (w + 48),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            children: [for (final p in rest) _tile(context, p)],
          );
        }),
      ],
    );
  }

  // Foto utama: besar, dengan judul di panel kaca.
  Widget _hero(BuildContext context, _Photo p) => Pressable(
        onTap: () => _open(context, p),
        semanticLabel: 'Buka foto ${p.title}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 280,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(p.image, fit: BoxFit.cover),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Glass(
                  radius: 18,
                  shadow: false,
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(p.title, style: AppText.headline),
                    const SizedBox(height: 2),
                    Text(p.owner, style: AppText.footnote),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      );

  // Satu foto di grid: foto persegi, label AI Enhanced (bila ada), lalu judul dan pengirim di bawahnya.
  Widget _tile(BuildContext context, _Photo p) => Pressable(
        onTap: () => _open(context, p),
        semanticLabel: 'Buka foto ${p.title}',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(p.image, fit: BoxFit.cover),
                if (p.ai)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Glass(
                      radius: 12,
                      shadow: false,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(CupertinoIcons.sparkles, size: 12, color: AppColors.leaf),
                        const SizedBox(width: 4),
                        Text('AI Enhanced', style: AppText.caption.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.subheadline.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
          Text(p.owner, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.footnote),
        ]),
      );
}
