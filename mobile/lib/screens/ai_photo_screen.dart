import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';
import '../utils/photo_enhance.dart';
import '../utils/photo_io.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';

// AI Photo Studio: memperbagus foto dari galeri atau kamera secara otomatis, seperti tombol "Auto" di aplikasi edit foto
// profesional tetapi tidak berlebihan. Foto dianalisis (warna, kecerahan, kontras), lalu warnanya diseimbangkan dan
// dihidupkan. Pengguna mengatur kekuatan dan gaya, membandingkan dengan foto asli, lalu menyimpan atau membagikan hasilnya.
// Semua diproses di HP, foto tidak diunggah ke server.
class AiPhotoScreen extends StatefulWidget {
  const AiPhotoScreen({super.key});

  @override
  State<AiPhotoScreen> createState() => _AiPhotoScreenState();
}

class _AiPhotoScreenState extends State<AiPhotoScreen> {
  static const _repo = 'https://raw.githubusercontent.com/deanadibaanugrah/SumberSira/main/mobile/assets/images';

  final _picker = ImagePicker();
  ui.Image? _image;
  PhotoStats? _stats;
  EnhancePlan? _plan;
  EnhancePreset _preset = EnhancePreset.alami;
  // [P4 Slider] Kekuatan perbaikan 0 sampai 100: 0 = foto asli, 100 = perbaikan penuh.
  double _strength = 70;
  // [P4 Switch] Tampilkan geseran perbandingan dengan foto asli (true) atau hanya hasilnya (false).
  bool _compare = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  List<double>? get _matrix => _plan == null ? null : colorMatrix(_plan!, _strength / 100);

  // Membaca foto, menganalisisnya, lalu menyusun rencana perbaikan sesuai gaya yang dipilih.
  Future<void> _load(Uint8List bytes) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final image = await decodePhoto(bytes);
      final stats = await analyzeImage(image);
      if (!mounted) return;
      final old = _image;
      setState(() {
        _image = image;
        _stats = stats;
        _plan = planEnhancement(stats, _preset);
        _busy = false;
      });
      old?.dispose();
    } catch (e, st) {
      debugPrint('AI Photo Studio: foto gagal dibaca: $e\n$st');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Foto tidak bisa dibaca. Coba foto lain (JPG, PNG, atau WebP).';
      });
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return;
      await _load(await file.readAsBytes());
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = source == ImageSource.camera ? 'Kamera tidak bisa dibuka di perangkat ini.' : 'Galeri tidak bisa dibuka.');
    }
  }

  // Foto bawah air bawaan aplikasi, untuk mencoba tanpa memilih foto sendiri.
  Future<void> _useSample() async {
    final data = await rootBundle.load('assets/images/onboarding-bawah-air.jpg');
    // Hanya bagian milik foto ini (di web, ByteData bisa berupa potongan dari buffer yang lebih besar).
    await _load(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _setPreset(EnhancePreset p) {
    setState(() {
      _preset = p;
      if (_stats != null) _plan = planEnhancement(_stats!, p);
    });
  }

  // Menyimpan hasil sebagai PNG lewat lembar bagikan sistem (bisa disimpan ke galeri atau dikirim ke WhatsApp).
  Future<void> _share() async {
    final image = _image, matrix = _matrix;
    if (image == null || matrix == null || _busy) return;
    setState(() => _busy = true);
    try {
      final png = await renderPng(image, matrix);
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(png, mimeType: 'image/png', name: 'foto-sumber-sira.png')],
        text: 'Foto diperbagus dengan AI Photo Studio Sumber Sira',
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(kIsWeb ? 'Bagikan belum didukung di browser ini. Coba lewat aplikasi di HP.' : 'Foto belum bisa disimpan. Coba lagi.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(title: 'AI Photo Studio'),
      body: AppBackground(
        child: ResponsiveBody(children: [
          if (image == null) _empty() else _CompareView(image: image, matrix: _matrix!, compare: _compare),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator(minHeight: 3)),
          if (_error != null)
            Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: AppText.footnote.copyWith(color: AppColors.coral))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: TintedButton(label: 'Galeri', icon: CupertinoIcons.photo, onPressed: _busy ? null : () => _pick(ImageSource.gallery))),
            const SizedBox(width: 10),
            Expanded(child: TintedButton(label: 'Kamera', icon: CupertinoIcons.camera, onPressed: _busy ? null : () => _pick(ImageSource.camera))),
          ]),
          const SizedBox(height: 8),
          TextButton(onPressed: _busy ? null : _useSample, child: const Text('Coba dengan foto contoh bawah air')),
          if (image != null && _stats != null) ...[
            _diagnosis(_stats!),
            GroupedList(top: 12, indent: 16, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(CupertinoIcons.slider_horizontal_3, size: 20, color: AppColors.leaf),
                    const SizedBox(width: 14),
                    const Expanded(child: Text('Kekuatan', style: AppText.body)),
                    Text('${_strength.round()}%', style: AppText.number(17, color: AppColors.forest)),
                  ]),
                  // onChanged dijalankan selama Slider digeser; setState() memperbarui foto seketika.
                  Slider(value: _strength, max: 100, divisions: 20, label: '${_strength.round()}%', onChanged: (v) => setState(() => _strength = v)),
                  const SizedBox(height: 2),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    for (final p in EnhancePreset.values)
                      ChoiceChip(
                        label: Text(p.label, style: AppText.footnote.copyWith(fontWeight: FontWeight.w600, color: _preset == p ? AppColors.forest : AppColors.ink)),
                        selected: _preset == p,
                        onSelected: (_) => _setPreset(p),
                        selectedColor: AppColors.leaf12,
                        showCheckmark: false,
                        side: BorderSide(color: _preset == p ? AppColors.leaf : AppColors.line),
                      ),
                  ]),
                  Padding(padding: const EdgeInsets.only(top: 8, bottom: 6), child: Text(_preset.hint, style: AppText.caption)),
                ]),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 2, 12, 2),
                value: _compare,
                onChanged: (v) => setState(() => _compare = v),
                secondary: const Icon(CupertinoIcons.square_split_2x1, size: 20, color: AppColors.leaf),
                title: const Text('Bandingkan dengan foto asli', style: AppText.body),
              ),
            ]),
            const SizedBox(height: 14),
            PrimaryButton(label: 'Simpan atau Bagikan', icon: CupertinoIcons.share, loading: _busy, onPressed: _share),
          ],
          GroupedList(
            header: 'Cara kerja',
            footer: 'Foto diproses di HP kamu dan tidak diunggah ke server.',
            children: [
              for (final (i, step) in const [
                'Pilih foto dari galeri atau ambil dengan kamera.',
                'Aplikasi menganalisis warna, kecerahan, dan kontras, lalu menyusun perbaikan otomatis seperti tombol Auto di aplikasi edit foto profesional.',
                'Atur kekuatan dan gaya sampai terlihat natural, bandingkan dengan foto asli, lalu simpan atau bagikan.',
              ].indexed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 20, child: Text('${i + 1}', style: AppText.number(17, weight: FontWeight.w700, color: AppColors.forest))),
                    const SizedBox(width: 16),
                    Expanded(child: Text(step, style: AppText.subheadline.copyWith(color: AppColors.ink))),
                  ]),
                ),
            ],
          ),
          const SectionTitle('Galeri Komunitas'),
          Row(children: [
            for (var i = 1; i <= 3; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 1 ? 0 : 6, right: i == 3 ? 0 : 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      // [P4 Image.network] Foto diambil langsung dari internet (repo GitHub proyek).
                      // Kalau gagal dimuat (mis. tanpa internet), errorBuilder memakai foto lokal (Image.asset).
                      child: Image.network(
                        '$_repo/komunitas-$i.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset('assets/images/komunitas-$i.jpg', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ]),
      ),
    );
  }

  // Tampilan awal sebelum ada foto.
  Widget _empty() => AspectRatio(
        aspectRatio: 4 / 3,
        child: AppCard(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(CupertinoIcons.sparkles, size: 34, color: AppColors.leaf),
            const SizedBox(height: 12),
            const Text('Pilih foto untuk diperbagus', style: AppText.headline),
            const SizedBox(height: 4),
            Text('Warna lebih hidup dan jernih, tetap natural', textAlign: TextAlign.center, style: AppText.footnote),
          ]),
        ),
      );

  // Keterangan kondisi foto hasil analisis, mis. "Warna terlalu biru".
  Widget _diagnosis(PhotoStats stats) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Hasil analisis foto', style: AppText.subheadline),
            const SizedBox(height: 8),
            for (final d in diagnose(stats))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(padding: EdgeInsets.only(top: 3), child: Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 15, color: AppColors.leaf)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(d, style: AppText.footnote.copyWith(color: AppColors.ink))),
                ]),
              ),
          ]),
        ),
      );
}

// Foto dengan geseran perbandingan: sisi kiri foto asli, sisi kanan hasil. Geser garisnya untuk membandingkan.
class _CompareView extends StatefulWidget {
  const _CompareView({required this.image, required this.matrix, required this.compare});

  final ui.Image image;
  final List<double> matrix;
  final bool compare;

  @override
  State<_CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends State<_CompareView> {
  double _split = .5;

  @override
  Widget build(BuildContext context) {
    final ratio = (widget.image.width / widget.image.height).clamp(.75, 1.5).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: ratio,
        child: LayoutBuilder(builder: (context, box) {
          final x = box.maxWidth * _split;
          return GestureDetector(
            onHorizontalDragUpdate: widget.compare ? (d) => setState(() => _split = (_split + d.delta.dx / box.maxWidth).clamp(.04, .96)) : null,
            child: Stack(fit: StackFit.expand, children: [
              // Hasil perbaikan (di bawah).
              ColorFiltered(colorFilter: ColorFilter.matrix(widget.matrix), child: RawImage(image: widget.image, fit: BoxFit.cover)),
              if (widget.compare) ...[
                // Foto asli hanya terlihat di sebelah kiri garis.
                ClipRect(clipper: _LeftClipper(x), child: RawImage(image: widget.image, fit: BoxFit.cover)),
                Positioned(left: x - 1, top: 0, bottom: 0, child: Container(width: 2, color: Colors.white)),
                Positioned(
                  left: x - 18,
                  top: box.maxHeight / 2 - 18,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 8)]),
                    child: const Icon(CupertinoIcons.arrow_left_right, size: 18, color: AppColors.forest),
                  ),
                ),
                Positioned(left: 10, bottom: 10, child: _tag('Asli')),
                Positioned(right: 10, bottom: 10, child: _tag('Hasil')),
              ] else
                Positioned(right: 10, bottom: 10, child: _tag('Hasil')),
            ]),
          );
        }),
      ),
    );
  }

  Widget _tag(String label) => Glass(
        radius: 14,
        shadow: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(label, style: AppText.caption.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
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
