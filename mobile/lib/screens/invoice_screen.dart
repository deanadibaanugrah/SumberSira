import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/app_state.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/launcher.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Booking Berhasil & Invoice: tampil setelah pembayaran QRIS, berisi QR kode booking dan rincian
// yang sudah dibayar. Juga dibuka dari riwayat invoice di Tiket & Booking.
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key, required this.code});

  final String code;

  // Isi pesan WhatsApp berisi ringkasan invoice.
  String _waMessage(Booking b) => [
        'Invoice Sumber Sira',
        'Kode: ${b.code}',
        'Nama: ${b.name}',
        'Jam: ${labelJam(b.slot)}',
        'Item: ${b.itemsText}',
        'Total: ${rupiah(b.total)} (QRIS, lunas)',
      ].join('\n');

  @override
  Widget build(BuildContext context) {
    final b = AppState.instance.findBooking(code);
    if (b == null) {
      return Scaffold(
        appBar: const PageAppBar(title: 'Invoice'),
        body: AppBackground(child: ResponsiveBody(children: [AppCard(child: Text('Booking $code tidak ditemukan.'))])),
      );
    }
    return Scaffold(
      body: AppBackground(
        child: ResponsiveBody(children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(color: AppColors.pale, shape: BoxShape.circle, border: Border.all(color: AppColors.mint, width: 8)),
              child: const Icon(Icons.check_rounded, size: 48, color: AppColors.forest),
            ),
          ),
          const SizedBox(height: 18),
          Text('Booking Berhasil!', textAlign: TextAlign.center, style: AppTheme.display(28)),
          const SizedBox(height: 6),
          const Text('Pembayaran QRIS diterima. Tunjukkan QR ini di pintu masuk.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.4)),
          const SizedBox(height: 20),
          // Kartu invoice berbentuk tiket: QR di atas, sobekan, lalu rincian pembayaran.
          AppCard(
            radius: 24,
            padding: EdgeInsets.zero,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.pale, width: 1.5)),
                    // Package qr_flutter: QR berisi kode booking yang discan petugas.
                    child: QrImageView(data: b.code, size: 160),
                  ),
                  const SizedBox(height: 12),
                  Text('Invoice ${b.code}', textAlign: TextAlign.center, style: AppTheme.mono(14, weight: FontWeight.w700, color: AppColors.forest)),
                ]),
              ),
              const TicketDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Column(children: [
                  DetailRow('Nama Pemesan', b.name),
                  DetailRow('Waktu Kunjungan', labelJam(b.slot)),
                  DetailRow('Item', b.itemsText),
                  DetailRow('Dibayar', '${b.date.isEmpty ? tanggalHariIni() : b.date}, ${b.orderedAt}'),
                  const DetailRow('Pembayaran', 'QRIS, lunas'),
                  const Divider(height: 18),
                  DetailRow('Total Dibayar', rupiah(b.total), strong: true),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          OutlineAction(label: 'Kirim Invoice ke WhatsApp', icon: Icons.chat_outlined, onPressed: () => kirimWhatsApp(context, b.whatsapp, _waMessage(b))),
          const SizedBox(height: 8),
          Text('Riwayat invoice tersimpan di nomor ${b.whatsapp}.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Selesai',
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName(AppRoutes.main)),
          ),
        ]),
      ),
    );
  }
}
