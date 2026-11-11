import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/painting.dart';

import 'photo_enhance.dart';

// Membaca, menganalisis, dan menyimpan foto untuk AI Photo Studio (bagian yang memakai dart:ui).
// Hitungan perbaikannya ada di photo_enhance.dart.

// Membaca foto dari byte (JPG, PNG, WebP) dan memperkecil bila sisi terpanjangnya melebihi [maxSide],
// supaya foto kamera 12 MP tidak memenuhi memori HP. Orientasi EXIF ikut dipatuhi oleh decoder.
Future<ui.Image> decodePhoto(Uint8List bytes, {int maxSide = 2048}) async {
  // Browser tidak mendukung ImageDescriptor.width/height: baca penuh lalu perkecil sendiri bila perlu.
  if (kIsWeb) {
    final full = (await (await ui.instantiateImageCodec(bytes)).getNextFrame()).image;
    final longest = max(full.width, full.height);
    if (longest <= maxSide) return full;
    final scale = maxSide / longest;
    final w = max(1, (full.width * scale).round()), h = max(1, (full.height * scale).round());
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      full,
      ui.Rect.fromLTWH(0, 0, full.width.toDouble(), full.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      ui.Paint()..filterQuality = FilterQuality.high,
    );
    final small = await recorder.endRecording().toImage(w, h);
    full.dispose();
    return small;
  }
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  try {
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    try {
      final longest = max(descriptor.width, descriptor.height);
      final scale = longest > maxSide ? maxSide / longest : 1.0;
      final codec = await descriptor.instantiateCodec(
        targetWidth: max(1, (descriptor.width * scale).round()),
        targetHeight: max(1, (descriptor.height * scale).round()),
      );
      return (await codec.getNextFrame()).image;
    } finally {
      descriptor.dispose();
    }
  } finally {
    buffer.dispose();
  }
}

// Menganalisis foto: gambar diperkecil dulu (sisi terpanjang 160 px) karena sebaran warna tidak butuh semua piksel.
Future<PhotoStats> analyzeImage(ui.Image image) async {
  final scale = 160 / max(image.width, image.height);
  final w = max(1, (image.width * min(1.0, scale)).round());
  final h = max(1, (image.height * min(1.0, scale)).round());
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawImageRect(
    image,
    ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    ui.Paint()..filterQuality = FilterQuality.medium,
  );
  final small = await recorder.endRecording().toImage(w, h);
  final data = await small.toByteData(format: ui.ImageByteFormat.rawRgba);
  small.dispose();
  return analyzePixels(data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

// Menggambar foto dengan matriks warna hasil perbaikan lalu mengubahnya jadi PNG (ukuran penuh foto yang sudah dibaca).
Future<Uint8List> renderPng(ui.Image image, List<double> matrix) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawImage(
    image,
    ui.Offset.zero,
    ui.Paint()
      ..colorFilter = ui.ColorFilter.matrix(matrix)
      ..filterQuality = FilterQuality.high,
  );
  final out = await recorder.endRecording().toImage(image.width, image.height);
  final data = await out.toByteData(format: ui.ImageByteFormat.png);
  out.dispose();
  return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
