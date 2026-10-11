import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Palet warna Sumber Sira: hanya dua hijau, ditambah ink dan satu aksen coral (sama dengan Figma).
class AppColors {
  static const forest = Color(0xFF1B4332);
  static const leaf = Color(0xFF40916C);
  static const ink = Color(0xFF172321);
  static const coral = Color(0xFFE07A5F);
  static Color white(double alpha) => Colors.white.withValues(alpha: alpha);
}

// Tema aplikasi dan gaya teks: Fraunces untuk judul, Inter untuk teks, JetBrains Mono untuk angka/harga.
class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.leaf, brightness: Brightness.dark, primary: AppColors.leaf),
    );
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.white(.25)));
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ink,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: Colors.white, displayColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white(.1),
        hintStyle: TextStyle(color: AppColors.white(.55), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: AppColors.white(.7))),
        errorBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.coral)),
        focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.coral)),
        errorStyle: const TextStyle(color: AppColors.coral),
      ),
      snackBarTheme: const SnackBarThemeData(backgroundColor: AppColors.forest, contentTextStyle: TextStyle(color: Colors.white)),
    );
  }

  static TextStyle display(double size) =>
      GoogleFonts.fraunces(fontSize: size, fontWeight: FontWeight.w600, color: Colors.white, height: 1.15);

  static TextStyle mono(double size, {FontWeight weight = FontWeight.w500, Color color = Colors.white}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color);
}
