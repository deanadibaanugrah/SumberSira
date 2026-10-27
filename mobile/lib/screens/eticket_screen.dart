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

// Halaman hasil input: e-tiket berisi QR kode tiket, status, dan detail pesanan.
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
      appBar: const PageAppBar(title: 'E-Tiket Masuk'),
      body: AppBackground(
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final t = AppState.instance.find(code);
            if (t == null) {
              return ResponsiveBody(children: [
                AppCard(child: Text('Tiket $code tidak ditemukan.')),
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
              // Kartu e-tiket: pita hijau tua di atas, QR dan status, sobekan tiket, lalu rincian pesanan.
              AppCard(
                radius: 24,
                padding: EdgeInsets.zero,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(
                    color: AppColors.forest,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(children: [
                      const Icon(Icons.confirmation_number_outlined, size: 19, color: AppColors.lightLeaf),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Tiket Masuk Sumber Sira', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                    child: Column(children: [
                      Opacity(
                        opacity: t.status == TicketStatus.waiting ? 1 : .5,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.pale, width: 1.5)),
                          child: QrImageView(data: t.code, size: 180),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(t.code, style: AppTheme.mono(22, weight: FontWeight.w700, color: AppColors.forest)),
                      const SizedBox(height: 8),
                      TicketStatusChip(t.status),
                      const SizedBox(height: 12),
                      Text(_messages[t.status]!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4)),
                      if (t.checkInAt != null) ...[
                        const SizedBox(height: 4),
                        Text('Masuk ${t.checkInAt}', style: AppTheme.mono(12, weight: FontWeight.w600, color: AppColors.leaf)),
                      ],
                    ]),
                  ),
                  const TicketDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                    child: Column(children: [
                      for (final (i, (label, value)) in rows.indexed) ...[
                        if (i == last) const Divider(height: 18),
                        DetailRow(label, value, strong: i == last),
                      ],
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              if (t.status == TicketStatus.waiting) ...[
                OutlineAction(label: 'Simulasi scan petugas (demo)', icon: Icons.qr_code_scanner_rounded, onPressed: () => AppState.instance.checkIn(t.code)),
                const SizedBox(height: 10),
              ],
              // Tanpa login: e-tiket dikirim ke WhatsApp pemesan dan riwayatnya dicari lewat nomor itu.
              if (t.whatsapp.isNotEmpty) ...[
                OutlineAction(label: 'Kirim E-Tiket ke WhatsApp', icon: Icons.chat_outlined, onPressed: () => kirimWhatsApp(context, t.whatsapp, _waMessage(t))),
                const SizedBox(height: 8),
                Text('Riwayat tiket ini tersimpan di nomor ${t.whatsapp}. Buka Tiket Saya untuk melihatnya lagi.',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 14),
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
