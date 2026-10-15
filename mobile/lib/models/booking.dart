// Satu baris pesanan di booking, mis. 2x Ban Besar @Rp10.000.
class BookingLine {
  const BookingLine({required this.name, required this.qty, required this.price});

  factory BookingLine.fromJson(Map<String, dynamic> json) =>
      BookingLine(name: json['name'] as String, qty: json['qty'] as int, price: json['price'] as int);

  final String name;
  final int qty;
  final int price;

  int get subtotal => qty * price;

  Map<String, dynamic> toJson() => {'name': name, 'qty': qty, 'price': price};
}

// Isi booking yang dibawa dari bagian Sewa & Booking ke layar Checkout (belum ada data pemesan).
class BookingDraft {
  const BookingDraft({required this.slot, required this.lines});

  final String slot;
  final List<BookingLine> lines;

  int get total => lines.fold(0, (sum, l) => sum + l.subtotal);
}

// Pesanan yang sudah diisi nama dan WhatsApp di Checkout, dibawa ke layar bayar QRIS.
// Baru disimpan menjadi Booking setelah pembayaran QRIS selesai.
class BookingRequest {
  const BookingRequest({required this.draft, required this.name, required this.whatsapp});

  final BookingDraft draft;
  final String name;
  final String whatsapp;
}

// Booking yang sudah dibayar lewat QRIS. Kodenya dipakai sebagai isi QR di invoice.
class Booking {
  const Booking({
    required this.code,
    required this.name,
    required this.whatsapp,
    required this.slot,
    required this.lines,
    required this.orderedAt,
    this.date = '',
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        code: json['code'] as String,
        name: json['name'] as String,
        whatsapp: json['whatsapp'] as String,
        slot: json['slot'] as String,
        lines: [for (final l in json['lines'] as List<dynamic>) BookingLine.fromJson(l as Map<String, dynamic>)],
        orderedAt: json['orderedAt'] as String,
        date: (json['date'] as String?) ?? '',
      );

  final String code;
  final String name;
  final String whatsapp;
  final String slot;
  final List<BookingLine> lines;
  final String orderedAt;
  final String date;

  int get total => lines.fold(0, (sum, l) => sum + l.subtotal);

  // Ringkasan item, mis. "2x Ban Besar, 1x ATV".
  String get itemsText => lines.map((l) => '${l.qty}x ${l.name}').join(', ');

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'whatsapp': whatsapp,
        'slot': slot,
        'lines': [for (final l in lines) l.toJson()],
        'orderedAt': orderedAt,
        'date': date,
      };
}
