import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/app_state.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/launcher.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';

// Halaman hasil input: e-tiket berisi QR kode tiket (hero), status, dan detail pesanan.
class ETicketScreen extends StatelessWidget {
  const ETicketScreen({super.key, required this.code});

  // [P5 Kirim data antar halaman] Kode tiket diterima lewat constructor dari halaman sebelumnya.

  final String code;

  // Pesan di bawah QR sesuai status tiket.
  static const _messages = {
    TicketStatus.waiting: 'Tunjukkan QR ini ke petugas di pintu masuk. Setelah discan, kamu ikut terhitung di Live Crowd.',
    TicketStatus.inside: 'Kamu sudah masuk dan ikut terhitung di Live Crowd. Selamat bermain air!',
    TicketStatus.out: 'Tiket sudah dipakai. Terima kasih sudah berkunjung!',
  };

  // Isi pesan WhatsApp berisi ringkasan e-tiket.
  String _waMessage(Ticket t) => [
        'E-Tiket Sumber Sira',
        'Kode: ${t.code}',
        'Nama: ${t.name}',
        'Pengunjung: ${t.people} orang',
        'Berlaku: ${t.date.isEmpty ? tanggalHariIni() : t.date}',
        'Total: ${rupiah(t.total)}',
        'Tunjukkan kode ini ke petugas di pintu masuk.',
      ].join('\n');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(title: 'E-Tiket Masuk'),
      body: AppBackground(
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final t = AppState.instance.find(code);
            if (t == null) {
              return ResponsiveBody(children: [
                AppCard(child: Text('Tiket $code tidak ditemukan.', style: AppText.body)),
              ]);
            }
            final rows = [
              ('Nama', t.name),
              ('Pengunjung', '${t.adults} orang${t.kids > 0 ? ' + ${t.kids} balita' : ''}'),
              ('Parkir', t.parking.label),
              ('Jam datang', t.arrival.isEmpty ? '-' : t.arrival),
              ('WhatsApp', t.whatsapp.isEmpty ? '-' : t.whatsapp),
              ('Berlaku', t.date.isEmpty ? tanggalHariIni() : t.date),
              ('Dibeli', 'Pukul ${t.boughtAt}'),
              ('Pembayaran', t.payment == PaymentMethod.cash ? 'Tunai di loket' : 'QRIS, lunas'),
              ('Total', rupiah(t.total)),
            ];
            final last = rows.length - 1;
            return ResponsiveBody(children: [
              // Kartu e-tiket: judul dan status, QR besar, sobekan tiket, lalu rincian pesanan.
              AppCard(
                radius: 24,
                padding: EdgeInsets.zero,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
                    child: Row(children: [
                      const Icon(CupertinoIcons.ticket, size: 20, color: AppColors.leaf),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Tiket Masuk Sumber Sira', style: AppText.headline)),
                      TicketStatusChip(t.status),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(children: [
                      Opacity(
                        opacity: t.status == TicketStatus.waiting ? 1 : .45,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
                          child: QrImageView(
                            data: t.code,
                            size: 200,
                            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink),
                            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.ink),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(t.code, style: AppText.number(24, weight: FontWeight.w700, color: AppColors.forest)),
                      const SizedBox(height: 10),
                      Text(_messages[t.status]!, textAlign: TextAlign.center, style: AppText.subheadline),
                      if (t.checkInAt != null) ...[
                        const SizedBox(height: 6),
                        Text('Masuk ${t.checkInAt}', style: AppText.number(13, color: AppColors.forest)),
                      ],
                    ]),
                  ),
                  const TicketDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Column(children: [
                      for (final (i, (label, value)) in rows.indexed) ...[
                        if (i == last) const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider()),
                        DetailRow(label, value, strong: i == last),
                      ],
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              if (t.status == TicketStatus.waiting) ...[
                TintedButton(label: 'Simulasi scan petugas (demo)', icon: CupertinoIcons.qrcode_viewfinder, onPressed: () => AppState.instance.checkIn(t.code)),
                const SizedBox(height: 10),
              ],
              // Tanpa login: e-tiket dikirim ke WhatsApp pemesan dan riwayatnya dicari lewat nomor itu.
              if (t.whatsapp.isNotEmpty) ...[
                TintedButton(label: 'Kirim E-Tiket ke WhatsApp', icon: CupertinoIcons.paperplane, onPressed: () => kirimWhatsApp(context, t.whatsapp, _waMessage(t))),
                const SizedBox(height: 8),
                Text('Riwayat tiket ini tersimpan di nomor ${t.whatsapp}. Buka Riwayat di Tiket & Booking untuk melihatnya lagi.',
                    textAlign: TextAlign.center, style: AppText.footnote),
                const SizedBox(height: 16),
              ],
              PrimaryButton(
                label: 'Selesai',
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName(AppRoutes.main)),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
