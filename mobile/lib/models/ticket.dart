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

// Status pembayaran tiket di server. Selain paid, pembayaran masih harus dituntaskan.
enum PaymentStatus { pending, paid, failed, expired, cancelled }

// Pilihan parkir. Tarifnya tidak disimpan di aplikasi: selalu dibaca dari backend (GET /pricing)
// supaya angka di layar sama dengan yang ditagih server.
enum Parking {
  none('Tidak'),
  motor('Motor'),
  mobil('Mobil'),
  bus('Bus');

  const Parking(this.label);
  final String label;
}

// [P2 Class dan Object] Class Ticket adalah cetakan; setiap tiket yang dibuat adalah object-nya.
// Satu tiket masuk online. Harga tiket ditentukan backend, balita gratis.
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
    this.amount,
    this.paymentStatus = PaymentStatus.paid,
    this.paymentId,
    this.paymentProvider,
    this.qrString,
    this.qrUrl,
    this.expiresAt,
  });

  // Membaca tiket dari backend (POST /tickets, GET /tickets/:code, GET /tickets).
  // Harga, status pembayaran, dan data QR semuanya dari server; jam dari server (UTC) diubah ke WIB.
  factory Ticket.fromApi(Map<String, dynamic> j) {
    final pay = j['payment'] as Map<String, dynamic>?;
    return Ticket(
      code: j['code'] as String,
      name: j['name'] as String,
      whatsapp: (j['whatsapp'] as String?) ?? '',
      adults: j['adults'] as int,
      kids: (j['kids'] as int?) ?? 0,
      parking: Parking.values.byName(j['parking'] as String),
      payment: PaymentMethod.values.firstWhere(
        (v) => v.name == (pay?['method'] as String?),
        orElse: () => PaymentMethod.qris,
      ),
      arrival: (j['arrival'] as String?) ?? '',
      status: TicketStatus.values.byName(j['status'] as String),
      boughtAt: jamWib(j['createdAt'] as String),
      date: tanggalPanjang(j['visitDate'] as String),
      checkInAt: j['checkInAt'] == null
          ? null
          : jamWib(j['checkInAt'] as String),
      amount: (j['amount'] as num?)?.toInt(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (v) => v.name == (j['paymentStatus'] as String?),
        orElse: () => PaymentStatus.pending,
      ),
      paymentId: pay?['id'] as String?,
      paymentProvider: pay?['provider'] as String?,
      qrString: pay?['qrString'] as String?,
      qrUrl: pay?['qrUrl'] as String?,
      expiresAt: pay?['expiresAt'] as String?,
      mine: true,
      synced: true,
    );
  }

  // "2026-11-11T03:42:00.000Z" -> "10.42" (WIB = UTC+7, tidak bergantung zona waktu HP).
  static String jamWib(String iso) =>
      DateFormat('HH.mm')
          .format(DateTime.parse(iso).toUtc().add(const Duration(hours: 7)));

  // "2026-11-12" -> "Kamis, 12 November 2026". Butuh initializeDateFormatting('id_ID') yang sudah dipanggil di main().
  static String tanggalPanjang(String ymd) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(ymd));

  final String code;
  final String name;
  final String whatsapp;
  final int adults;
  final int kids;
  final Parking parking;
  final PaymentMethod payment;
  final String arrival;
  final String boughtAt;
  // Tanggal berlaku tiket. Kosong berarti hari ini.
  final String date;
  final bool mine;
  // True bila tiket ini tercatat di server (bisa discan petugas).
  final bool synced;
  TicketStatus status;
  // [P2 Null Safety] Tanda ? artinya boleh kosong (null) selama tiket belum discan.
  String? checkInAt;

  // Total sebenarnya dihitung server (sumber kebenaran). Null hanya bila respons server tidak memuatnya.
  final int? amount;
  // Status pembayaran di server; berubah saat polling (mis. tunai dikonfirmasi petugas di loket).
  PaymentStatus paymentStatus;
  // Data pembayaran dari server: id untuk polling, dan QR yang harus dibayar pengunjung.
  final String? paymentId;
  final String? paymentProvider;
  final String? qrString;
  final String? qrUrl;
  final String? expiresAt;

  int get people => adults + kids;
  // Null berarti server tidak mengirim total; layar menampilkan "—", bukan harga karangan.
  int? get total => amount;

  // Teks baris Pembayaran di e-tiket, sesuai metode dan status pembayaran.
  String get labelPembayaran => switch (payment) {
    PaymentMethod.qris => switch (paymentStatus) {
      PaymentStatus.paid => 'QRIS, lunas',
      PaymentStatus.expired => 'QRIS · Kedaluwarsa',
      PaymentStatus.failed || PaymentStatus.cancelled => 'QRIS · Gagal',
      _ => 'QRIS · Menunggu pembayaran',
    },
    PaymentMethod.cash =>
      paymentStatus == PaymentStatus.paid ? 'Tunai, lunas' : 'Tunai di loket',
  };
}
