import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sumber_sira/utils/photo_enhance.dart';
import 'package:sumber_sira/utils/photo_io.dart';

// Uji jalur lengkap foto sungguhan: baca foto bawah air bawaan aplikasi, analisis, susun perbaikan, lalu simpan jadi PNG.
void main() {
  testWidgets('foto bawah air bawaan: decode, analisis, perbaikan, dan simpan PNG', (tester) async {
    await tester.runAsync(() async {
      final bytes = File('assets/images/onboarding-bawah-air.jpg').readAsBytesSync();

      final image = await decodePhoto(bytes);
      expect(image.width, greaterThan(0));
      expect(image.width, lessThanOrEqualTo(2048));

      final stats = await analyzeImage(image);
      expect(stats.luma, inInclusiveRange(0, 255));
      expect(stats.high[0], greaterThanOrEqualTo(stats.low[0]));

      // Foto bawah air: biasanya dominan biru-hijau.
      final plan = planEnhancement(stats, EnhancePreset.bawahAir);
      final matrix = colorMatrix(plan, .7);
      expect(matrix, hasLength(20));

      final png = await renderPng(image, matrix);
      expect(png.length, greaterThan(1000));
      // Tanda tangan file PNG.
      expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);

      // Hasilnya dibaca ulang dan ukurannya sama dengan foto yang diproses.
      final back = await decodePhoto(png, maxSide: 4096);
      expect(back.width, image.width);
      expect(back.height, image.height);
    });
  });

  testWidgets('foto rusak melempar error (ditangkap layar sebagai pesan)', (tester) async {
    await tester.runAsync(() async {
      await expectLater(decodePhoto(File('pubspec.yaml').readAsBytesSync()), throwsA(anything));
    });
  });
}
