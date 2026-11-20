import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/api_client.dart';
import '../../../models/booking.dart';
import '../../../models/payment.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/format.dart';
import '../../../utils/routes.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/common.dart';
import '../../../widgets/glass.dart';

// Halaman bayar QRIS booking: QR asli dari server (dibuat bersama booking di Checkout), batas waktu
// bayar dari server, dan status pembayaran diperiksa ke server tiap 3 detik (bagian 6 planning).
// Booking sudah ada di server saat halaman ini dibuka; setelah lunas, faktur dibuka dan halaman
// Checkout dan Bayar ditutup supaya tidak bisa bayar dua kali.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.booking});

  // [P5 Kirim data antar halaman] Booking dari server (punya id pembayaran dan QR) diterima dari Checkout.
  final Booking booking;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentInfo _pay;
  // Sisa waktu bayar dihitung dari expiresAt server, berkurang tiap detik.
  Duration _left = Duration.zero;
  Timer? _ticker;
  Timer? _poll;
  // True selama tombol "Saya Sudah Bayar" (mode simulasi) sedang memproses.
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Data pembayaran dari respons pembuatan booking; id dipakai untuk polling.
    _pay = PaymentInfo(
      id: widget.booking.paymentId ?? '',
      status: widget.booking.paymentStatus.name,
      amount: widget.booking.total,
      provider: widget.booking.paymentProvider,
      qrString: widget.booking.qrString,
      qrUrl: widget.booking.qrUrl,
      expiresAt: widget.booking.expiresAt,
    );
    _hitungSisaWaktu();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left.inSeconds <= 0) return;
      setState(() => _left -= const Duration(seconds: 1));
    });
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _periksa());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  void _hitungSisaWaktu() {
    final iso = _pay.expiresAt;
    if (iso == null || iso.isEmpty) return;
    final sisa = DateTime.parse(iso).difference(DateTime.now());
    _left = sisa.isNegative ? Duration.zero : sisa;
  }

  // Polling GET /payments/:id (bagian 6 planning). Berhenti sendiri saat status sudah final.
  Future<void> _periksa() async {
    if (_pay.id.isEmpty || _pay.selesai || _pay.tutup) return;
    try {
      final p = await ApiClient.fetchPayment(_pay.id);
      if (!mounted) return;
      setState(() {
        _pay = p;
        _hitungSisaWaktu();
      });
      if (p.selesai) _tuntaskan();
    } on ApiException {
      // server tidak terjangkau: dicoba lagi pada polling berikutnya
    }
  }

  // Lunas: hentikan timer, buka faktur, dan tutup Checkout + Bayar dari tumpukan navigasi.
  void _tuntaskan() {
    _poll?.cancel();
    _ticker?.cancel();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.invoice,
      ModalRoute.withName(AppRoutes.main),
      arguments: widget.booking.code,
    );
  }

  // Tombol "Saya Sudah Bayar" (hanya mode simulasi backend): minta server menandai lunas.
  Future<void> _sudahBayar() async {
    if (_checking || _pay.id.isEmpty) return;
    setState(() => _checking = true);
    try {
      final p = await ApiClient.simulatePayment(_pay.id);
      if (!mounted) return;
      setState(() {
        _pay = p;
        _checking = false;
      });
      if (p.selesai) _tuntaskan();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _checking = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // Teks QR untuk dipindai; bila server hanya mengirim URL gambar, tampilkan gambar itu.
  Widget _qr() {
    final q = _pay.qrString;
    if (q != null && q.isNotEmpty) {
      return QrImageView(
        data: q,
        size: 210,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.ink,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.ink,
        ),
      );
    }
    final url = _pay.qrUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(url, width: 210, height: 210, fit: BoxFit.cover),
      );
    }
    // Cadangan: QR kode booking, sama dengan yang discan petugas.
    return QrImageView(
      data: widget.booking.code,
      size: 210,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: AppColors.ink,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: AppColors.ink,
      ),
    );
  }

  // Pesan ketika pembayaran tidak bisa dilanjutkan (expired, failed, cancelled).
  String get _pesanAkhir => switch (_pay.status) {
    'expired' => 'Batas waktu pembayaran habis.',
    'failed' => 'Pembayaran gagal diproses.',
    _ => 'Pembayaran dibatalkan.',
  };

  @override
  Widget build(BuildContext context) {
    final expired = _left.inSeconds <= 0;
    final tutup = _pay.tutup || (expired && !_pay.selesai);
    final mm = _left.inMinutes.toString().padLeft(2, '0');
    final ss = (_left.inSeconds % 60).toString().padLeft(2, '0');
    const steps = [
      'Buka aplikasi bank atau e-wallet (GoPay, OVO, DANA, m-banking).',
      'Pilih menu Scan / Bayar QRIS, lalu arahkan ke kode di atas.',
      'Pastikan nama merchant Sumber Sira dan nominalnya sama, lalu bayar.',
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const PageAppBar(title: 'Bayar Booking QRIS'),
      body: AppBackground(
        child: ResponsiveBody(
          children: [
            AppCard(
              radius: 24,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.building_2_fill,
                        size: 15,
                        color: AppColors.abu,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Sumber Sira · BUMDes Putukrejo',
                        style: AppText.footnote,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(rupiah(_pay.amount), style: AppText.hero(40)),
                  const SizedBox(height: 18),
                  Opacity(
                    opacity: tutup ? .3 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.line),
                      ),
                      // Package qr_flutter: membuat gambar QR dari teks QRIS asli dari server (warna Ink sesuai palet).
                      child: _qr(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sisa waktu bayar dari server: Hijau Daun 12% saat masih berlaku, Coral saat habis.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: tutup ? AppColors.coral : AppColors.leaf12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.timer,
                          size: 17,
                          color: tutup ? AppColors.ink : AppColors.forest,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            tutup
                                ? 'Waktu bayar habis.'
                                : 'Bayar sebelum $mm:$ss',
                            style: AppText.number(
                              13,
                              color: tutup ? AppColors.ink : AppColors.forest,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GroupedList(
              header: 'Cara bayar',
              footer:
                  '${widget.booking.lines.length} item · ${labelJam(widget.booking.slot)} · a.n. ${widget.booking.name}',
              children: [
                for (final (i, step) in steps.indexed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StepBadge(i + 1),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            step,
                            style: AppText.subheadline.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingBar(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tutup) ...[
              // Pembayaran tidak bisa dilanjutkan: kembali ke Checkout untuk membuat ulang pesanan.
              PrimaryButton(
                label: 'Kembali',
                glass: true,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              Text(
                _pesanAkhir,
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
            ] else if (_pay.simulasi) ...[
              // Mode simulasi backend: tombol untuk menandai lunas, seperti pada sheet tiket.
              PrimaryButton(
                label: 'Saya Sudah Bayar',
                glass: true,
                loading: _checking,
                onPressed: _sudahBayar,
              ),
              const SizedBox(height: 8),
              const Text(
                'Simulasi pembayaran: tekan tombol di atas untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
            ] else ...[
              // Mode sungguhan: tunggu pembayaran terdeteksi otomatis oleh server.
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.leaf,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Menunggu pembayaran...', style: AppText.subheadline),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
