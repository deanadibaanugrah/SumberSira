// ============================================================================
// File: lib/mahasiswa/presentation/viewmodels/mahasiswa_viewmodel.dart
// Lapisan: PRESENTATION (ViewModels) - Pengelola UI State & Penghubung ke Use Case
// ============================================================================

// Mengimpor ChangeNotifier dari foundation Flutter untuk notifikasi perubahan state ke View
import 'package:flutter/foundation.dart';
// Mengimpor entitas Mahasiswa dari domain
import '../../domain/entities/mahasiswa.dart';
// Mengimpor Use Case AmbilMahasiswa
import '../../domain/usecases/ambil_mahasiswa.dart';
// Mengimpor Use Case TambahMahasiswa
import '../../domain/usecases/tambah_mahasiswa.dart';
// Mengimpor Use Case HapusMahasiswa
import '../../domain/usecases/hapus_mahasiswa.dart';

// Class MahasiswaViewModel mewarisi ChangeNotifier untuk memberitahu View saat terjadi perubahan data
class MahasiswaViewModel extends ChangeNotifier {
  // Menyimpan instance use case ambil data mahasiswa
  final AmbilMahasiswa ambilMahasiswa;
  // Menyimpan instance use case tambah data mahasiswa
  final TambahMahasiswa tambahMahasiswa;
  // Menyimpan instance use case hapus data mahasiswa
  final HapusMahasiswa hapusMahasiswa;

  // Constructor menerima injeksi ketiga use case (tidak bergantung langsung ke repository konkret)
  MahasiswaViewModel({
    required this.ambilMahasiswa,
    required this.tambahMahasiswa,
    required this.hapusMahasiswa,
  });

  // Getter daftar: mengambil daftar mahasiswa aktif dengan memanggil use case execute()
  List<Mahasiswa> get daftar => ambilMahasiswa.execute();

  // Properti pesanError: menyimpan pesan error jika validasi gagal, atau null jika validasi sukses
  String? pesanError;

  // Method tambah: dipanggil oleh View saat pengguna menekan tombol Tambah
  void tambah(String nim, String nama) {
    try {
      // Memanggil use case TambahMahasiswa untuk memvalidasi dan menambahkan data
      tambahMahasiswa.execute(nim, nama);
      // Jika berhasil tanpa melempar exception, bersihkan pesan error
      pesanError = null;
    } on ArgumentError catch (e) {
      // Menangkap ArgumentError dari use case (misal NIM/nama kosong) lalu set pesan error
      pesanError = e.message?.toString() ?? 'Input tidak valid';
    } on StateError catch (e) {
      // Menangkap StateError dari use case (misal NIM duplikat) lalu set pesan error
      pesanError = e.message;
    }
    // Memberitahu semua listener (widget pendengar seperti ListenableBuilder) agar merender ulang UI
    notifyListeners();
  }

  // Method hapus: dipanggil oleh View saat pengguna menekan ikon hapus pada salah satu baris
  void hapus(String nim) {
    // Memanggil use case HapusMahasiswa untuk menghapus data berdasarkan NIM
    hapusMahasiswa.execute(nim);
    // Reset pesan error menjadi null
    pesanError = null;
    // Beritahu UI agar memperbarui tampilan daftar terbaru
    notifyListeners();
  }
}

