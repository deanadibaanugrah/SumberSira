import '../models/ticket.dart';

// Data contoh (tanpa backend). Angkanya sama dengan desain Figma dan web admin.
class DummyData {
  // Pilihan perkiraan jam datang di form tiket (DropdownButton).
  static const arrivalSlots = ['08.00 - 10.00', '10.00 - 12.00', '12.00 - 14.00', '14.00 - 16.00'];

  // Prediksi keramaian per jam (persen kapasitas) untuk grafik di Home dan Live Crowd.
  static const forecast = [('08', 15), ('10', 50), ('12', 90), ('14', 85), ('16', 40)];

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
      Ticket(code: 'TK-${n++}', name: 'Kel. Hidayat', adults: 4, parking: Parking.mobil, boughtAt: '09.50'),
      Ticket(code: 'TK-${n++}', name: 'Andi S.', adults: 2, parking: Parking.motor, boughtAt: '10.02'),
      Ticket(code: 'TK-${n++}', name: 'Kel. Saputra', adults: 5, parking: Parking.mobil, status: TicketStatus.out, boughtAt: '06.30', checkInAt: '07.58'),
    ];
    return list;
  }
}
