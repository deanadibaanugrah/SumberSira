// ============================================================================
// File: test/mahasiswa_test.dart
// Unit & Widget Test untuk Praktikum Pertemuan 10 (MVVM & Clean Architecture)
// Menguji 6 skenario pengujian dari modul praktikum (Tabel Halaman 6 & 12)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

// Import Clean Architecture
import 'package:sumber_sira/mahasiswa/data/repositories/mahasiswa_repository_memory.dart';
import 'package:sumber_sira/mahasiswa/domain/usecases/ambil_mahasiswa.dart';
import 'package:sumber_sira/mahasiswa/domain/usecases/hapus_mahasiswa.dart';
import 'package:sumber_sira/mahasiswa/domain/usecases/tambah_mahasiswa.dart';
import 'package:sumber_sira/mahasiswa/presentation/viewmodels/mahasiswa_viewmodel.dart' as clean_vm;

// Import MVVM Tradisional
import 'package:sumber_sira/mahasiswa_mvvm/repositories/mahasiswa_repository.dart' as mvvm_repo;
import 'package:sumber_sira/mahasiswa_mvvm/viewmodels/mahasiswa_viewmodel.dart' as mvvm_vm;

void main() {
  group('1. Pengujian Modul Clean Architecture (Percobaan 5 - 10)', () {
    late MahasiswaRepositoryMemory repository;
    late clean_vm.MahasiswaViewModel vm;

    setUp(() {
      repository = MahasiswaRepositoryMemory();
      vm = clean_vm.MahasiswaViewModel(
        ambilMahasiswa: AmbilMahasiswa(repository),
        tambahMahasiswa: TambahMahasiswa(repository),
        hapusMahasiswa: HapusMahasiswa(repository),
      );
    });

    test('Uji 1: Buka aplikasi -> Data inisial Andi (001) dan Budi (002) tampil', () {
      expect(vm.daftar.length, 2);
      expect(vm.daftar[0].nim, '001');
      expect(vm.daftar[0].nama, 'Andi');
      expect(vm.daftar[1].nim, '002');
      expect(vm.daftar[1].nama, 'Budi');
    });

    test('Uji 2: Tambah 003 dan Citra -> Citra berhasil masuk ke daftar', () {
      vm.tambah('003', 'Citra');
      expect(vm.pesanError, isNull);
      expect(vm.daftar.length, 3);
      expect(vm.daftar.last.nama, 'Citra');
      expect(vm.daftar.last.nim, '003');
    });

    test('Uji 3: Tambah dengan NIM atau Nama kosong -> Muncul pesan error wajib diisi', () {
      vm.tambah('', 'Citra');
      expect(vm.pesanError, 'NIM dan nama wajib diisi');

      vm.tambah('003', '  ');
      expect(vm.pesanError, 'NIM dan nama wajib diisi');
    });

    test('Uji 4: Tambah dengan NIM 001 yang sudah ada -> Muncul pesan error NIM sudah digunakan', () {
      vm.tambah('001', 'Andi Duplikat');
      expect(vm.pesanError, 'NIM sudah digunakan');
    });

    test('Uji 5: Hapus mahasiswa Budi (002) -> Budi terhapus dari daftar', () {
      vm.hapus('002');
      expect(vm.daftar.length, 1);
      expect(vm.daftar.any((m) => m.nim == '002'), isFalse);
    });
  });

  group('2. Pengujian Modul MVVM Tradisional (Percobaan 1 - 4)', () {
    late mvvm_repo.MahasiswaRepository repository;
    late mvvm_vm.MahasiswaViewModel vm;

    setUp(() {
      repository = mvvm_repo.MahasiswaRepository();
      vm = mvvm_vm.MahasiswaViewModel(repository);
    });

    test('Uji 1: Data awal memuat Andi dan Budi', () {
      expect(vm.daftar.length, 2);
      expect(vm.daftar[0].nama, 'Andi');
    });

    test('Uji 2: Tambah mahasiswa baru via ViewModel', () {
      vm.tambah('003', 'Citra');
      expect(vm.pesanError, isNull);
      expect(vm.daftar.length, 3);
    });

    test('Uji 3 & 4: Validasi input kosong dan duplikasi NIM', () {
      vm.tambah('', '');
      expect(vm.pesanError, 'NIM dan nama wajib diisi');

      vm.tambah('001', 'Andi Lagi');
      expect(vm.pesanError, 'NIM sudah digunakan');
    });

    test('Uji 5: Hapus mahasiswa', () {
      vm.hapus('001');
      expect(vm.daftar.length, 1);
      expect(vm.daftar.first.nim, '002');
    });
  });
}

