import 'package:intl/intl.dart';

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
    this.synced = false,
  });

  // Membaca tiket dari backend (POST /tickets, GET /tickets). Jam dari server (UTC) diubah ke WIB, tanggal ke Bahasa Indonesia.
  factory Ticket.fromApi(Map<String, dynamic> j) => Ticket(
        code: j['code'] as String,
        name: j['name'] as String,
        whatsapp: (j['whatsapp'] as String?) ?? '',
        adults: j['adults'] as int,
        kids: (j['kids'] as int?) ?? 0,
        parking: Parking.values.byName(j['parking'] as String),
        payment: PaymentMethod.values.byName(j['payment'] as String),
        arrival: (j['arrival'] as String?) ?? '',
        status: TicketStatus.values.byName(j['status'] as String),
        boughtAt: jamWib(j['boughtAt'] as String),
        date: tanggalPanjang(j['visitDate'] as String),
        checkInAt: j['checkInAt'] == null ? null : jamWib(j['checkInAt'] as String),
        mine: true,
        synced: true,
      );

  // "2026-11-11T03:42:00.000Z" -> "10.42" (WIB = UTC+7, tidak bergantung zona waktu HP).
  static String jamWib(String iso) => DateFormat('HH.mm').format(DateTime.parse(iso).toUtc().add(const Duration(hours: 7)));

  // "2026-11-12" -> "Kamis, 12 November 2026". Butuh initializeDateFormatting('id_ID') yang sudah dipanggil di main().
  static String tanggalPanjang(String ymd) => DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(ymd));

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
        synced: (json['synced'] as bool?) ?? false,
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
  // True bila tiket ini tercatat di server (bisa discan petugas). False hanya untuk data contoh tanpa koneksi.
  final bool synced;
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
        'synced': synced,
      };
}
