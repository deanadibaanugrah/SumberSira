// Validasi sederhana untuk form. Mengembalikan pesan error, atau null kalau isian benar.
class Validators {
  // Nomor WhatsApp Indonesia: diawali 08 atau 62, total 10 sampai 14 angka.
  static final _waPattern = RegExp(r'^(\+?62|0)8\d{8,12}$');
  // Email: satu tanda @, ada titik setelah @, hanya huruf, angka, titik, garis bawah, dan tanda hubung.
  // Karakter seperti ( ) : & " ' atau spasi ditolak. Aturan dan pesannya sama dengan form login web admin.
  static final _emailAllowed = RegExp(r'^[A-Za-z0-9._@-]+$');
  static final _emailPattern = RegExp(
      r'^[A-Za-z0-9](?:[A-Za-z0-9._-]*[A-Za-z0-9])?@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}$');

  static String? required(String? value, String field) =>
      (value == null || value.trim().isEmpty) ? '$field wajib diisi.' : null;

  static String? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email wajib diisi.';
    if (email.length > 100) return 'Email terlalu panjang (maksimal 100 karakter).';
    if (!email.contains('@')) return 'Email harus memakai tanda @.';
    if (!_emailAllowed.hasMatch(email)) return 'Email hanya boleh berisi huruf, angka, titik (.), garis bawah (_), tanda hubung (-), dan @.';
    final parts = email.split('@');
    if (parts.length != 2) return 'Email hanya boleh punya satu tanda @.';
    if (parts[0].isEmpty) return 'Isi nama sebelum tanda @, contoh: nama@sumbersira.id.';
    if (!parts[1].contains('.')) return 'Bagian setelah @ harus memakai titik, contoh: nama@sumbersira.id.';
    if (email.contains('..') || !_emailPattern.hasMatch(email)) return 'Format email belum benar, contoh: nama@sumbersira.id.';
    return null;
  }

  static String? whatsapp(String? value) {
    final clean = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (clean.isEmpty) return 'Nomor WhatsApp wajib diisi.';
    return _waPattern.hasMatch(clean) ? null : 'Masukkan nomor yang valid, mis. 081234567890.';
  }
}
