import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/app_state.dart';
import '../../../models/booking.dart';
import '../../../models/ticket.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/format.dart';
import '../../../utils/launcher.dart';
import '../../../utils/routes.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/common.dart';
import '../../../widgets/glass.dart';

// Booking Berhasil & Invoice: tampil setelah pembayaran QRIS, berisi tanda berhasil (hero), QR kode booking,
// dan rincian yang sudah dibayar. Juga dibuka dari Riwayat di Tiket & Booking. Faktur dibaca dari server
// (GET /bookings/:code?whatsapp=): total, baris item, dan status pembayaran semuanya dari server.
class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, required this.code});

  final String code;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  void initState() {
    super.initState();
    // Faktur terbaru dari server (status pembayaran bisa berubah). Gagal diam-diam: memakai data terakhir.
    AppState.instance.refreshBooking(widget.code);
  }

  // Isi pesan WhatsApp berisi ringkasan invoice.
  String _waMessage(Booking b) => [
    'Invoice Sumber Sira',
    'Kode: ${b.code}',
    'Nama: ${b.name}',
    'Jam: ${labelJam(b.slot)}',
    'Item: ${b.itemsText}',
    'Total: ${rupiah(b.total)} (${b.labelPembayaran})',
  ].join('\n');

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final b = AppState.instance.findBooking(widget.code);
        if (b == null) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: const PageAppBar(title: 'Invoice'),
            body: AppBackground(
              child: ResponsiveBody(
                children: [
                  AppCard(
                    child: Text(
                      'Booking ${widget.code} tidak ditemukan.',
                      style: AppText.body,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final lunas = b.paymentStatus == PaymentStatus.paid;
        return Scaffold(
          body: AppBackground(
            child: ResponsiveBody(
              children: [
                const SizedBox(height: 12),
                // Kartu status hijau: lunas = berhasil, selain itu masih menunggu pembayaran.
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Glass(
                        tone: GlassTone.dark,
                        radius: 36,
                        shadow: false,
                        child: SizedBox.square(
                          dimension: 72,
                          child: Icon(
                            lunas
                                ? CupertinoIcons.checkmark_alt
                                : CupertinoIcons.clock_fill,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lunas ? 'Booking Berhasil!' : 'Menunggu Pembayaran',
                        textAlign: TextAlign.center,
                        style: AppText.display(30, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lunas
                            ? 'Pembayaran QRIS diterima. Tunjukkan QR ini di pintu masuk.'
                            : 'Pembayaran QRIS belum lunas. Status di sini ikut diperbarui dari server.',
                        textAlign: TextAlign.center,
                        style: AppText.subheadline.copyWith(
                          color: AppColors.putih72,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Kartu invoice berbentuk tiket: QR di atas, sobekan, lalu rincian pembayaran.
                AppCard(
                  radius: 24,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppColors.line),
                              ),
                              // Package qr_flutter: QR berisi kode booking yang discan petugas.
                              child: QrImageView(
                                data: b.code,
                                size: 170,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: AppColors.ink,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Invoice ${b.code}',
                              textAlign: TextAlign.center,
                              style: AppText.number(
                                15,
                                weight: FontWeight.w700,
                                color: AppColors.forest,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const TicketDivider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        child: Column(
                          children: [
                            DetailRow('Nama Pemesan', b.name),
                            DetailRow('Waktu Kunjungan', labelJam(b.slot)),
                            DetailRow('Item', b.itemsText),
                            DetailRow(
                              lunas ? 'Dibayar' : 'Dipesan',
                              '${b.date.isEmpty ? tanggalHariIni() : b.date}, ${b.orderedAt}',
                            ),
                            DetailRow('Pembayaran', b.labelPembayaran),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Divider(),
                            ),
                            DetailRow(
                              'Total Dibayar',
                              rupiah(b.total),
                              strong: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TintedButton(
                  label: 'Kirim Invoice ke WhatsApp',
                  icon: CupertinoIcons.paperplane,
                  onPressed: () =>
                      kirimWhatsApp(context, b.whatsapp, _waMessage(b)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Riwayat invoice tersimpan di nomor ${b.whatsapp}.',
                  textAlign: TextAlign.center,
                  style: AppText.footnote,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Selesai',
                  onPressed: () => Navigator.popUntil(
                    context,
                    ModalRoute.withName(AppRoutes.main),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
