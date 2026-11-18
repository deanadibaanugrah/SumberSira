// ============================================================================
// File: lib/mahasiswa/data/repositories/mahasiswa_repository_memory.dart
// Lapisan: DATA (Repositories) - Implementasi konkret kontrak repository
// ============================================================================

// Mengimpor entitas Mahasiswa dari domain
import '../../domain/entities/mahasiswa.dart';
// Mengimpor kontrak interface MahasiswaRepository dari domain
import '../../domain/repositories/mahasiswa_repository.dart';

// Class MahasiswaRepositoryMemory mengimplementasikan interface MahasiswaRepository
// Lapisan data bergantung pada domain (Dependency Inversion Principle), bukan sebaliknya
class MahasiswaRepositoryMemory implements MahasiswaRepository {
  // Properti privat _data: list dinamis yang menyimpan objek Mahasiswa secara in-memory
  // Diisi dengan data inisial awal (Andi & Budi) untuk keperluan simulasi praktikum
  final List<Mahasiswa> _data = [
    const Mahasiswa(nim: '001', nama: 'Andi'),
    const Mahasiswa(nim: '002', nama: 'Budi'),
  ];

  // Mengimplementasikan method ambilSemua() dari interface MahasiswaRepository
  // Mengembalikan List unmodifiable (read-only view) agar list internal tidak dapat dimodifikasi langsung dari luar
  @override
  List<Mahasiswa> ambilSemua() => List.unmodifiable(_data);

  // Mengimplementasikan method nimSudahAda() dari interface MahasiswaRepository
  // Menggunakan fungsi any() untuk memeriksa apakah ada elemen di _data dengan nim yang cocok
  @override
  bool nimSudahAda(String nim) => _data.any((m) => m.nim == nim);

  // Mengimplementasikan method tambah() dari interface MahasiswaRepository
  // Menambahkan objek mahasiswa baru ke dalam list _data
  @override
  void tambah(Mahasiswa mahasiswa) {
    _data.add(mahasiswa);
  }

  // Mengimplementasikan method hapus() dari interface MahasiswaRepository
  // Menghapus elemen dari list _data di mana atribut nim sama persis dengan nim yang dicari
  @override
  void hapus(String nim) {
    _data.removeWhere((m) => m.nim == nim);
  }
}

