import '../utils/waktu.dart';
import 'ticket.dart';

// Satu baris pesanan di booking, mis. 2x Ban Besar @Rp10.000.
// rideId ada bila barisnya berasal dari server (katalog wahana); dipakai saat mengirim booking.
class BookingLine {
  const BookingLine({required this.name, required this.qty, required this.price, this.rideId});

  factory BookingLine.fromJson(Map<String, dynamic> json) => BookingLine(
        rideId: json['rideId'] as String?,
        name: json['name'] as String,
        qty: json['qty'] as int,
        // Server mengirim unitPrice; data contoh lama memakai price.
        price: (json['unitPrice'] as num?)?.toInt() ?? (json['price'] as num?)?.toInt() ?? 0,
      );

  final String? rideId;
  final String name;
  final int qty;
  final int price;

  int get subtotal => qty * price;
}

// Isi booking yang dibawa dari bagian Sewa & Booking ke layar Checkout (belum ada data pemesan).
// slot memakai id server, mis. "08-09"; tampilannya diubah labelJam() jadi "08.00 - 09.00".
class BookingDraft {
  const BookingDraft({required this.slot, required this.lines});

  final String slot;
  final List<BookingLine> lines;

  int get total => lines.fold(0, (sum, l) => sum + l.subtotal);
}

// Booking sewa dan wahana. Sejak integrasi backend, booking dibuat di server (POST /bookings)
// saat pengguna menekan tombol bayar di Checkout; status pembayarannya QRIS dan bisa masih pending.
class Booking {
  const Booking({
    required this.code,
    required this.name,
    required this.whatsapp,
    required this.slot,
    required this.lines,
    required this.orderedAt,
    this.slotLabel = '',
    this.date = '',
    this.amount,
    this.paymentStatus = PaymentStatus.paid,
    this.paymentId,
    this.paymentProvider,
    this.qrString,
    this.qrUrl,
    this.expiresAt,
    this.synced = false,
  });

  // Membaca booking dari backend (POST /bookings, GET /bookings, GET /bookings/:code).
  // Jam dari server (UTC) diubah ke WIB; total, baris item, dan status pembayaran semuanya dari server.
  factory Booking.fromApi(Map<String, dynamic> j) {
    final pay = j['payment'] as Map<String, dynamic>?;
    return Booking(
      code: j['code'] as String,
      name: j['name'] as String,
      whatsapp: (j['whatsapp'] as String?) ?? '',
      slot: (j['slot'] as String?) ?? '',
      slotLabel: (j['slotLabel'] as String?) ?? '',
      lines: [for (final l in (j['lines'] as List? ?? const [])) BookingLine.fromJson(l as Map<String, dynamic>)],
      orderedAt: jamWib(j['createdAt'] as String?),
      date: tanggalPanjang(j['visitDate'] as String),
      amount: (j['amount'] as num?)?.toInt(),
      paymentStatus: PaymentStatus.values.firstWhere((v) => v.name == (j['paymentStatus'] as String?), orElse: () => PaymentStatus.pending),
      paymentId: pay?['id'] as String?,
      paymentProvider: pay?['provider'] as String?,
      qrString: pay?['qrString'] as String?,
      qrUrl: pay?['qrUrl'] as String?,
      expiresAt: pay?['expiresAt'] as String?,
      synced: true,
    );
  }

  final String code;
  final String name;
  final String whatsapp;
  final String slot;
  // Label jam dari server, mis. "09.00 - 10.00". Kosong untuk data lama: diformat dari slot.
  final String slotLabel;
  final List<BookingLine> lines;
  final String orderedAt;
  // Tanggal kunjungan, mis. "Kamis, 13 November 2026". Kosong berarti hari ini.
  final String date;
  // True bila booking tercatat di server (QR-nya bisa discan petugas).
  final bool synced;
  // Total sebenarnya dihitung server. Null untuk data lama: dihitung dari baris item.
  final int? amount;
  // Status pembayaran di server; berubah saat polling (QRIS dibayar). Objek diganti utuh, bukan diubah.
  final PaymentStatus paymentStatus;
  // Data pembayaran dari server: id untuk polling dan QR yang harus dibayar.
  final String? paymentId;
  final String? paymentProvider;
  final String? qrString;
  final String? qrUrl;
  final String? expiresAt;

  int get total => amount ?? lines.fold(0, (sum, l) => sum + l.subtotal);

  // Ringkasan item, mis. "2x Ban Besar, 1x ATV".
  String get itemsText => lines.map((l) => '${l.qty}x ${l.name}').join(', ');

  // Teks baris Pembayaran di faktur (booking hanya memakai QRIS).
  String get labelPembayaran => switch (paymentStatus) {
        PaymentStatus.paid => 'QRIS, lunas',
        PaymentStatus.expired => 'QRIS · Kedaluwarsa',
        PaymentStatus.failed || PaymentStatus.cancelled => 'QRIS · Gagal',
        _ => 'QRIS · Menunggu pembayaran',
      };
}
