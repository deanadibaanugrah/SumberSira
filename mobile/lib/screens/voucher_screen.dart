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

// Konfirmasi & E-Voucher: tampil setelah Checkout, berisi QR kode booking dan ringkasan pesanan.
// Juga dibuka dari riwayat di Tiket Saya.
class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key, required this.code});

  final String code;

  // Isi pesan WhatsApp berisi ringkasan e-voucher.
  String _waMessage(Booking b) => [
        'E-Voucher Sumber Sira',
        'Kode: ${b.code}',
        'Nama: ${b.name}',
        'Jam: ${labelJam(b.slot)}',
        'Item: ${b.itemsText}',
        'Total: ${rupiah(b.total)} (${b.cash ? 'bayar tunai di lokasi' : 'QRIS, lunas'})',
      ].join('\n');

  @override
  Widget build(BuildContext context) {
    final b = AppState.instance.findBooking(code);
    return Scaffold(
      body: AppBackground(
        child: b == null
            ? ResponsiveBody(children: [
                const PageHeader(title: 'E-Voucher'),
                GlassCard(child: Text('Booking $code tidak ditemukan.')),
              ])
            : ResponsiveBody(children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.leaf.withValues(alpha: .45),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white(.3)),
                    ),
                    child: const Icon(Icons.check_rounded, size: 52),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Booking Berhasil!', textAlign: TextAlign.center, style: AppTheme.display(26)),
                const SizedBox(height: 6),
                Text('Tunjukkan QR ini di pintu masuk', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.white(.75))),
                const SizedBox(height: 4),
                Text('Kode: ${b.code}', textAlign: TextAlign.center, style: AppTheme.mono(11)),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                    // Package qr_flutter: QR berisi kode booking yang discan petugas.
                    child: QrImageView(data: b.code, size: 150),
                  ),
                ),
                const SizedBox(height: 18),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  child: Column(children: [
                    for (final (label, value) in [
                      ('Nama Pemesan', b.name),
                      ('Waktu Kunjungan', labelJam(b.slot)),
                      ('Item', b.itemsText),
                      ('Pembayaran', b.cash ? 'Cash di lokasi' : 'QRIS, lunas'),
                      (b.cash ? 'Total Dibayar di Lokasi' : 'Total Dibayar', rupiah(b.total)),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: AppColors.white(.7)))),
                          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        ]),
                      ),
                  ]),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: AppColors.white(.3)),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => kirimWhatsApp(context, b.whatsapp, _waMessage(b)),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('Kirim E-Voucher ke WhatsApp'),
                ),
                const SizedBox(height: 6),
                Text('Riwayat booking tersimpan di nomor ${b.whatsapp}.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.white(.65))),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Kembali ke Beranda',
                  onPressed: () => Navigator.popUntil(context, ModalRoute.withName(AppRoutes.main)),
                ),
              ]),
      ),
    );
  }
}
