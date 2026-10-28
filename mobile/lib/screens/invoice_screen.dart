import 'package:flutter/cupertino.dart';
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

// Booking Berhasil & Invoice: tampil setelah pembayaran QRIS, berisi tanda berhasil (hero), QR kode booking,
// dan rincian yang sudah dibayar. Juga dibuka dari Riwayat di Tiket & Booking.
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
        extendBodyBehindAppBar: true,
        appBar: const PageAppBar(title: 'Invoice'),
        body: AppBackground(child: ResponsiveBody(children: [AppCard(child: Text('Booking $code tidak ditemukan.', style: AppText.body))])),
      );
    }
    return Scaffold(
      body: AppBackground(
        child: ResponsiveBody(children: [
          const SizedBox(height: 12),
          const Icon(CupertinoIcons.checkmark_seal_fill, size: 76, color: AppColors.leaf),
          const SizedBox(height: 14),
          Text('Booking Berhasil!', textAlign: TextAlign.center, style: AppText.title2.copyWith(fontSize: 28, height: 34 / 28)),
          const SizedBox(height: 6),
          const Text('Pembayaran QRIS diterima. Tunjukkan QR ini di pintu masuk.', textAlign: TextAlign.center, style: AppText.subheadline),
          const SizedBox(height: 22),
          // Kartu invoice berbentuk tiket: QR di atas, sobekan, lalu rincian pembayaran.
          AppCard(
            radius: 24,
            padding: EdgeInsets.zero,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
                    // Package qr_flutter: QR berisi kode booking yang discan petugas.
                    child: QrImageView(
                      data: b.code,
                      size: 170,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Invoice ${b.code}', textAlign: TextAlign.center, style: AppText.number(15, weight: FontWeight.w700, color: AppColors.forest)),
                ]),
              ),
              const TicketDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(children: [
                  DetailRow('Nama Pemesan', b.name),
                  DetailRow('Waktu Kunjungan', labelJam(b.slot)),
                  DetailRow('Item', b.itemsText),
                  DetailRow('Dibayar', '${b.date.isEmpty ? tanggalHariIni() : b.date}, ${b.orderedAt}'),
                  const DetailRow('Pembayaran', 'QRIS, lunas'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider()),
                  DetailRow('Total Dibayar', rupiah(b.total), strong: true),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          TintedButton(label: 'Kirim Invoice ke WhatsApp', icon: CupertinoIcons.paperplane, onPressed: () => kirimWhatsApp(context, b.whatsapp, _waMessage(b))),
          const SizedBox(height: 8),
          Text('Riwayat invoice tersimpan di nomor ${b.whatsapp}.', textAlign: TextAlign.center, style: AppText.footnote),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Selesai',
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName(AppRoutes.main)),
          ),
        ]),
      ),
    );
  }
}
