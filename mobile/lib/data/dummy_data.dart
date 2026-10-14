import '../models/review.dart';
import '../models/ticket.dart';

// Data contoh (tanpa backend). Angkanya sama dengan desain Figma dan web admin.
class DummyData {
  // Pilihan perkiraan jam datang di form tiket (DropdownButton).
  static const arrivalSlots = ['08.00 - 10.00', '10.00 - 12.00', '12.00 - 14.00', '14.00 - 16.00'];

  // Prediksi keramaian per jam (persen kapasitas) untuk grafik di Home dan Live Crowd.
  static const forecast = [('08', 15), ('10', 50), ('12', 90), ('14', 85), ('16', 40)];

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
  // keys = kata kunci yang dicari di pertanyaan pengunjung.
  static const faq = [
    (keys: ['jam', 'buka', 'tutup', 'weekend', 'weekday'], answer: 'Weekday buka 08.00-16.00, weekend 08.00-17.00 ya!'),
    (keys: ['harga', 'tiket', 'htm', 'bayar masuk', 'balita'], answer: 'Tiket masuk Rp5.000 per orang untuk usia 3 tahun ke atas. Balita gratis.'),
    (keys: ['qris', 'tunai', 'cash', 'pembayaran'], answer: 'Bisa bayar tunai atau QRIS.'),
    (keys: ['fasilitas', 'gazebo', 'musholla', 'kolam anak'], answer: 'Ada kolam mata air, kolam anak, gazebo, dan musholla.'),
    (keys: ['atv', 'sewa', 'ban', 'wahana', 'booking'], answer: 'Buka menu Sewa & Booking, pilih jam, tambah item, lalu tekan Lanjut Booking.'),
    (keys: ['parkir', 'bus', 'mobil', 'motor'], answer: 'Parkir motor 3rb, mobil 10rb, bus 20rb.'),
    (keys: ['ramai', 'sepi', 'crowd', 'penuh'], answer: 'Cek menu Live Crowd. Biasanya paling sepi pukul 08.00-09.00 atau setelah 15.00.'),
    (keys: ['riwayat', 'whatsapp', 'tiket saya', 'hilang'], answer: 'Buka Tiket Saya lalu cari dengan nomor WhatsApp yang dipakai saat beli. Tidak perlu login.'),
  ];

  // Pertanyaan cepat di bawah sapaan chatbot.
  static const quickQuestions = ['Jam buka?', 'Cara sewa ATV?', 'Harga tiket?', 'Parkir bus?'];
}
