import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/app_state.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';

// Halaman bayar QRIS booking (simulasi): tampil setelah Checkout, sebelum Booking Berhasil.
// Berisi QR pembayaran dan total (hero), batas waktu bayar, dan langkah pembayaran.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.request});

  // [P5 Kirim data antar halaman] Pesanan (isi booking, nama, WhatsApp) diterima dari Checkout.
  final BookingRequest request;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Batas waktu bayar 15 menit, berkurang tiap detik.
  static const _limit = Duration(minutes: 15);
  Duration _left = _limit;
  Timer? _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left.inSeconds <= 0) return _timer?.cancel();
      setState(() => _left -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Tombol Saya Sudah Bayar: seolah-olah mengecek pembayaran ke bank, lalu simpan booking
  // dan buka Booking Berhasil. Halaman Checkout dan Bayar ditutup supaya tidak bisa bayar dua kali.
  Future<void> _paid() async {
    setState(() => _checking = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final booking = AppState.instance.addBooking(widget.request);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.invoice, ModalRoute.withName(AppRoutes.main), arguments: booking.code);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.request.draft.total;
    final expired = _left.inSeconds <= 0;
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
        child: ResponsiveBody(children: [
          AppCard(
            radius: 24,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(CupertinoIcons.building_2_fill, size: 15, color: AppColors.abu),
                SizedBox(width: 6),
                Text('Sumber Sira · BUMDes Putukrejo', style: AppText.footnote),
              ]),
              const SizedBox(height: 6),
              Text(rupiah(total), style: AppText.hero(40)),
              const SizedBox(height: 18),
              Opacity(
                opacity: expired ? .3 : 1,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
                  // Package qr_flutter: QR berisi nama merchant dan nominal (simulasi QRIS).
                  child: QrImageView(
                    data: 'QRIS SUMBER SIRA ${widget.request.whatsapp} $total',
                    size: 210,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.ink),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sisa waktu bayar: Hijau Daun 12% saat masih berlaku, Coral saat habis.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: expired ? AppColors.coral : AppColors.leaf12, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(CupertinoIcons.timer, size: 17, color: expired ? AppColors.ink : AppColors.forest),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(expired ? 'Waktu bayar habis, kembali lalu ulangi.' : 'Bayar sebelum $mm:$ss',
                        style: AppText.number(13, color: expired ? AppColors.ink : AppColors.forest)),
                  ),
                ]),
              ),
            ]),
          ),
          GroupedList(
            header: 'Cara bayar',
            footer: '${widget.request.draft.lines.length} item · ${labelJam(widget.request.draft.slot)} · a.n. ${widget.request.name}',
            children: [
              for (final (i, step) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 20, child: Text('${i + 1}', style: AppText.number(17, weight: FontWeight.w700, color: AppColors.forest))),
                    const SizedBox(width: 16),
                    Expanded(child: Text(step, style: AppText.subheadline.copyWith(color: AppColors.ink))),
                  ]),
                ),
            ],
          ),
        ]),
      ),
      bottomNavigationBar: FloatingBar(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          PrimaryButton(label: 'Saya Sudah Bayar', glass: true, loading: _checking, onPressed: expired ? null : _paid),
          const SizedBox(height: 8),
          const Text('Simulasi: belum terhubung ke bank. Tekan tombol di atas untuk melanjutkan.', textAlign: TextAlign.center, style: AppText.caption),
        ]),
      ),
    );
  }
}
