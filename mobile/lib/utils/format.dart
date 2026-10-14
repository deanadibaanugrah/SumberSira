import 'package:intl/intl.dart';

// [P6 Package intl] Format angka ke Rupiah: 45000 -> "Rp45.000".
final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
String rupiah(int value) => _rupiah.format(value);

// [P6 Package intl] Tanggal hari ini dalam Bahasa Indonesia, mis. "Senin, 12 Oktober 2026".
// Butuh initializeDateFormatting('id_ID') yang sudah dipanggil di main().
String tanggalHariIni() => DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

// Jam sekarang dengan format 10.42.
String jamSekarang() => DateFormat('HH.mm').format(DateTime.now());

// Tanggal ringkas untuk kode booking, mis. 20261014.
String tanggalKode() => DateFormat('yyyyMMdd').format(DateTime.now());

// Menyamakan penulisan nomor WhatsApp supaya pencarian riwayat tidak gagal karena beda format.
// "+62 812-3456-7890", "62812..." dan "0812..." semuanya menjadi "081234567890".
String nomorWa(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.startsWith('62') ? '0${digits.substring(2)}' : digits;
}

// Nomor untuk tautan wa.me harus diawali kode negara 62, tanpa angka 0 di depan.
String nomorWaInternasional(String value) {
  final n = nomorWa(value);
  return n.startsWith('0') ? '62${n.substring(1)}' : n;
}

// Jam booking "08-10" ditampilkan sebagai "08.00 - 10.00".
String labelJam(String slot) {
  final parts = slot.split('-');
  return parts.length == 2 ? '${parts[0]}.00 - ${parts[1]}.00' : slot;
}
