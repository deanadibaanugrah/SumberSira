// ============================================================================
// File: lib/mahasiswa/domain/usecases/ambil_mahasiswa.dart
// Lapisan: DOMAIN (Use Cases) - Kasus penggunaan spesifik untuk mengambil data
// ============================================================================

// Mengimpor entitas Mahasiswa sebagai tipe return
import '../entities/mahasiswa.dart';
// Mengimpor kontrak interface MahasiswaRepository untuk abstraksi dependensi
import '../repositories/mahasiswa_repository.dart';

// Class Use Case AmbilMahasiswa: membungkus satu alur logika bisnis spesifik (mengambil seluruh daftar mahasiswa)
class AmbilMahasiswa {
  // Menyimpan referensi interface repository yang diinjeksi melalui konstruktor
  final MahasiswaRepository repository;

  // Constructor menerima instance implementasi dari interface MahasiswaRepository (Dependency Inversion)
  AmbilMahasiswa(this.repository);

  // Method execute: titik eksekusi use case, memanggil ambilSemua() dari repository dan mengembalikan List<Mahasiswa>
  List<Mahasiswa> execute() => repository.ambilSemua();
}
