// ============================================================================
// File: lib/mahasiswa/domain/usecases/hapus_mahasiswa.dart
// Lapisan: DOMAIN (Use Cases) - Menangani logika bisnis penghapusan data
// ============================================================================

// Mengimpor interface MahasiswaRepository untuk melakukan operasi penghapusan
import '../repositories/mahasiswa_repository.dart';

// Class Use Case HapusMahasiswa: bertanggung jawab mendelegasikan penghapusan mahasiswa berdasarkan NIM
class HapusMahasiswa {
  // Referensi abstrak ke interface repository
  final MahasiswaRepository repository;

  // Constructor menerima dependensi interface repository
  HapusMahasiswa(this.repository);

  // Method execute: menerima nim mahasiswa yang akan dihapus lalu mengeksekusi method hapus() pada repository
  void execute(String nim) => repository.hapus(nim);
}

