import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';

// Tab Galeri: foto kiriman pengunjung yang sudah disetujui admin (menu Galeri & Konten di web admin).
// Ketuk foto untuk melihat lebih besar dan bisa di-zoom.
class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  // Tampilan foto besar: InteractiveViewer = bisa dicubit untuk zoom dan digeser.
  void _open(BuildContext context, ({String image, String title, String owner, bool ai}) photo) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Latar gelap di sekitar foto seperti penampil foto pada umumnya.
          ColoredBox(
            color: AppColors.ink,
            child: InteractiveViewer(maxScale: 4, child: Center(child: Image.asset(photo.image, fit: BoxFit.contain))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(photo.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('Foto dari ${photo.owner}${photo.ai ? ' · AI Enhanced' : ''}', style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                ]),
              ),
              IconButton(
                tooltip: 'Tutup',
                style: IconButton.styleFrom(backgroundColor: AppColors.mint),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.forest),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBody(
      header: TabHeader(
        title: 'Galeri',
        subtitle: 'Foto pengunjung dan suasana Sumber Sira.',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: AppColors.white(.14), borderRadius: BorderRadius.circular(20)),
          child: Text('${DummyData.gallery.length} foto', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
      children: [
        // [P3 GridView] Dua kolom foto; shrinkWrap karena berada di dalam ListView.
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .78,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final p in DummyData.gallery)
              Material(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => _open(context, p),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset(p.image, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.ink.withValues(alpha: .85)],
                          stops: const [.45, 1],
                        ),
                      ),
                    ),
                    if (p.ai)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.auto_awesome, size: 12, color: AppColors.leaf),
                            SizedBox(width: 4),
                            Text('AI Enhanced', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.forest)),
                          ]),
                        ),
                      ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1.25)),
                        const SizedBox(height: 2),
                        Text(p.owner, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: AppColors.white(.8))),
                      ]),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
