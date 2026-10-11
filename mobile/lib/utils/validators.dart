// Validasi sederhana untuk form. Mengembalikan pesan error, atau null kalau isian benar.
class Validators {
  // Nomor WhatsApp Indonesia: diawali 08 atau 62, total 10 sampai 14 angka.
  static final _waPattern = RegExp(r'^(\+?62|0)8\d{8,12}$');
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value, String field) =>
      (value == null || value.trim().isEmpty) ? '$field wajib diisi.' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi.';
    return _emailPattern.hasMatch(value.trim()) ? null : 'Format email belum benar.';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi.';
    return value.length < 6 ? 'Password minimal 6 karakter.' : null;
  }

  static String? whatsapp(String? value) {
    final clean = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (clean.isEmpty) return 'Nomor WhatsApp wajib diisi.';
    return _waPattern.hasMatch(clean) ? null : 'Masukkan nomor yang valid, mis. 081234567890.';
  }
}
