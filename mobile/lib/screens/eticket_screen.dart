import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/app_state.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final t = AppState.instance.find(code);
            if (t == null) {
              return ResponsiveBody(children: [
                const PageHeader(title: 'E-Tiket Masuk'),
                GlassCard(child: Text('Tiket $code tidak ditemukan.')),
              ]);
            }
            final rows = [
              ('Nama', t.name),
              ('Pengunjung', '${t.adults} orang${t.kids > 0 ? ' + ${t.kids} balita' : ''}'),
              ('Parkir', t.parking.label),
              ('Jam datang', t.arrival.isEmpty ? '-' : t.arrival),
              ('Berlaku', tanggalHariIni()),
              ('Dibeli', 'Pukul ${t.boughtAt}'),
              ('Pembayaran', t.payment == PaymentMethod.cash ? 'Tunai di loket' : 'QRIS, lunas'),
              ('Total', rupiah(t.total)),
            ];
            return ResponsiveBody(children: [
              const PageHeader(title: 'E-Tiket Masuk'),
              GlassCard(
                radius: 24,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(children: [
                  Opacity(
                    opacity: t.status == TicketStatus.waiting ? 1 : .6,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: QrImageView(data: t.code, size: 170),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(t.code, style: AppTheme.mono(20, weight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TicketStatusChip(t.status),
                  const SizedBox(height: 12),
                  Text(_messages[t.status]!, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.white(.8))),
                  if (t.checkInAt != null) ...[
                    const SizedBox(height: 4),
                    Text('Masuk ${t.checkInAt}', style: AppTheme.mono(10, color: AppColors.white(.65))),
                  ],
                ]),
              ),
              const SizedBox(height: 14),
              GlassCard(
                child: Column(children: [
                  for (final (label, value) in rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 11, color: AppColors.white(.7)))),
                        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                ]),
              ),
              const SizedBox(height: 14),
              if (t.status == TicketStatus.waiting) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: AppColors.white(.3)),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => AppState.instance.checkIn(t.code),
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text('Simulasi scan petugas (demo)'),
                ),
                const SizedBox(height: 10),
              ],
              PrimaryButton(
                label: 'Kembali ke Beranda',
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName(AppRoutes.main)),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
