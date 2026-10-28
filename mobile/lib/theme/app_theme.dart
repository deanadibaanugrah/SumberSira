import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Palet warna Sumber Sira (terkunci, sama dengan papan Color Palette di Figma).
// Tidak boleh menambah warna baru; turunan hanya berupa transparansi yang tercantum di bawah.
class AppColors {
  static const forest = Color(0xFF1B4332); // Hijau Tua: header, judul, sorotan grafik, tombol primer
  static const leaf = Color(0xFF40916C); // Hijau Daun: menu aktif, ikon, grafik, status Sepi
  static const ink = Color(0xFF172321); // Ink: teks utama, kode QR
  static const abu = Color(0xFF4B5A57); // Abu: teks sekunder
  static const abuMuda = Color(0xFFF5F6F5); // Abu Muda: latar halaman
  static const coral = Color(0xFFE07A5F); // Coral: status Ramai, tolak, keluhan

  // Turunan yang diizinkan (transparansi dari warna di atas, bukan warna baru).
  static const kaca = Color(0x1FFFFFFF); // Kartu Kaca: Putih 12% di atas latar gelap
  static const putih72 = Color(0xB8FFFFFF); // Teks sekunder di latar gelap: Putih 72%
  static const leaf30 = Color(0x4D40916C); // Hijau Daun 30%: batang dan track grafik
  static const leaf12 = Color(0x1F40916C); // Hijau Daun 12%: latar ikon terpilih, pill, chip
  static const line = Color(0x1A172321); // Garis: Ink 10%

  // Token Liquid Glass (lapisan navigasi), tetap dari palet + transparansi.
  static const glass = Color(0xB8FFFFFF); // kaca di atas latar terang: Putih 72%
  static const glassEdge = Color(0x80FFFFFF); // garis tepi kaca: Putih 50%
  static const glassTint = Color(0xD91B4332); // CTA primer kaca: Hijau Tua 85%

  // Latar Mobile: gradien Hijau Tua ke Ink, dipakai header tab utama.
  static const headerGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [forest, ink]);
}

// Ukuran dan jarak bersama: margin layar 20, jarak antar bagian 28, padding kartu 16.
class AppSpace {
  static const margin = 20.0;
  static const section = 28.0;
  static const card = 16.0;
  static const radius = 20.0;
  // Tinggi tab bar mengambang dan jarak dari tepi bawah.
  static const tabBar = 64.0;
  static const tabGap = 12.0;
}

// Skala huruf mengikuti Dynamic Type iOS. Teks memakai Inter (pengganti SF Pro);
// serif Fraunces hanya untuk judul besar tab dan angka hero.
class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  static TextStyle largeTitle({Color color = Colors.white}) =>
      GoogleFonts.fraunces(fontSize: 34, height: 41 / 34, fontWeight: FontWeight.w700, color: color, letterSpacing: -.3);

  // Angka hero, mis. "62%", "Rp45.000", "4.8". Digit sama lebar supaya angka tidak bergeser.
  static TextStyle hero(double size, {Color color = AppColors.forest}) =>
      GoogleFonts.fraunces(fontSize: size, height: 1.05, fontWeight: FontWeight.w700, color: color, fontFeatures: _tabular);

  static const title2 = TextStyle(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -.3);
  static const headline = TextStyle(fontSize: 17, height: 22 / 17, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -.2);
  static const body = TextStyle(fontSize: 17, height: 22 / 17, fontWeight: FontWeight.w400, color: AppColors.ink, letterSpacing: -.2);
  static const subheadline = TextStyle(fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w400, color: AppColors.abu, letterSpacing: -.1);
  static const footnote = TextStyle(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w400, color: AppColors.abu);
  static const caption = TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: AppColors.abu);
  static const tabLabel = TextStyle(fontSize: 10.5, height: 1.2, fontWeight: FontWeight.w600);

  // Harga dan jam: angka sama lebar.
  static TextStyle number(double size, {FontWeight weight = FontWeight.w600, Color color = AppColors.ink}) =>
      TextStyle(fontSize: size, fontWeight: weight, color: color, fontFeatures: _tabular, letterSpacing: -.2);
}

// Tema aplikasi: hanya mode terang, warna dari palet terkunci.
class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forest,
        onPrimary: Colors.white,
        secondary: AppColors.leaf,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: AppColors.ink,
        error: AppColors.coral,
        onError: AppColors.ink,
        outline: AppColors.line,
        outlineVariant: AppColors.line,
        surfaceTint: Colors.transparent,
      ),
    );
    final field = OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none);
    final selected = WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.leaf : AppColors.abu);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.abuMuda,
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.leaf12,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      iconTheme: const IconThemeData(color: AppColors.leaf, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: AppText.body.copyWith(color: AppColors.abu),
        labelStyle: AppText.subheadline,
        floatingLabelStyle: AppText.footnote.copyWith(color: AppColors.forest, fontWeight: FontWeight.w600),
        prefixIconColor: AppColors.abu,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: field,
        enabledBorder: field,
        focusedBorder: field.copyWith(borderSide: const BorderSide(color: AppColors.leaf, width: 1.5)),
        errorBorder: field.copyWith(borderSide: const BorderSide(color: AppColors.coral, width: 1.5)),
        focusedErrorBorder: field.copyWith(borderSide: const BorderSide(color: AppColors.coral, width: 1.5)),
        // Teks error memakai Ink supaya terbaca; garis Coral menandai kolom yang salah.
        errorStyle: AppText.footnote.copyWith(color: AppColors.ink),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, space: 1, thickness: 1),
      radioTheme: RadioThemeData(fillColor: selected),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.leaf : Colors.white),
        side: const BorderSide(color: AppColors.abu, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      // Switch bergaya iOS: kenop putih besar, track Hijau Daun saat aktif.
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        thumbIcon: const WidgetStatePropertyAll(Icon(null)),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.leaf : AppColors.line),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.leaf,
        inactiveTrackColor: AppColors.leaf30,
        thumbColor: Colors.white,
        overlayColor: AppColors.leaf12,
        valueIndicatorColor: AppColors.forest,
        trackHeight: 4,
        thumbShape: const GlassThumbShape(),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.leaf),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBarrierColor: AppColors.line,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        barrierColor: AppColors.line,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.forest,
        contentTextStyle: AppText.subheadline.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      popupMenuTheme: PopupMenuThemeData(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }
}

// Kenop slider gaya iOS: lingkaran putih bergaris tepi Ink 10% dan bayangan kaca tipis.
class GlassThumbShape extends SliderComponentShape {
  const GlassThumbShape();

  static const _radius = 13.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(_radius);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    final circle = Path()..addOval(Rect.fromCircle(center: center, radius: _radius));
    canvas.drawShadow(circle, AppColors.ink, 3, false);
    canvas.drawCircle(center, _radius, Paint()..color = Colors.white);
    canvas.drawCircle(center, _radius, Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
  }
}
