import '../models/review.dart';
import '../models/ticket.dart';

// Data contoh (tanpa backend). Angkanya sama dengan desain Figma dan web admin.
class DummyData {
  // Pilihan perkiraan jam datang di form tiket (DropdownButton).
  static const arrivalSlots = ['08.00 - 10.00', '10.00 - 12.00', '12.00 - 14.00', '14.00 - 16.00'];

  // Pilihan jam booking sewa dan wahana, selang 1 jam (format "08-09" ditampilkan "08.00 - 09.00").
  static const bookingSlots = ['08-09', '09-10', '10-11', '11-12', '12-13', '13-14', '14-15', '15-16'];

  // Prediksi jumlah pengunjung per jam hari ini (kapasitas 300 orang), untuk grafik di Beranda.
  // Sama dengan prediksi per jam di web admin (CROWD_FORECAST, persen x 300).
  static const hourlyForecast = [
    ('08', 30), ('09', 60), ('10', 135), ('11', 225), ('12', 285),
    ('13', 270), ('14', 240), ('15', 120), ('16', 45),
  ];

  // Banner geser di Beranda: tiap foto punya label dan teks sendiri.
  static const slides = [
    (image: 'assets/images/hero-sawah.jpg', label: 'SUMBER SIRA', title: 'Kunjungan Jernih Tanpa Antre', text: 'Wisata mata air di tengah sawah Desa Putukrejo, Malang.'),
    (image: 'assets/images/onboarding-air-jernih.jpg', label: 'MATA AIR ALAMI', title: 'Air Jernih dari Sumber Asli', text: 'Berenang dan main air bareng ikan wader lokal.'),
    (image: 'assets/images/onboarding-kereta-sawah.jpg', label: 'WAHANA', title: 'Kereta Sawah & Wahana Seru', text: 'Sewa ban, ATV, dan flying fox lewat menu Tiket & Booking.'),
    (image: 'assets/images/onboarding-bawah-air.jpg', label: 'AI PHOTO STUDIO', title: 'Foto Bawah Air Lebih Jernih', text: 'Rencana fitur AI untuk memperbaiki warna foto bawah air.'),
    (image: 'assets/images/komunitas-2.jpg', label: 'TIKET ONLINE', title: 'Beli Tiket, Tanpa Antre', text: 'Rp5.000 per orang, tunjukkan QR di pintu masuk.'),
  ];

  // Foto di menu Galeri: kiriman pengunjung yang sudah disetujui admin (Galeri & Konten).
  static const gallery = [
    (image: 'assets/images/komunitas-2.jpg', title: 'Kolam batu mata air', owner: 'Kel. Ahmad', ai: false),
    (image: 'assets/images/onboarding-bawah-air.jpg', title: 'Snorkeling bawah air', owner: 'Dimas P.', ai: true),
    (image: 'assets/images/onboarding-air-jernih.jpg', title: 'Main air di aliran jernih', owner: 'Joko Didi', ai: false),
    (image: 'assets/images/onboarding-kereta-sawah.jpg', title: 'Naik kereta sawah', owner: 'Rombongan TK Pelangi', ai: false),
    (image: 'assets/images/komunitas-1.jpg', title: 'Sudut kolam di bawah pohon', owner: 'Ibu Sari K.', ai: true),
    (image: 'assets/images/hero-sawah.jpg', title: 'Hamparan sawah dan gazebo', owner: 'Bu Rani S.', ai: false),
    (image: 'assets/images/komunitas-3.jpg', title: 'Saluran air di tepi sawah', owner: 'Kel. Hartono', ai: false),
    (image: 'assets/images/sawah-sumber-sira.jpg', title: 'Pematang dan irigasi', owner: 'Komunitas Gowes', ai: false),
    (image: 'assets/images/splash-sumber-sira.jpg', title: 'Langit mendung di Putukrejo', owner: 'Karang Taruna', ai: false),
  ];

  // Nomor WhatsApp contoh untuk mencoba riwayat di Tiket Saya.
  static const demoWhatsapp = '081234567890';

  // Tiket pengunjung lain hari ini. Yang masih di dalam berjumlah 186 orang = 62% kapasitas.
  static List<Ticket> seedTickets() {
    const inside = [
      ('Bu Rani S.', 4, Parking.mobil), ('Dimas P.', 2, Parking.motor), ('Kel. Ahmad', 6, Parking.mobil),
      ('Rombongan SMA X', 32, Parking.bus), ('Rombongan TK Pelangi', 24, Parking.bus), ('Komunitas Gowes', 12, Parking.none),
      ('Karang Taruna', 18, Parking.bus), ('Kel. Hartono', 5, Parking.mobil), ('Ibu Sari K.', 3, Parking.motor),
      ('Joko Didi', 2, Parking.motor), ('Kel. Wijaya', 4, Parking.mobil), ('PKK Putukrejo', 20, Parking.bus),
      ('Kel. Prasetyo', 6, Parking.mobil), ('Kel. Susanto', 5, Parking.mobil), ('Arisan RT 03', 43, Parking.bus),
    ];
    // [P2 var] Nilai n bisa berubah: bertambah satu untuk setiap kode tiket.
    var n = 1001;
    final list = <Ticket>[
      for (final t in inside)
        Ticket(code: 'TK-${n++}', name: t.$1, adults: t.$2, parking: t.$3, status: TicketStatus.inside, boughtAt: '07.30', checkInAt: '08.40'),
      Ticket(code: 'TK-${n++}', name: 'Kel. Hidayat', whatsapp: demoWhatsapp, adults: 4, parking: Parking.mobil, boughtAt: '09.50'),
      Ticket(code: 'TK-${n++}', name: 'Andi S.', whatsapp: '085712345678', adults: 2, parking: Parking.motor, boughtAt: '10.02'),
      Ticket(code: 'TK-${n++}', name: 'Kel. Hidayat', whatsapp: demoWhatsapp, adults: 5, parking: Parking.mobil, status: TicketStatus.out, boughtAt: '06.30', checkInAt: '07.58'),
    ];
    return list;
  }

  // Ulasan terbaru, sama dengan data di web admin (AI Insight).
  static const reviews = [
    Review(name: 'Bu Rani S.', stars: 5, text: 'Airnya jernih banget, anak-anak senang main di kolam!'),
    Review(name: 'Dimas P.', stars: 4, text: 'Spot foto oke, tapi pas siang rame banget.'),
    Review(name: 'Kel. Ahmad', stars: 5, text: 'Sewa ATV gampang lewat app, ga perlu antre.'),
  ];

  // FAQ untuk chatbot Tanya Sira, sama dengan menu Chatbot & FAQ di web admin.
  // keys = kata kunci yang dicari di pertanyaan pengunjung. Dicek dari atas ke bawah.
  static const faq = [
    (keys: ['riwayat', 'whatsapp', 'tiket saya', 'hilang'], answer: 'Buka Tiket & Booking lalu cari dengan nomor WhatsApp yang dipakai saat beli. Tidak perlu login.'),
    (keys: ['jam', 'buka', 'tutup', 'weekend', 'weekday'], answer: 'Weekday buka 08.00-16.00, weekend 08.00-17.00 ya!'),
    (keys: ['harga', 'tiket', 'htm', 'bayar masuk', 'balita'], answer: 'Tiket masuk Rp5.000 per orang untuk usia 3 tahun ke atas. Balita gratis.'),
    (keys: ['qris', 'tunai', 'cash', 'pembayaran'], answer: 'Tiket masuk bisa QRIS atau tunai di loket. Sewa dan wahana dibayar lewat QRIS.'),
    (keys: ['fasilitas', 'gazebo', 'musholla', 'kolam anak'], answer: 'Ada kolam mata air, kolam anak, gazebo, dan musholla.'),
    (keys: ['atv', 'sewa', 'ban', 'wahana', 'booking'], answer: 'Buka Tiket & Booking, pilih jam, tambah item, lalu tekan Lanjut Booking.'),
    (keys: ['parkir', 'bus', 'mobil', 'motor'], answer: 'Parkir motor 3rb, mobil 10rb, bus 20rb.'),
    (keys: ['ramai', 'sepi', 'crowd', 'penuh'], answer: 'Lihat grafik keramaian di Beranda. Biasanya paling sepi pukul 08.00-09.00 atau setelah 15.00.'),
  ];

  // Pertanyaan cepat di bawah sapaan chatbot.
  static const quickQuestions = ['Jam buka?', 'Cara sewa ATV?', 'Harga tiket?', 'Parkir bus?'];
}
