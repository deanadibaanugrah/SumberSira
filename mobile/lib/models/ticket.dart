// Status tiket masuk, beserta label yang tampil di layar.
enum TicketStatus {
  waiting('Belum masuk'),
  inside('Di dalam'),
  out('Keluar');

  const TicketStatus(this.label);
  final String label;
}

// Pilihan parkir beserta tarifnya.
enum Parking {
  none('Tidak', 0),
  motor('Motor', 3000),
  mobil('Mobil', 10000),
  bus('Bus', 20000);

  const Parking(this.label, this.price);
  final String label;
  final int price;
}

// Satu tiket masuk online. Harga tiket Rp5.000 per orang usia 3 tahun ke atas, balita gratis.
class Ticket {
  Ticket({
    required this.code,
    required this.name,
    required this.adults,
    this.kids = 0,
    this.whatsapp = '',
    this.parking = Parking.none,
    this.status = TicketStatus.waiting,
    required this.boughtAt,
    this.checkInAt,
    this.mine = false,
  });

  static const int pricePerPerson = 5000;

  final String code;
  final String name;
  final String whatsapp;
  final int adults;
  final int kids;
  final Parking parking;
  final String boughtAt;
  final bool mine;
  TicketStatus status;
  String? checkInAt;

  int get people => adults + kids;
  int get total => adults * pricePerPerson + parking.price;
}
