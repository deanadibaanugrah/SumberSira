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
      body: AppBackground(
        child: ResponsiveBody(children: [
          const PageHeader(title: 'Bayar dengan QRIS'),
          GlassCard(
            radius: 24,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(children: [
              Text('Sumber Sira · BUMDes Putukrejo', style: TextStyle(fontSize: 11, color: AppColors.white(.75))),
              const SizedBox(height: 4),
              Text(rupiah(total), style: AppTheme.mono(26, weight: FontWeight.w600)),
              const SizedBox(height: 14),
              Opacity(
                opacity: expired ? .3 : 1,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  // Package qr_flutter: QR berisi nama merchant dan nominal (simulasi QRIS).
                  child: QrImageView(data: 'QRIS SUMBER SIRA ${widget.request.whatsapp} $total', size: 190),
                ),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.timer_outlined, size: 15, color: expired ? AppColors.coral : Colors.white),
                const SizedBox(width: 6),
                Text(expired ? 'Waktu bayar habis, kembali lalu ulangi.' : 'Bayar sebelum $mm:$ss',
                    style: TextStyle(fontSize: 12, color: expired ? AppColors.coral : Colors.white)),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cara bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              for (final (i, step) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(radius: 9, backgroundColor: AppColors.leaf, child: Text('${i + 1}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(step, style: TextStyle(fontSize: 11, color: AppColors.white(.85)))),
                  ]),
                ),
              const SizedBox(height: 4),
              Text('${widget.request.draft.lines.length} item · ${labelJam(widget.request.draft.slot)} · a.n. ${widget.request.name}',
                  style: TextStyle(fontSize: 10, color: AppColors.white(.65))),
            ]),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Saya Sudah Bayar', loading: _checking, onPressed: expired ? null : _paid),
          const SizedBox(height: 8),
          Text('Simulasi: belum terhubung ke bank. Tekan tombol di atas untuk melanjutkan.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.white(.55))),
        ]),
      ),
    );
  }
}
