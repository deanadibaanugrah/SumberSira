// ============================================================================
// File: lib/mahasiswa_mvvm/views/mahasiswa_page.dart
// Lapisan: VIEW (MVVM Tradisional) - Tampilan antarmuka pengguna (Percobaan 4)
// ============================================================================

// Mengimpor material widget bawaan Flutter
import 'package:flutter/material.dart';

// Mengimpor repository konkret
import '../repositories/mahasiswa_repository.dart';
// Mengimpor viewmodel
import '../viewmodels/mahasiswa_viewmodel.dart';

// Class MahasiswaPage: halaman tampilan daftar mahasiswa (MVVM)
class MahasiswaPage extends StatefulWidget {
  // Konstruktor konstan dengan key
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

// State class dari MahasiswaPage
class _MahasiswaPageState extends State<MahasiswaPage> {
  // Instance ViewModel diinisialisasi secara late final di dalam initState
  late final MahasiswaViewModel vm;
  // Controller teks untuk input NIM
  final nimController = TextEditingController();
  // Controller teks untuk input Nama
  final namaController = TextEditingController();

  // Inisialisasi awal saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();
    // Menginstansiasi ViewModel dengan MahasiswaRepository konkret
    vm = MahasiswaViewModel(MahasiswaRepository());
  }

  // Membersihkan resource controller dan viewmodel saat widget dihancurkan
  @override
  void dispose() {
    nimController.dispose();
    namaController.dispose();
    vm.dispose();
    super.dispose();
  }

  // Fungsi simpan ketika tombol tambah ditekan
  void simpan() {
    // Memanggil aksi tambah pada ViewModel
    vm.tambah(nimController.text, namaController.text);
    // Jika tidak ada pesan error (sukses), kosongkan teks form input
    if (vm.pesanError == null) {
      nimController.clear();
      namaController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Mahasiswa (MVVM)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input field untuk NIM
            TextField(
              controller: nimController,
              decoration: const InputDecoration(labelText: 'NIM'),
            ),
            // Input field untuk Nama
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 12),
            // Tombol simpan
            ElevatedButton(onPressed: simpan, child: const Text('Tambah')),
            const SizedBox(height: 12),
            // Area daftar mahasiswa yang reaktif terhadap perubahan ViewModel
            Expanded(
              child: ListenableBuilder(
                listenable: vm,
                builder: (context, child) {
                  return Column(
                    children: [
                      // Menampilkan pesan error berwarna merah bila ada
                      if (vm.pesanError != null)
                        Text(
                          vm.pesanError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      // Daftar list mahasiswa yang dapat discroll
                      Expanded(
                        child: ListView.builder(
                          itemCount: vm.daftar.length,
                          itemBuilder: (context, index) {
                            final m = vm.daftar[index];
                            return ListTile(
                              title: Text(m.nama),
                              subtitle: Text('NIM: ${m.nim}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => vm.hapus(m.nim),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
