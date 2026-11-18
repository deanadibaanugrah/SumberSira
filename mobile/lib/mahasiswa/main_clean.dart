// ============================================================================
// File: lib/mahasiswa/main_clean.dart
// Entry point / Composition Root untuk Praktikum Clean Architecture (Langkah 10.2)
// Jalankan via: flutter run -t lib/mahasiswa/main_clean.dart -d chrome
// ============================================================================

// Mengimpor paket material design bawaan Flutter
import 'package:flutter/material.dart';

// Mengimpor implementasi konkret repository memori dari lapisan data
import 'data/repositories/mahasiswa_repository_memory.dart';
// Mengimpor use case ambil data dari lapisan domain
import 'domain/usecases/ambil_mahasiswa.dart';
// Mengimpor use case tambah data dari lapisan domain
import 'domain/usecases/tambah_mahasiswa.dart';
// Mengimpor use case hapus data dari lapisan domain
import 'domain/usecases/hapus_mahasiswa.dart';
// Mengimpor viewmodel dari lapisan presentation
import 'presentation/viewmodels/mahasiswa_viewmodel.dart';
// Mengimpor halaman UI view dari lapisan presentation
import 'presentation/views/mahasiswa_page.dart';

// Fungsi utama main() sebagai Composition Root:
// Merakit implementasi konkret repositori dan menginjeksikannya ke Use Case, ViewModel, dan View
void main() {
  // 1. Membuat instance konkret repository (sumber data memori)
  final repository = MahasiswaRepositoryMemory();

  // 2. Membuat instance ViewModel dan menginjeksikan ketiga use case yang bergantung pada repositori
  final vm = MahasiswaViewModel(
    ambilMahasiswa: AmbilMahasiswa(repository),
    tambahMahasiswa: TambahMahasiswa(repository),
    hapusMahasiswa: HapusMahasiswa(repository),
  );

  // 3. Menjalankan aplikasi Flutter dengan MaterialApp dan halaman awal MahasiswaPage
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner:
          false, // Menyembunyikan pita debug di pojok kanan atas
      home: MahasiswaPage(
        vm: vm,
      ), // Menampilkan MahasiswaPage dengan injeksi viewmodel
    ),
  );
}
