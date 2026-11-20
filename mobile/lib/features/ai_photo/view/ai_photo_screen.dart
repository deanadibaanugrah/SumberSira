import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

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

// AI Photo Studio: memperbagus foto dari galeri atau kamera. Foto diunggah ke backend (POST /ai-photo),
// server memperbaiki warna dan ketajamannya, lalu aplikasi menampilkan foto asli dan hasilnya.
// Hasil bisa disimpan/dibagikan lewat sistem, atau dibagikan ke Galeri Komunitas (menunggu persetujuan admin).
class AiPhotoScreen extends StatefulWidget {
  const AiPhotoScreen({super.key});

  @override
  State<AiPhotoScreen> createState() => _AiPhotoScreenState();
}

class _AiPhotoScreenState extends State<AiPhotoScreen> {
  static const _repo =
      'https://raw.githubusercontent.com/deanadibaanugrah/SumberSira/main/mobile/assets/images';

  final _picker = ImagePicker();
  AiPhotoResult? _result;
  // Tiga penanda terpisah agar tombol yang sedang berjalan tidak memutar tombol lain.
  bool _processing = false;
  bool _saving = false;
  bool _sharing = false;
  // True setelah hasil berhasil dibagikan ke galeri (satu job hanya boleh sekali).
  bool _shared = false;
  String? _error;

  bool get _busy => _processing || _saving || _sharing;
  String get _ownerAwal => AppState.instance.myTickets.isNotEmpty
      ? AppState.instance.myTickets.first.name
      : '';

  Future<void> _pick(ImageSource source) async {
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = source == ImageSource.camera
            ? 'Kamera tidak bisa dibuka di perangkat ini.'
            : 'Galeri tidak bisa dibuka.',
      );
      return;
    }
    if (file == null) return;

    // Batas 4 MB dan tipe JPEG/PNG/WebP sama dengan aturan backend.
    final masalah = await validatePhotoFile(file);
    if (!mounted) return;
    if (masalah != null) {
      setState(() => _error = masalah);
      return;
    }
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    await _processBytes(bytes, file.name);
  }

  // Foto bawah air bawaan aplikasi, untuk mencoba tanpa memilih foto sendiri.
  Future<void> _useSample() async {
    if (_busy) return;
    try {
      final data = await rootBundle.load(
        'assets/images/onboarding-bawah-air.jpg',
      );
      if (!mounted) return;
      // Hanya bagian milik foto ini (di web, ByteData bisa berupa potongan dari buffer yang lebih besar).
      await _processBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        'contoh-bawah-air.jpg',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Foto contoh tidak bisa dibaca.');
    }
  }

  // Unggah foto ke server; jawabannya berisi URL foto asli dan hasil perbaikan.
  Future<void> _processBytes(List<int> bytes, String fileName) async {
    setState(() {
      _processing = true;
      _error = null;
      _result = null;
      _shared = false;
    });
    try {
      final result = await ApiClient.enhancePhoto(
        fileName: fileName,
        fileBytes: bytes,
      );
      if (!mounted) return;
      setState(() {
        _processing = false;
        if (result.done) {
          _result = result;
        } else {
          // Job tersimpan tapi gagal diproses (422 PROCESSING_FAILED).
          _error = result.error ?? 'Foto belum selesai diproses. Coba lagi.';
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = e.message;
      });
    }
  }

  // Mengunduh hasil dari server lalu membukanya di lembar bagikan sistem (simpan ke galeri HP atau kirim).
  Future<void> _share() async {
    final result = _result;
    if (result == null || _busy) return;
    setState(() => _saving = true);
    try {
      final res = await http
          .get(Uri.parse(result.resultUrl))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) throw Exception('unduh gagal');
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              res.bodyBytes,
              mimeType: 'image/jpeg',
              name: 'foto-sumber-sira.jpg',
            ),
          ],
          text: 'Foto diperbagus dengan AI Photo Studio Sumber Sira',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? 'Bagikan belum didukung di browser ini. Coba lewat aplikasi di HP.'
                : 'Foto belum bisa disimpan. Coba lagi.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // Bagikan hasil AI ke Galeri Komunitas (POST /ai-photo/:id/share-to-gallery). Masuk sebagai pending.
  Future<void> _shareToGallery() async {
    final result = _result;
    if (result == null || _busy || _shared) return;
    final isi = await showGlassSheet<PhotoDetails>(
      context,
      builder: (_) => PhotoForm(
        heading: 'Bagikan ke Galeri',
        hint: 'Hasil AI akan tampil setelah disetujui admin.',
        ownerAwal: _ownerAwal,
        buttonLabel: 'Bagikan',
      ),
    );
    if (isi == null || !mounted) return;

    setState(() => _sharing = true);
    try {
      await ApiClient.shareAiPhotoToGallery(
        id: result.id,
        title: isi.title,
        owner: isi.owner,
      );
      if (!mounted) return;
      setState(() => _shared = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto dikirim ke galeri. Menunggu persetujuan admin.'),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      // DUPLICATE berarti job ini sudah pernah dibagikan; tombol tidak perlu dicoba lagi.
      if (e.code == 'DUPLICATE') setState(() => _shared = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(title: 'AI Photo Studio'),
      body: AppBackground(
        child: ResponsiveBody(
          children: [
            if (result != null)
              _BeforeAfter(
                originalUrl: result.originalUrl,
                resultUrl: result.resultUrl,
              )
            else if (_processing)
              _progress()
            else
              _empty(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: AppText.footnote.copyWith(color: AppColors.coral),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TintedButton(
                    label: 'Galeri',
                    icon: CupertinoIcons.photo,
                    onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TintedButton(
                    label: 'Kamera',
                    icon: CupertinoIcons.camera,
                    onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            PressScale(
              child: TextButton(
                onPressed: _busy ? null : _useSample,
                child: const Text('Coba dengan foto contoh bawah air'),
              ),
            ),
            if (result != null) ...[
              const SizedBox(height: 14),
              TintedButton(
                label: _shared
                    ? 'Terkirim ke Galeri'
                    : (_sharing ? 'Mengirim...' : 'Bagikan ke Galeri'),
                icon: CupertinoIcons.square_arrow_up,
                onPressed: (_busy || _shared) ? null : _shareToGallery,
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Simpan atau Bagikan',
                icon: CupertinoIcons.share,
                loading: _saving,
                onPressed: _busy ? null : _share,
              ),
              const SizedBox(height: 6),
              Text(
                'Hasil yang dibagikan ke galeri menunggu persetujuan admin.',
                textAlign: TextAlign.center,
                style: AppText.footnote,
              ),
            ],
            GroupedList(
              header: 'Cara kerja',
              footer: 'Foto diunggah ke server Sumber Sira untuk diperbaiki. Hasilnya bisa disimpan atau dibagikan ke Galeri Komunitas.',
              children: [
                for (final (i, step) in const [
                  'Pilih foto dari galeri atau ambil dengan kamera.',
                  'Server menganalisis warna, kecerahan, dan kontras, lalu memperbaikinya otomatis seperti tombol Auto di aplikasi edit foto profesional.',
                  'Bandingkan dengan foto asli, lalu simpan, bagikan, atau kirim ke Galeri Komunitas.',
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text(
                            '${i + 1}',
                            style: AppText.number(
                              17,
                              weight: FontWeight.w700,
                              color: AppColors.forest,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            step,
                            style: AppText.subheadline.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SectionTitle('Galeri Komunitas'),
            Row(
              children: [
                for (var i = 1; i <= 3; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: i == 1 ? 0 : 6,
                        right: i == 3 ? 0 : 6,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          // [P4 Image.network] Foto diambil langsung dari internet (repo GitHub proyek).
                          // Kalau gagal dimuat (mis. tanpa internet), errorBuilder memakai foto lokal (Image.asset).
                          child: Image.network(
                            '$_repo/komunitas-$i.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/komunitas-$i.jpg',
                              fit: BoxFit.cover,
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

  // Tampilan awal sebelum ada foto.
  Widget _empty() => AspectRatio(
    aspectRatio: 4 / 3,
    child: AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.sparkles, size: 34, color: AppColors.leaf),
          const SizedBox(height: 12),
          const Text('Pilih foto untuk diperbagus', style: AppText.headline),
          const SizedBox(height: 4),
          Text(
            'Warna lebih hidup dan jernih, tetap natural',
            textAlign: TextAlign.center,
            style: AppText.footnote,
          ),
        ],
      ),
    ),
  );

  // Selama server memproses foto.
  Widget _progress() => AspectRatio(
    aspectRatio: 4 / 3,
    child: AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.leaf,
            ),
          ),
          const SizedBox(height: 14),
          const Text('Memperbaiki foto di server...', style: AppText.headline),
          const SizedBox(height: 4),
          Text('Biasanya hanya beberapa detik.', style: AppText.footnote),
        ],
      ),
    ),
  );
}

// Perbandingan sebelum/sesudah dari dua URL server: sisi kiri foto asli, sisi kanan hasil.
// Geser garisnya untuk melihat bagian yang sama pada kedua foto.
class _BeforeAfter extends StatefulWidget {
  const _BeforeAfter({required this.originalUrl, required this.resultUrl});

  final String originalUrl;
  final String resultUrl;

  @override
  State<_BeforeAfter> createState() => _BeforeAfterState();
}

class _BeforeAfterState extends State<_BeforeAfter> {
  double _split = .5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: LayoutBuilder(
          builder: (context, box) {
            final x = box.maxWidth * _split;
            return GestureDetector(
              onHorizontalDragUpdate: (d) => setState(
                () => _split = (_split + d.delta.dx / box.maxWidth).clamp(
                  .04,
                  .96,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hasil perbaikan (di bawah).
                  _network(widget.resultUrl),
                  // Foto asli hanya terlihat di sebelah kiri garis.
                  ClipRect(
                    clipper: _LeftClipper(x),
                    child: _network(widget.originalUrl),
                  ),
                  Positioned(
                    left: x - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white),
                  ),
                  Positioned(
                    left: x - 18,
                    top: box.maxHeight / 2 - 18,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x33000000), blurRadius: 8),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.arrow_left_right,
                        size: 18,
                        color: AppColors.forest,
                      ),
                    ),
                  ),
                  Positioned(left: 10, bottom: 10, child: _tag('Asli')),
                  Positioned(right: 10, bottom: 10, child: _tag('Hasil')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _network(String url) => Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => ColoredBox(
      color: AppColors.abuMuda,
      child: const Center(
        child: Icon(CupertinoIcons.photo, size: 32, color: AppColors.abu),
      ),
    ),
  );

  Widget _tag(String label) => Glass(
    radius: 14,
    shadow: false,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Text(
      label,
      style: AppText.caption.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// Memotong tampilan sampai garis geser (sisi kiri saja).
class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper(this.x);

  final double x;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, x, size.height);

  @override
  bool shouldReclip(_LeftClipper old) => old.x != x;
}
