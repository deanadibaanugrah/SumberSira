import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sumber_sira/utils/photo_enhance.dart';

// Membuat foto RGBA sintetis: tiap piksel diambil dari fungsi (x, y) -> (r, g, b).
Uint8List image(int w, int h, List<int> Function(int x, int y) px) {
  final data = Uint8List(w * h * 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final c = px(x, y);
      final i = (y * w + x) * 4;
      data[i] = c[0];
      data[i + 1] = c[1];
      data[i + 2] = c[2];
      data[i + 3] = 255;
    }
  }
  return data;
}

// Foto bawah air buatan: kebiruan, datar (berkabut), merah hampir hilang.
Uint8List underwater() => image(64, 64, (x, y) {
      final t = (x + y) / 126; // 0..1
      return [(35 + 55 * t).round(), (70 + 70 * t).round(), (120 + 80 * t).round()];
    });

// Foto netral dengan rentang penuh dan warna cukup hidup.
Uint8List balanced() {
  final rnd = Random(7);
  return image(64, 64, (x, y) {
    final base = (x * 4).clamp(0, 255);
    return [(base + rnd.nextInt(30) - 10).clamp(0, 255), (255 - base + rnd.nextInt(30) - 10).clamp(0, 255), ((x + y) * 2).clamp(0, 255)];
  });
}

double meanOf(List<List<double>> px, int c) => px.map((p) => p[c]).reduce((a, b) => a + b) / px.length;

void main() {
  test('strength 0 menghasilkan foto asli (matriks identitas)', () {
    final plan = planEnhancement(analyzePixels(underwater()), EnhancePreset.bawahAir);
    final m = colorMatrix(plan, 0);
    expect(m, hasLength(20));
    const identity = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    for (var i = 0; i < 20; i++) {
      expect(m[i], closeTo(identity[i].toDouble(), 1e-9), reason: 'elemen $i');
    }
  });

  test('foto bawah air: merah digeser naik, biru turun, warna jadi lebih seimbang', () {
    final src = underwater();
    final stats = analyzePixels(src);
    final plan = planEnhancement(stats, EnhancePreset.bawahAir);
    expect(plan.offset[0], greaterThan(plan.offset[2]), reason: 'merah yang hilang digeser naik, biru yang dominan digeser turun');

    final m = colorMatrix(plan, 1);
    final before = <List<double>>[], after = <List<double>>[];
    for (var i = 0; i < src.length; i += 4) {
      before.add([src[i].toDouble(), src[i + 1].toDouble(), src[i + 2].toDouble()]);
      after.add(applyMatrix(m, src[i].toDouble(), src[i + 1].toDouble(), src[i + 2].toDouble()));
    }
    double spread(List<List<double>> px) {
      final means = [for (var c = 0; c < 3; c++) meanOf(px, c)];
      return means.reduce(max) - means.reduce(min);
    }

    expect(spread(after), lessThan(spread(before)), reason: 'selisih rata-rata antar warna harus mengecil');
    // Rentang terang-gelap melebar (kabut berkurang).
    final lumaBefore = analyzePixels(src).range;
    final out = Uint8List(src.length);
    for (var i = 0; i < src.length; i += 4) {
      final p = applyMatrix(m, src[i].toDouble(), src[i + 1].toDouble(), src[i + 2].toDouble());
      out[i] = p[0].round();
      out[i + 1] = p[1].round();
      out[i + 2] = p[2].round();
      out[i + 3] = 255;
    }
    expect(analyzePixels(out).range, greaterThan(lumaBefore));
  });

  test('foto yang sudah seimbang hampir tidak diubah (tidak alay)', () {
    final stats = analyzePixels(balanced());
    for (final preset in EnhancePreset.values) {
      final plan = planEnhancement(stats, preset);
      for (final g in plan.gain) {
        expect(g, inInclusiveRange(1, 1.15), reason: '${preset.name}: penguat tidak boleh jauh dari 1');
      }
      for (final o in plan.offset) {
        expect(o.abs(), lessThan(20), reason: '${preset.name}: geseran kecil untuk foto yang sudah seimbang');
      }
      expect(plan.brightness.abs(), lessThan(23));
      expect(plan.saturation, lessThanOrEqualTo(preset.maxSaturation));
    }
  });

  test('semua batas kewajaran dipatuhi untuk foto ekstrem', () {
    final extremes = {
      'hitam': image(32, 32, (x, y) => [0, 0, 0]),
      'putih': image(32, 32, (x, y) => [255, 255, 255]),
      'merah': image(32, 32, (x, y) => [200, 10, 10]),
      'abu datar': image(32, 32, (x, y) => [120, 120, 120]),
    };
    for (final MapEntry(key: name, value: src) in extremes.entries) {
      final stats = analyzePixels(src);
      for (final preset in EnhancePreset.values) {
        final plan = planEnhancement(stats, preset);
        for (final g in plan.gain) {
          expect(g, inInclusiveRange(.9, preset.maxGain), reason: '$name/${preset.name} penguat');
        }
        for (final o in plan.offset) {
          expect(o, inInclusiveRange(-160, 60), reason: '$name/${preset.name} geseran');
        }
        expect(plan.brightness, inInclusiveRange(-22, 28));
        expect(plan.contrast, inInclusiveRange(1, preset.baseContrast + .06 + 1e-9));
        expect(plan.saturation, inInclusiveRange(1, preset.maxSaturation));
        // Hasil piksel selalu di dalam 0..255 dan tidak NaN.
        for (final v in applyMatrix(colorMatrix(plan, 1), 0, 128, 255)) {
          expect(v.isNaN, isFalse);
          expect(v, inInclusiveRange(0, 255));
        }
      }
    }
  });

  test('kekuatan menengah berada di antara foto asli dan hasil penuh', () {
    final plan = planEnhancement(analyzePixels(underwater()), EnhancePreset.alami);
    final half = colorMatrix(plan, .5), full = colorMatrix(plan, 1);
    // Piksel biru-kehijauan: saluran merah naik makin besar saat kekuatan naik.
    const r = 60.0, g = 100.0, b = 150.0;
    final o0 = applyMatrix(colorMatrix(plan, 0), r, g, b)[0];
    final o1 = applyMatrix(half, r, g, b)[0];
    final o2 = applyMatrix(full, r, g, b)[0];
    expect(o0, closeTo(r, 1e-9));
    expect((o1 - o0).abs(), lessThan((o2 - o0).abs() + 1e-9));
    expect((o1 - o0).abs(), greaterThan(0));
  });

  test('keterangan kondisi foto', () {
    expect(diagnose(analyzePixels(underwater())), containsAll(['Warna terlalu biru, khas foto bawah air', 'Kontras rendah atau berkabut']));
    expect(diagnose(analyzePixels(image(16, 16, (x, y) => [20, 20, 20]))), contains('Agak gelap'));
    expect(diagnose(analyzePixels(balanced())), isNotEmpty);
  });

  test('foto kosong atau transparan tidak membuat error', () {
    final stats = analyzePixels(Uint8List(0));
    expect(stats.luma, 128);
    final plan = planEnhancement(stats, EnhancePreset.alami);
    for (final v in colorMatrix(plan, .7)) {
      expect(v.isNaN, isFalse);
    }
  });
}
