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
        backgroundColor: AppColors.forest,
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          InteractiveViewer(maxScale: 4, child: Image.asset(photo.image, fit: BoxFit.contain)),
          ListTile(
            title: Text(photo.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('Foto dari ${photo.owner}${photo.ai ? ' · AI Enhanced' : ''}', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
            trailing: IconButton(tooltip: 'Tutup', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBody(children: [
      Text('Galeri', style: AppTheme.display(22)),
      const SizedBox(height: 4),
      Text('Foto pengunjung dan suasana Sumber Sira.', style: TextStyle(fontSize: 12, color: AppColors.white(.7))),
      const SizedBox(height: 16),
      // [P3 GridView] Dua kolom foto; shrinkWrap karena berada di dalam ListView.
      GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final p in DummyData.gallery)
            Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(18),
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
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.leaf, borderRadius: BorderRadius.circular(10)),
                        child: const Text('AI Enhanced', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(p.owner, style: TextStyle(fontSize: 10, color: AppColors.white(.75))),
                    ]),
                  ),
                ]),
              ),
            ),
        ],
      ),
    ]);
  }
}
