// ============================================================================
// File: lib/mahasiswa/domain/entities/mahasiswa.dart
// Lapisan: DOMAIN (Entities) - Inti aturan bisnis dan model data murni
// ============================================================================

// Mendefinisikan class Mahasiswa sebagai entitas murni tanpa dependensi framework
class Mahasiswa {
  // Properti nim: nomor induk mahasiswa bertipe String (bersifat immutable / tidak dapat diubah setelah dibuat)
  final String nim;

  // Properti nama: nama lengkap mahasiswa bertipe String (bersifat immutable)
  final String nama;

  // Constructor const: memungkinkan pembuatan instance konstan di memori untuk efisiensi
  // required memastikan nilai nim dan nama wajib diisi saat objek Mahasiswa diinstansiasi
  const Mahasiswa({
    required this.nim,  // Wajib menyertakan parameter nim bertipe String
    required this.nama, // Wajib menyertakan parameter nama bertipe String
  });
}

