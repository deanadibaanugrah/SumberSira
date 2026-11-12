// Status tiket masuk, beserta label yang tampil di layar.
enum TicketStatus {
  waiting('Belum masuk'),
  inside('Di dalam'),
  out('Keluar');

  const TicketStatus(this.label);
  final String label;
}

// Metode pembayaran tiket.
enum PaymentMethod {
  qris('QRIS'),
  cash('Tunai di loket');

  const PaymentMethod(this.label);
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

// [P2 Class dan Object] Class Ticket adalah cetakan; setiap tiket yang dibuat adalah object-nya.
// Satu tiket masuk online. Harga tiket Rp5.000 per orang usia 3 tahun ke atas, balita gratis.
class Ticket {
  Ticket({
    required this.code,
    required this.name,
    required this.adults,
    this.kids = 0,
    this.whatsapp = '',
    this.parking = Parking.none,
    this.payment = PaymentMethod.qris,
    this.arrival = '',
    this.status = TicketStatus.waiting,
    required this.boughtAt,
    this.date = '',
    this.checkInAt,
    this.mine = false,
  });

  // Membaca tiket yang tersimpan di perangkat (kebalikan dari toJson).
  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        code: json['code'] as String,
        name: json['name'] as String,
        whatsapp: (json['whatsapp'] as String?) ?? '',
        adults: json['adults'] as int,
        kids: (json['kids'] as int?) ?? 0,
        parking: Parking.values.byName(json['parking'] as String),
        payment: PaymentMethod.values.byName(json['payment'] as String),
        arrival: (json['arrival'] as String?) ?? '',
        status: TicketStatus.values.byName(json['status'] as String),
        boughtAt: json['boughtAt'] as String,
        date: (json['date'] as String?) ?? '',
        checkInAt: json['checkInAt'] as String?,
        mine: true,
      );

  static const int pricePerPerson = 5000;

  final String code;
  final String name;
  final String whatsapp;
  final int adults;
  final int kids;
  final Parking parking;
  final PaymentMethod payment;
  final String arrival;
  final String boughtAt;
  // Tanggal berlaku tiket. Kosong untuk data contoh, artinya hari ini.
  final String date;
  final bool mine;
  TicketStatus status;
  // [P2 Null Safety] Tanda ? artinya boleh kosong (null) selama tiket belum discan.
  String? checkInAt;

  int get people => adults + kids;
  int get total => adults * pricePerPerson + parking.price;

  // Mengubah tiket menjadi Map supaya bisa disimpan sebagai JSON di shared_preferences.
  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'whatsapp': whatsapp,
        'adults': adults,
        'kids': kids,
        'parking': parking.name,
        'payment': payment.name,
        'arrival': arrival,
        'status': status.name,
        'boughtAt': boughtAt,
        'date': date,
        'checkInAt': checkInAt,
      };
}
