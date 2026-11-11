import 'dart:math';
import 'dart:typed_data';

// Perbaikan foto otomatis untuk AI Photo Studio. Kodenya murni hitungan (tanpa Flutter) supaya mudah diuji.
//
// Cara kerjanya mirip tombol "Auto" di aplikasi edit foto profesional:
//  1. Foto dianalisis: sebaran warna per saluran (merah, hijau, biru), kecerahan, kontras, dan kepekatan warna.
//  2. Dari analisis dibuat satu rencana perbaikan: meregangkan tingkat gelap-terang tiap warna (seperti Auto Levels),
//     menyeimbangkan warna yang berat sebelah (misalnya foto bawah air yang terlalu biru), menyesuaikan kecerahan,
//     menambah sedikit kontras untuk foto berkabut, dan menghidupkan warna yang pucat.
//  3. Rencana dijadikan satu matriks warna (4x5) yang dipakai ColorFilter. Slider kekuatan mencampur foto asli dan hasil.
// Semua langkah dibatasi (tidak ada nilai ekstrem) supaya hasilnya natural dan tidak berlebihan.

// Pilihan gaya. Tiap gaya hanya mengubah batas kewajaran, bukan caranya.
enum EnhancePreset {
  alami('Alami', 'Perbaikan halus, warna tetap mirip aslinya'),
  cerah('Cerah', 'Lebih terang dan hidup, cocok untuk foto siang hari'),
  bawahAir('Bawah air', 'Mengurangi dominan biru dan kabut air');

  const EnhancePreset(this.label, this.hint);
  final String label;
  final String hint;

  // Penguatan maksimum tiap warna, seberapa kuat warna yang berat sebelah dikoreksi, batas kepekatan warna,
  // target kepekatan, kontras dasar, dan target kecerahan rata-rata.
  double get maxGain => switch (this) { alami => 1.30, cerah => 1.35, bawahAir => 1.65 };
  double get castWeight => switch (this) { alami => .30, cerah => .40, bawahAir => .85 };
  double get maxSaturation => switch (this) { alami => 1.18, cerah => 1.30, bawahAir => 1.22 };
  double get targetSaturation => switch (this) { alami => .36, cerah => .42, bawahAir => .38 };
  double get baseContrast => switch (this) { alami => 1.04, cerah => 1.07, bawahAir => 1.06 };
  double get targetLuma => switch (this) { alami => 108, cerah => 118, bawahAir => 112 };
}

// Hasil analisis sebuah foto.
class PhotoStats {
  const PhotoStats({required this.mean, required this.low, required this.high, required this.luma, required this.lumaLow, required this.lumaHigh, required this.saturation});

  // Rata-rata, batas gelap (persentil 1%), dan batas terang (persentil 99%) tiap saluran R, G, B (0 sampai 255).
  final List<double> mean;
  final List<double> low;
  final List<double> high;
  // Kecerahan rata-rata, serta batas gelap dan terangnya.
  final double luma;
  final double lumaLow;
  final double lumaHigh;
  // Kepekatan warna rata-rata (0 sampai 1).
  final double saturation;

  // Selisih terang-gelap: makin kecil makin datar atau berkabut.
  double get range => lumaHigh - lumaLow;
}

// Menganalisis piksel RGBA (4 byte per piksel). Piksel hampir transparan dilewati.
PhotoStats analyzePixels(Uint8List rgba) {
  final hist = List.generate(3, (_) => List.filled(256, 0));
  final lumaHist = List.filled(256, 0);
  final sum = [0.0, 0.0, 0.0];
  var satSum = 0.0, lumaSum = 0.0, n = 0;
  for (var i = 0; i + 3 < rgba.length; i += 4) {
    if (rgba[i + 3] < 16) continue;
    final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2];
    hist[0][r]++;
    hist[1][g]++;
    hist[2][b]++;
    final y = (0.2126 * r + 0.7152 * g + 0.0722 * b).round().clamp(0, 255);
    lumaHist[y]++;
    sum[0] += r;
    sum[1] += g;
    sum[2] += b;
    lumaSum += y;
    final mx = max(r, max(g, b)), mn = min(r, min(g, b));
    satSum += mx == 0 ? 0 : (mx - mn) / mx;
    n++;
  }
  if (n == 0) {
    return const PhotoStats(mean: [128, 128, 128], low: [0, 0, 0], high: [255, 255, 255], luma: 128, lumaLow: 0, lumaHigh: 255, saturation: 0);
  }
  double percentile(List<int> h, double p) {
    final target = n * p;
    var acc = 0;
    for (var v = 0; v < 256; v++) {
      acc += h[v];
      if (acc >= target) return v.toDouble();
    }
    return 255;
  }

  return PhotoStats(
    mean: [for (final s in sum) s / n],
    low: [for (final h in hist) percentile(h, .01)],
    high: [for (final h in hist) percentile(h, .99)],
    luma: lumaSum / n,
    lumaLow: percentile(lumaHist, .01),
    lumaHigh: percentile(lumaHist, .99),
    saturation: satSum / n,
  );
}

// Keterangan singkat tentang kondisi foto, ditampilkan ke pengguna.
List<String> diagnose(PhotoStats s) {
  final out = <String>[];
  if (s.mean[0] < s.mean[2] * .65 && s.mean[2] > s.mean[1] * .95) out.add('Warna terlalu biru, khas foto bawah air');
  if (s.range < 150) out.add('Kontras rendah atau berkabut');
  if (s.luma < 90) out.add('Agak gelap');
  if (s.luma > 175) out.add('Agak terlalu terang');
  if (s.saturation < .22) out.add('Warna kurang hidup');
  return out.isEmpty ? ['Foto sudah cukup seimbang, perbaikan dibuat halus'] : out;
}

// Rencana perbaikan hasil analisis (sebelum dicampur dengan kekuatan).
class EnhancePlan {
  const EnhancePlan({required this.gain, required this.offset, required this.brightness, required this.contrast, required this.saturation});

  // Penguat dan penggeser tiap saluran R, G, B (offset dalam skala 0 sampai 255).
  final List<double> gain;
  final List<double> offset;
  // Geseran kecerahan (skala 0 sampai 255), pengali kontras di sekitar abu-abu tengah, dan pengali kepekatan warna.
  final double brightness;
  final double contrast;
  final double saturation;
}

const _blackPoint = 12.0, _whitePoint = 243.0;
const _lumaW = [0.2126, 0.7152, 0.0722];

EnhancePlan planEnhancement(PhotoStats s, EnhancePreset preset) {
  final gain = List.filled(3, 1.0);
  final offset = List.filled(3, 0.0);

  // 1. Penguat (seperti Auto Levels): regangkan rentang tiap saluran supaya mengisi [12, 243], dibatasi agar tidak berlebihan.
  final mid = [for (var c = 0; c < 3; c++) (s.low[c] + s.high[c]) / 2];
  for (var c = 0; c < 3; c++) {
    final range = max(s.high[c] - s.low[c], 40.0);
    gain[c] = ((_whitePoint - _blackPoint) / range).clamp(1.0, preset.maxGain);
  }

  // 2. Geseran: tiap saluran digeser supaya bagian tengah rentangnya mendekati titik tengah bersama. Ini yang menyeimbangkan
  //    warna yang berat sebelah (mis. foto bawah air yang biru). castWeight = seberapa jauh digeser (sebagian saja untuk
  //    foto biasa, supaya warna asli seperti hijau daun tidak ikut bergeser). Titik tengah bersama sedikit ditarik ke tengah.
  final avgMid = (mid[0] + mid[1] + mid[2]) / 3;
  final center = avgMid + .35 * (127.5 - avgMid);
  for (var c = 0; c < 3; c++) {
    final target = mid[c] * (1 - preset.castWeight) + center * preset.castWeight;
    offset[c] = (target - gain[c] * mid[c]).clamp(-160.0, 60.0);
  }

  // 3. Kecerahan: dekatkan rata-rata ke target, tapi hanya sebagian dan dengan batas.
  var luma = 0.0;
  for (var c = 0; c < 3; c++) {
    luma += _lumaW[c] * (s.mean[c] * gain[c] + offset[c]);
  }
  final diff = preset.targetLuma - luma;
  final brightness = diff.abs() < 6 ? 0.0 : (diff * .6).clamp(-22.0, 28.0);

  // 4. Kontras: sedikit lebih banyak untuk foto yang datar atau berkabut.
  final hazy = ((150 - s.range) / 150).clamp(0.0, 1.0);
  final contrast = preset.baseContrast + hazy * .06;

  // 5. Warna: hidupkan warna yang pucat, tanpa melewati batas gaya.
  final saturation = (1 + (preset.targetSaturation - s.saturation) * 1.4).clamp(1.0, preset.maxSaturation);

  return EnhancePlan(gain: gain, offset: offset, brightness: brightness, contrast: contrast, saturation: saturation);
}

// Matriks warna 4x5 (20 angka) untuk ColorFilter.matrix. strength 0 = foto asli, 1 = perbaikan penuh.
// Urutan perhitungan: penguat dan geseran tiap warna, kecerahan, kontras di sekitar abu-abu tengah (128), lalu kepekatan warna.
List<double> colorMatrix(EnhancePlan p, double strength) {
  final k = strength.clamp(0.0, 1.0);
  double mix(double target) => 1 + (target - 1) * k;

  // m = matriks 3x3, t = geseran 3 angka.
  var m = [
    [mix(p.gain[0]), 0.0, 0.0],
    [0.0, mix(p.gain[1]), 0.0],
    [0.0, 0.0, mix(p.gain[2])],
  ];
  var t = [for (var c = 0; c < 3; c++) p.offset[c] * k + p.brightness * k];

  final c = mix(p.contrast);
  m = [for (final row in m) [for (final v in row) v * c]];
  t = [for (final v in t) v * c + 128 * (1 - c)];

  final s = mix(p.saturation);
  final sat = [
    for (var r = 0; r < 3; r++) [for (var col = 0; col < 3; col++) _lumaW[col] * (1 - s) + (r == col ? s : 0.0)],
  ];
  final m2 = [
    for (var r = 0; r < 3; r++)
      [for (var col = 0; col < 3; col++) sat[r][0] * m[0][col] + sat[r][1] * m[1][col] + sat[r][2] * m[2][col]],
  ];
  final t2 = [for (var r = 0; r < 3; r++) sat[r][0] * t[0] + sat[r][1] * t[1] + sat[r][2] * t[2]];

  return [
    ...m2[0], 0, t2[0], //
    ...m2[1], 0, t2[1],
    ...m2[2], 0, t2[2],
    0, 0, 0, 1, 0,
  ];
}

// Menerapkan matriks ke satu piksel (hasil dibatasi 0 sampai 255). Dipakai untuk pengujian.
List<double> applyMatrix(List<double> m, double r, double g, double b) => [
      for (var row = 0; row < 3; row++) (m[row * 5] * r + m[row * 5 + 1] * g + m[row * 5 + 2] * b + m[row * 5 + 4]).clamp(0.0, 255.0),
    ];
