// ============================================================================
// File: lib/mahasiswa_mvvm/models/mahasiswa.dart
// Lapisan: MODEL (MVVM Tradisional) - Mendeskripsikan bentuk data
// ============================================================================

// Class Mahasiswa: model representasi data mahasiswa
class Mahasiswa {
  // Atribut nim bertipe String yang nilainya tidak dapat diubah (immutable)
  final String nim;

  // Atribut nama bertipe String yang nilainya tidak dapat diubah (immutable)
  final String nama;

  // Konstruktor konstan dengan parameter wajib (required) untuk nim dan nama
  const Mahasiswa({
    required this.nim,  // Wajib menyertakan nim
    required this.nama, // Wajib menyertakan nama
  });
}

