import 'package:intl/intl.dart';

// [P6 Package intl] Format angka ke Rupiah: 45000 -> "Rp45.000".
final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
String rupiah(int value) => _rupiah.format(value);

// [P6 Package intl] Tanggal hari ini dalam Bahasa Indonesia, mis. "Senin, 12 Oktober 2026".
// Butuh initializeDateFormatting('id_ID') yang sudah dipanggil di main().
String tanggalHariIni() => DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

// Jam sekarang dengan format 10.42.
String jamSekarang() => DateFormat('HH.mm').format(DateTime.now());
