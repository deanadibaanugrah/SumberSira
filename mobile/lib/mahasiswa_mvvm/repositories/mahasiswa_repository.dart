// ============================================================================
// File: lib/mahasiswa_mvvm/repositories/mahasiswa_repository.dart
// Lapisan: REPOSITORY (MVVM Tradisional) - Penyimpan dan penyedia sumber data
// ============================================================================

// Mengimpor model Mahasiswa
import '../models/mahasiswa.dart';

// Class MahasiswaRepository: mengelola operasi penyimpanan data secara in-memory
class MahasiswaRepository {
  // Properti privat list data awal sebagai simulasi penyimpanan sementara
  final List<Mahasiswa> _data = [
    const Mahasiswa(nim: '001', nama: 'Andi'),
    const Mahasiswa(nim: '002', nama: 'Budi'),
  ];

  // Mengembalikan list unmodifiable (read-only) agar list privat tidak bisa dimutasi sembarangan
  List<Mahasiswa> ambilSemua() => List.unmodifiable(_data);

  // Menambahkan data mahasiswa baru ke dalam list privat _data
  void tambah(Mahasiswa mahasiswa) {
    _data.add(mahasiswa);
  }

  // Menghapus data mahasiswa dari list _data berdasarkan kecocokan nim
  void hapus(String nim) {
    _data.removeWhere((m) => m.nim == nim);
  }

  // Memeriksa apakah suatu nim sudah pernah ada di dalam list _data
  bool nimSudahAda(String nim) => _data.any((m) => m.nim == nim);
}

