// ============================================================================
// File: lib/mahasiswa/domain/usecases/tambah_mahasiswa.dart
// Lapisan: DOMAIN (Use Cases) - Menjalankan aturan bisnis penambahan data
// ============================================================================

// Mengimpor entitas Mahasiswa untuk membentuk data baru
import '../entities/mahasiswa.dart';
// Mengimpor interface MahasiswaRepository untuk menyimpan data
import '../repositories/mahasiswa_repository.dart';

// Class Use Case TambahMahasiswa: memusatkan aturan validasi bisnis saat menambahkan mahasiswa baru
class TambahMahasiswa {
  // Referensi abstrak ke interface repository data
  final MahasiswaRepository repository;

  // Constructor menerima dependensi interface repository
  TambahMahasiswa(this.repository);

  // Method execute: menerima input nim dan nama mentah dari presentation layer
  void execute(String nim, String nama) {
    // Menghilangkan spasi kosong di awal dan akhir teks nim
    nim = nim.trim();
    // Menghilangkan spasi kosong di awal dan akhir teks nama
    nama = nama.trim();

    // Aturan Bisnis 1: Memvalidasi apakah NIM atau Nama kosong
    if (nim.isEmpty || nama.isEmpty) {
      // Melemparkan exception ArgumentError jika ada isian wajib yang kosong
      throw ArgumentError('NIM dan nama wajib diisi');
    }

    // Aturan Bisnis 2: Memvalidasi apakah NIM sudah pernah digunakan sebelumnya di repository
    if (repository.nimSudahAda(nim)) {
      // Melemparkan exception StateError jika ditemukan duplikasi NIM
      throw StateError('NIM sudah digunakan');
    }

    // Jika seluruh validasi bisnis lolos, buat entitas Mahasiswa baru dan simpan ke repository
    repository.tambah(Mahasiswa(nim: nim, nama: nama));
  }
}

