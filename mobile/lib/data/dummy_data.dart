// Data cadangan lokal saat server belum terjangkau: pilihan jam datang, jam booking, pertanyaan cepat chat,
// dan banner Beranda. Tiket, booking, ulasan, galeri, FAQ, serta angka keramaian sepenuhnya dari backend.
class DummyData {
  // Pilihan perkiraan jam datang di form tiket (DropdownButton).
  static const arrivalSlots = ['08.00 - 10.00', '10.00 - 12.00', '12.00 - 14.00', '14.00 - 16.00'];

  // Pilihan jam booking sewa dan wahana, selang 1 jam (format "08-09" ditampilkan "08.00 - 09.00").
  static const bookingSlots = ['08-09', '09-10', '10-11', '11-12', '12-13', '13-14', '14-15', '15-16'];

  // Banner geser di Beranda: tiap foto punya label dan teks sendiri.
  static const slides = [
    (image: 'assets/images/hero-sawah.jpg', label: 'SUMBER SIRA', title: 'Kunjungan Jernih Tanpa Antre', text: 'Wisata mata air di tengah sawah Desa Putukrejo, Malang.'),
    (image: 'assets/images/onboarding-air-jernih.jpg', label: 'MATA AIR ALAMI', title: 'Air Jernih dari Sumber Asli', text: 'Berenang dan main air bareng ikan wader lokal.'),
    (image: 'assets/images/onboarding-kereta-sawah.jpg', label: 'WAHANA', title: 'Kereta Sawah & Wahana Seru', text: 'Sewa ban, ATV, dan flying fox lewat menu Tiket & Booking.'),
    (image: 'assets/images/onboarding-bawah-air.jpg', label: 'AI PHOTO STUDIO', title: 'Foto Lebih Jernih dan Berwarna', text: 'Perbagus warna foto dari galeri HP secara otomatis.'),
    (image: 'assets/images/komunitas-2.jpg', label: 'TIKET ONLINE', title: 'Beli Tiket, Tanpa Antre', text: 'Rp5.000 per orang, tunjukkan QR di pintu masuk.'),
  ];

  // Pertanyaan cepat di bawah sapaan chatbot, dipakai sebelum GET /chat/quick-questions termuat.
  static const quickQuestions = ['Jam buka?', 'Cara sewa ATV?', 'Harga tiket?', 'Parkir bus?'];
}
