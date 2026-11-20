import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/api_client.dart';
import '../../../data/app_state.dart';
import '../../../models/gallery.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/photo_upload.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/common.dart';
import '../../../widgets/glass.dart';
import '../../../widgets/photo_form.dart';
import '../../../widgets/motion.dart';

// Tab Galeri: foto kiriman pengunjung yang sudah disetujui admin (menu Galeri & Konten di web admin).
// Daftar dari GET /gallery; foto baru dikirim lewat POST /gallery dan menunggu persetujuan admin.
// Foto pertama tampil besar, sisanya grid dua kolom. Ketuk foto untuk melihat lebih besar dan bisa di-zoom.
class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  final _picker = ImagePicker();
  List<GalleryPhoto> _photos = const [];
  bool _loading = true;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Muat foto yang sudah disetujui dari server.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final photos = await ApiClient.fetchGallery();
      if (!mounted) return;
      setState(() {
        _photos = photos;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  // Pilih foto, isi judul dan nama, lalu unggah. Server menyimpannya sebagai "pending" sampai
  // disetujui admin, jadi foto belum muncul di daftar ini sesudah dikirim.
  Future<void> _upload() async {
    if (_uploading) return;
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
    } catch (_) {
      _snack('Galeri foto tidak bisa dibuka di perangkat ini.');
      return;
    }
    if (file == null) return;

    // Batas 4 MB dan tipe JPEG/PNG/WebP juga diperiksa di sini agar pengunjung langsung tahu.
    final masalah = await validatePhotoFile(file);
    if (!mounted) return;
    if (masalah != null) {
      _snack(masalah);
      return;
    }

    final isi = await showGlassSheet<PhotoDetails>(
      context,
      builder: (_) => PhotoForm(
        heading: 'Kirim Foto',
        hint: 'Foto akan tampil setelah disetujui admin.',
        ownerAwal: AppState.instance.myTickets.isNotEmpty
            ? AppState.instance.myTickets.first.name
            : '',
      ),
    );
    if (isi == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      await ApiClient.uploadGalleryPhoto(
        fileName: file.name,
        fileBytes: bytes,
        title: isi.title,
        owner: isi.owner,
      );
      if (!mounted) return;
      _snack(
        'Foto terkirim. Menunggu persetujuan admin sebelum tampil di galeri.',
      );
    } on ApiException catch (e) {
      // Termasuk FILE_TOO_LARGE dan UNSUPPORTED_MEDIA dari backend, sudah dalam pesan Indonesia.
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Penampil foto layar penuh berlatar Ink: InteractiveViewer = bisa dicubit untuk zoom dan digeser.
  void _open(BuildContext context, GalleryPhoto photo) {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.ink,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: AppColors.ink,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 4,
                child: SizedBox.expand(
                  child: Image.network(
                    photo.url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 48,
                        color: AppColors.putih72,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GlassIconButton(
                  icon: CupertinoIcons.xmark,
                  tooltip: 'Tutup',
                  tone: GlassTone.dark,
                  onPressed: () => Navigator.pop(context),
                ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        photo.title,
                        style: AppText.headline.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Foto dari ${photo.owner}${photo.ai ? ' · AI Enhanced' : ''}',
                        style: AppText.footnote.copyWith(
                          color: AppColors.putih72,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = _photos.isEmpty ? null : _photos.first;
    final rest = _photos.length > 1
        ? _photos.sublist(1)
        : const <GalleryPhoto>[];
    return TabPage(
      title: 'Galeri',
      lightHeader: true,
      header: TabHeader(
        light: true,
        title: 'Galeri',
        subtitle: 'Foto pengunjung dan suasana Sumber Sira',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.leaf12,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            _loading ? 'Memuat...' : '${_photos.length} foto',
            style: AppText.footnote.copyWith(
              color: AppColors.forest,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      children: [
        const SizedBox(height: 20),
        TintedButton(
          label: _uploading ? 'Mengirim foto...' : 'Kirim Foto',
          icon: CupertinoIcons.camera_fill,
          onPressed: _uploading ? null : _upload,
        ),
        if (_uploading)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: LinearProgressIndicator(minHeight: 3),
          ),
        const SizedBox(height: 6),
        Text(
          'Foto baru tampil di galeri setelah disetujui admin.',
          textAlign: TextAlign.center,
          style: AppText.footnote,
        ),
        const SizedBox(height: 20),
        // Status kosong, memuat, dan galat memakai kartu yang sama dengan isi galeri.
        if (_loading && _photos.isEmpty)
          const _InfoCard(text: 'Memuat galeri...')
        else if (_error != null && _photos.isEmpty)
          _InfoCard(
            text: 'Tidak dapat memuat galeri.',
            detail: _error,
            onRetry: _load,
          )
        else if (_photos.isEmpty)
          const _InfoCard(text: 'Belum ada foto yang disetujui.')
        else ...[
          _hero(context, first!),
          const SizedBox(height: 24),
          // [P3 GridView] Dua kolom foto; shrinkWrap karena berada di dalam ListView.
          LayoutBuilder(
            builder: (context, box) {
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
            },
          ),
          // Galat saat memuat ulang: foto terakhir tetap tampil, dengan tombol coba lagi.
          if (_error != null) ...[
            const SizedBox(height: 16),
            _InfoCard(
              text: 'Gagal memperbarui galeri. Menampilkan data terakhir.',
              detail: _error,
              onRetry: _load,
            ),
          ],
        ],
      ],
    );
  }

  // Foto utama: besar, dengan judul di panel kaca.
  Widget _hero(BuildContext context, GalleryPhoto p) => Pressable(
    onTap: () => _open(context, p),
    semanticLabel: 'Buka foto ${p.title}',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 280,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _photoImage(p, fit: BoxFit.cover),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Glass(
                radius: 18,
                shadow: false,
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.title, style: AppText.headline),
                    const SizedBox(height: 2),
                    Text(p.owner, style: AppText.footnote),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // Satu foto di grid: foto persegi, label AI Enhanced (bila ada), lalu judul dan pengirim di bawahnya.
  Widget _tile(BuildContext context, GalleryPhoto p) => Pressable(
    onTap: () => _open(context, p),
    semanticLabel: 'Buka foto ${p.title}',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _photoImage(p, fit: BoxFit.cover),
                if (p.ai)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Glass(
                      radius: 12,
                      shadow: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.sparkles,
                            size: 12,
                            color: AppColors.leaf,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI Enhanced',
                            style: AppText.caption.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          p.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.subheadline.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          p.owner,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.footnote,
        ),
      ],
    ),
  );

  // Foto dari server; bila gagal dimuat (mis. server mati), tampil latar Abu Muda dengan ikon.
  Widget _photoImage(GalleryPhoto p, {required BoxFit fit}) => Image.network(
    p.url,
    fit: fit,
    errorBuilder: (_, _, _) => ColoredBox(
      color: AppColors.abuMuda,
      child: const Center(
        child: Icon(CupertinoIcons.photo, size: 28, color: AppColors.abu),
      ),
    ),
  );
}

// Kartu status: memuat, kosong, atau galat dengan tombol coba lagi.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text, this.detail, this.onRetry});

  final String text;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppText.subheadline.copyWith(color: AppColors.ink),
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(detail!, textAlign: TextAlign.center, style: AppText.footnote),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            PressScale(
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(CupertinoIcons.refresh, size: 18),
                label: const Text('Coba lagi'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
