// Data pembayaran dari server (GET /payments/:id, atau isi "payment" di tiket/booking).
// status: pending (menunggu dibayar), paid (lunas), failed, expired, cancelled.
class PaymentInfo {
  const PaymentInfo({
    required this.id,
    this.status = 'pending',
    this.amount = 0,
    this.provider,
    this.qrString,
    this.qrUrl,
    this.expiresAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> j) => PaymentInfo(
    id: j['id'] as String,
    status: (j['status'] as String?) ?? 'pending',
    amount: (j['amount'] as num?)?.toInt() ?? 0,
    provider: j['provider'] as String?,
    qrString: j['qrString'] as String?,
    qrUrl: j['qrUrl'] as String?,
    expiresAt: j['expiresAt'] as String?,
  );

  final String id;
  final String status;
  final int amount;
  // Provider pembayaran: "midtrans" (asli) atau "simulation" (mode uji coba backend).
  final String? provider;
  // Teks QRIS untuk dipindai, atau URL gambar QR bila provider tidak mengirim teksnya.
  final String? qrString;
  final String? qrUrl;
  final String? expiresAt;

  bool get selesai => status == 'paid';

  // Backend dijalankan dengan PAYMENT_MODE=simulation: tombol "Saya Sudah Bayar" boleh tampil.
  // Respons pembuatan tiket tidak selalu memuat provider, jadi mode uji coba juga dikenali
  // dari QR simulasi yang selalu berawalan "QRIS-SIM:".
  bool get simulasi =>
      provider == 'simulation' || (qrString?.startsWith('QRIS-SIM:') ?? false);

  // Tidak bisa dibayar lagi (bukan pending dan belum lunas).
  bool get tutup =>
      status == 'failed' || status == 'expired' || status == 'cancelled';
}
