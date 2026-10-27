import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Palet warna Sumber Sira. Identitas tetap dua hijau, ink, dan aksen coral (sama dengan Figma);
// warna terang di bawahnya untuk latar, garis, dan teks sekunder tampilan terang.
class AppColors {
  static const forest = Color(0xFF1B4332);
  static const leaf = Color(0xFF40916C);
  static const ink = Color(0xFF172321);
  static const coral = Color(0xFFE07A5F);

  // Latar halaman, kartu lembut, garis tepi, dan teks sekunder.
  static const surface = Color(0xFFF4F8F6);
  static const mint = Color(0xFFEEF5F1);
  static const pale = Color(0xFFD6E9DE);
  static const line = Color(0xFFE1EAE5);
  static const muted = Color(0xFF5E6E69);

  // Warna status: hijau muda (Sepi di atas latar gelap), kuning (Sedang, bintang ulasan),
  // dan coral tua untuk teks peringatan supaya tetap terbaca di latar putih.
  static const lightLeaf = Color(0xFF7FD1A8);
  static const sun = Color(0xFFE5A823);
  static const sunDark = Color(0xFF8A5A00);
  static const coralDark = Color(0xFFB4533B);

  static Color white(double alpha) => Colors.white.withValues(alpha: alpha);
}

// Bayangan lembut untuk kartu putih dan bar bawah.
class AppShadows {
  static const card = [BoxShadow(color: Color(0x141B4332), blurRadius: 18, offset: Offset(0, 6))];
  static const bar = [BoxShadow(color: Color(0x1A1B4332), blurRadius: 20, offset: Offset(0, -4))];
}

// Tema aplikasi dan gaya teks: Fraunces untuk judul, Inter untuk teks, JetBrains Mono untuk kode tiket.
class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.leaf,
        primary: AppColors.forest,
        secondary: AppColors.leaf,
        surface: Colors.white,
        error: AppColors.coralDark,
      ),
    );
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line));
    final selected = WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.leaf : AppColors.muted);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: display(19),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: AppColors.muted.withValues(alpha: .75), fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.forest, fontSize: 14, fontWeight: FontWeight.w600),
        prefixIconColor: AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.leaf, width: 1.6)),
        errorBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.coralDark)),
        focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.coralDark, width: 1.6)),
        errorStyle: const TextStyle(color: AppColors.coralDark, fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, space: 1, thickness: 1),
      radioTheme: RadioThemeData(fillColor: selected),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.leaf : Colors.white),
        side: const BorderSide(color: AppColors.muted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.leaf : AppColors.pale),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.leaf,
        inactiveTrackColor: AppColors.pale,
        thumbColor: AppColors.forest,
        valueIndicatorColor: AppColors.forest,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.leaf),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: AppColors.pale,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.forest,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static TextStyle display(double size, {Color color = AppColors.forest}) =>
      GoogleFonts.fraunces(fontSize: size, fontWeight: FontWeight.w600, color: color, height: 1.2);

  static TextStyle mono(double size, {FontWeight weight = FontWeight.w500, Color color = AppColors.ink}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color);

  // Harga dan angka penting: Inter tebal supaya mudah dibaca.
  static TextStyle price(double size, {Color color = AppColors.forest}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: color, letterSpacing: -.2);
}
