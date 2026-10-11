// Format angka ke Rupiah: 45000 -> "Rp45.000".
String rupiah(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}Rp$buffer';
}

// Jam sekarang dengan format 10.42.
String jamSekarang() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
}
