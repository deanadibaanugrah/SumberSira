import 'package:intl/intl.dart';

// Helper waktu WIB (UTC+7) untuk data dari server.
// Server mengirim waktu dalam ISO-8601 UTC; semua jam yang tampil di aplikasi dikonversi
// ke WIB dan diformat dengan intl (id_ID), tidak bergantung zona waktu HP pengunjung.

// "2026-11-12T03:42:00.000Z" -> DateTime 10.42 WIB. Null bila iso null/kosong.
DateTime? waktuWib(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  return DateTime.parse(iso).toUtc().add(const Duration(hours: 7));
}

// ISO-8601 UTC dari server -> "10.42" (jam WIB). Null bila iso kosong.
String jamWib(String? iso) {
  final w = waktuWib(iso);
  return w == null ? '-' : DateFormat('HH.mm').format(w);
}

// ISO-8601 UTC dari server -> "Kamis, 12 November 2026" (tanggal di WIB).
// Butuh initializeDateFormatting('id_ID') yang sudah dipanggil di main().
String tanggalPanjangWib(String? iso) {
  final w = waktuWib(iso);
  return w == null ? '-' : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(w);
}

// Tanggal berlaku tiket dari server ("2026-11-12") -> "Kamis, 12 November 2026".
String tanggalPanjang(String ymd) => DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(ymd));
