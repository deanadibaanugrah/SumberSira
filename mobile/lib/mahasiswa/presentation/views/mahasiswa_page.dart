// ============================================================================
// File: lib/mahasiswa/presentation/views/mahasiswa_page.dart
// Lapisan: PRESENTATION (Views) - Menampilkan antarmuka dan menangani interaksi pengguna
// ============================================================================

// Mengimpor paket material design bawaan Flutter untuk widget UI
import 'package:flutter/material.dart';
// Mengimpor MahasiswaViewModel dari folder viewmodels sejajar
import '../viewmodels/mahasiswa_viewmodel.dart';

// Class MahasiswaPage: StatefulWidget yang mewakili halaman daftar mahasiswa
class MahasiswaPage extends StatefulWidget {
  // Properti vm: instance MahasiswaViewModel yang diinjeksi dari luar (misal dari composition root / main)
  final MahasiswaViewModel vm;

  // Constructor menerima parameter required vm dan key widget
  const MahasiswaPage({super.key, required this.vm});

  // Membuat instance State dari MahasiswaPage
  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

// Class private State untuk mengelola input controller dan lifecycle halaman
class _MahasiswaPageState extends State<MahasiswaPage> {
  // Controller untuk membaca dan mengontrol input teks NIM pada TextField
  final nimController = TextEditingController();
  // Controller untuk membaca dan mengontrol input teks Nama pada TextField
  final namaController = TextEditingController();

  // Method simpan: dipanggil saat tombol 'Tambah' ditekan pengguna
  void simpan() {
    // Memanggil method tambah pada ViewModel melalui widget.vm dengan nilai dari kedua controller
    widget.vm.tambah(nimController.text, namaController.text);
    // Jika tidak ada error setelah proses tambah berhasil
    if (widget.vm.pesanError == null) {
      // Bersihkan teks pada form input NIM
      nimController.clear();
      // Bersihkan teks pada form input Nama
      namaController.clear();
    }
  }

  // Method dispose: dipanggil saat widget dihapus dari pohon widget untuk mencegah memory leak
  @override
  void dispose() {
    // Membebaskan controller nim dari memori
    nimController.dispose();
    // Membebaskan controller nama dari memori
    namaController.dispose();
    // Membebaskan viewmodel yang diteruskan ke widget
    widget.vm.dispose();
    // Memanggil dispose milik super class
    super.dispose();
  }

  // Method build: merender struktur tampilan widget ke layar
  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar halaman (appBar dan body)
    return Scaffold(
      // AppBar di bagian atas halaman dengan judul 'Daftar Mahasiswa'
      appBar: AppBar(title: const Text('Daftar Mahasiswa')),
      // Padding membungkus seluruh konten body dengan jarak 16 pixel di semua sisi
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Column menyusun widget input, tombol, dan daftar secara vertikal dari atas ke bawah
        child: Column(
          children: [
            // TextField pertama: input untuk memasukkan NIM
            TextField(
              controller: nimController, // Menghubungkan controller NIM
              decoration: const InputDecoration(labelText: 'NIM'), // Label teks petunjuk
            ),
            // TextField kedua: input untuk memasukkan Nama Mahasiswa
            TextField(
              controller: namaController, // Menghubungkan controller Nama
              decoration: const InputDecoration(labelText: 'Nama'), // Label teks petunjuk
            ),
            // SizedBox memberi jarak vertikal setinggi 12 pixel
            const SizedBox(height: 12),
            // Tombol ElevatedButton untuk memicu aksi simpan data
            ElevatedButton(
              onPressed: simpan, // Menjalankan fungsi simpan saat ditekan
              child: const Text('Tambah'), // Label teks pada tombol
            ),
            // SizedBox memberi jarak vertikal setinggi 12 pixel
            const SizedBox(height: 12),
            // Expanded memastikan daftar mahasiswa mengisi sisa ruang layar ke bawah
            Expanded(
              // ListenableBuilder mendengarkan perubahan state dari widget.vm (ChangeNotifier)
              child: ListenableBuilder(
                listenable: widget.vm, // ViewModel yang didengarkan perubahannya
                builder: (context, child) {
                  // Mengambil data list mahasiswa terbaru dari ViewModel
                  final daftar = widget.vm.daftar;
                  // Column menampung tampilan teks error (jika ada) dan ListView
                  return Column(
                    children: [
                      // Menampilkan pesan error dengan warna merah jika pesanError tidak bernilai null
                      if (widget.vm.pesanError != null)
                        Text(
                          widget.vm.pesanError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      // Expanded membungkus ListView agar dapat discroll secara dinamis
                      Expanded(
                        // ListView.builder membangun elemen daftar secara efisien (lazy loading)
                        child: ListView.builder(
                          itemCount: daftar.length, // Jumlah item sesuai panjang list data
                          itemBuilder: (context, index) {
                            // Mengambil satu data objek Mahasiswa pada indeks saat ini
                            final m = daftar[index];
                            // ListTile menampilkan satu baris item data mahasiswa
                            return ListTile(
                              title: Text(m.nama), // Judul baris: Nama Mahasiswa
                              subtitle: Text('NIM: ${m.nim}'), // Subtitle baris: NIM
                              // Trailing: tombol ikon hapus di sisi paling kanan baris
                              trailing: IconButton(
                                icon: const Icon(Icons.delete), // Ikon tempat sampah (delete)
                                // Memanggil method hapus pada ViewModel dengan parameter nim mahasiswa ini
                                onPressed: () => widget.vm.hapus(m.nim),
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

