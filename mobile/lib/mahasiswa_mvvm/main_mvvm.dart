// ============================================================================
// File: lib/mahasiswa_mvvm/main_mvvm.dart
// Entry point untuk Praktikum MVVM Tradisional (Langkah 4.2)
// Jalankan via: flutter run -t lib/mahasiswa_mvvm/main_mvvm.dart -d chrome
// ============================================================================

// Mengimpor paket dasar Material UI Flutter
import 'package:flutter/material.dart';

// Mengimpor view halaman MahasiswaPage versi MVVM
import 'views/mahasiswa_page.dart';

// Fungsi utama aplikasi untuk menjalankan versi MVVM
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      home: MahasiswaPage(), // Menampilkan MahasiswaPage versi MVVM
    ),
  );
}
