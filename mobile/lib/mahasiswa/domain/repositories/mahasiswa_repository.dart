// ============================================================================
// File: lib/mahasiswa/domain/repositories/mahasiswa_repository.dart
// Lapisan: DOMAIN (Repositories) - Kontrak interface abstrak untuk akses data
// ============================================================================

// Mengimpor entitas Mahasiswa dari lapisan domain yang sama
import '../entities/mahasiswa.dart';

// Abstract class MahasiswaRepository berfungsi sebagai kontrak interface
// Lapisan domain tidak peduli bagaimana data diambil (API, SQLite, atau Memory)
abstract class MahasiswaRepository {
  // Kontrak method untuk mengambil semua data mahasiswa dan mengembalikan List<Mahasiswa>
  List<Mahasiswa> ambilSemua();

  // Kontrak method untuk mengecek apakah NIM tertentu sudah terdaftar (mengembalikan boolean true/false)
  bool nimSudahAda(String nim);

  // Kontrak method untuk menambahkan objek data Mahasiswa baru ke dalam penyimpanan
  void tambah(Mahasiswa mahasiswa);

  // Kontrak method untuk menghapus data mahasiswa berdasarkan string nim yang diberikan
  void hapus(String nim);
}
