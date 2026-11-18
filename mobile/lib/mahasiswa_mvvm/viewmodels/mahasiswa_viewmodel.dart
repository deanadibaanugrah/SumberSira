// ============================================================================
// File: lib/mahasiswa_mvvm/viewmodels/mahasiswa_viewmodel.dart
// Lapisan: VIEWMODEL (MVVM Tradisional) - Mengelola state, validasi, dan aksi UI
// ============================================================================

// Mengimpor ChangeNotifier dari framework Flutter
import 'package:flutter/foundation.dart';
// Mengimpor model Mahasiswa
import '../models/mahasiswa.dart';
// Mengimpor repository konkret MahasiswaRepository
import '../repositories/mahasiswa_repository.dart';

// Class MahasiswaViewModel: mengelola interaksi UI dan state daftar mahasiswa
class MahasiswaViewModel extends ChangeNotifier {
  // Properti repository yang menampung sumber data mahasiswa
  final MahasiswaRepository repository;

  // Constructor menerima instance repository konkret
  MahasiswaViewModel(this.repository);

  // Getter daftar: mengambil seluruh list mahasiswa langsung dari repository
  List<Mahasiswa> get daftar => repository.ambilSemua();

  // Variabel penampung teks pesan error (bernilai null jika tidak ada error)
  String? pesanError;

  // Method tambah: memproses penambahan data beserta validasi bisnisnya di ViewModel
  void tambah(String nim, String nama) {
    // Memangkas spasi kosong di awal dan akhir nim
    nim = nim.trim();
    // Memangkas spasi kosong di awal dan akhir nama
    nama = nama.trim();

    // Validasi 1: memeriksa apakah input kosong
    if (nim.isEmpty || nama.isEmpty) {
      pesanError = 'NIM dan nama wajib diisi';
    // Validasi 2: memeriksa apakah NIM sudah terdaftar
    } else if (repository.nimSudahAda(nim)) {
      pesanError = 'NIM sudah digunakan';
    // Jika valid, masukkan ke repository dan kosongkan pesan error
    } else {
      repository.tambah(Mahasiswa(nim: nim, nama: nama));
      pesanError = null;
    }
    // Memberitahu widget pendengar agar tampilan UI diperbarui
    notifyListeners();
  }

  // Method hapus: menghapus mahasiswa berdasarkan nim melalui repository
  void hapus(String nim) {
    // Memanggil operasi hapus pada repository
    repository.hapus(nim);
    // Reset pesan error
    pesanError = null;
    // Beritahu UI agar merender ulang daftar terbaru
    notifyListeners();
  }
}

