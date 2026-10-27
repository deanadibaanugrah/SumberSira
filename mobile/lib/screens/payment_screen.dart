import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/app_state.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Halaman bayar QRIS (simulasi): tampil setelah Checkout, sebelum Booking Berhasil.
// Berisi QR pembayaran, total, batas waktu bayar, dan langkah pembayaran.
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
      appBar: const PageAppBar(title: 'Bayar dengan QRIS'),
      body: AppBackground(
        child: ResponsiveBody(children: [
          AppCard(
            radius: 24,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.storefront_outlined, size: 16, color: AppColors.muted),
                const SizedBox(width: 6),
                Text('Sumber Sira · BUMDes Putukrejo', style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
              ]),
              const SizedBox(height: 6),
              Text(rupiah(total), style: AppTheme.price(30)),
              const SizedBox(height: 16),
              Opacity(
                opacity: expired ? .3 : 1,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.pale, width: 1.5)),
                  // Package qr_flutter: QR berisi nama merchant dan nominal (simulasi QRIS).
                  child: QrImageView(data: 'QRIS SUMBER SIRA ${widget.request.whatsapp} $total', size: 200),
                ),
              ),
              const SizedBox(height: 16),
              // Sisa waktu bayar: hijau saat masih berlaku, coral saat habis.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: expired ? AppColors.coral.withValues(alpha: .14) : AppColors.mint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.timer_outlined, size: 17, color: expired ? AppColors.coralDark : AppColors.forest),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(expired ? 'Waktu bayar habis, kembali lalu ulangi.' : 'Bayar sebelum $mm:$ss',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: expired ? AppColors.coralDark : AppColors.forest)),
                  ),
                ]),
              ),
            ]),
          ),
          const SectionLabel('Cara Bayar'),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final (i, step) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(radius: 12, backgroundColor: AppColors.forest, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(step, style: const TextStyle(fontSize: 13.5, height: 1.4))),
                  ]),
                ),
              const Divider(),
              const SizedBox(height: 10),
              Text('${widget.request.draft.lines.length} item · ${labelJam(widget.request.draft.slot)} · a.n. ${widget.request.name}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: BottomBar(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          PrimaryButton(label: 'Saya Sudah Bayar', loading: _checking, onPressed: expired ? null : _paid),
          const SizedBox(height: 8),
          const Text('Simulasi: belum terhubung ke bank. Tekan tombol di atas untuk melanjutkan.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
        ]),
      ),
    );
  }
}
