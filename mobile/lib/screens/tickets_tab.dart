import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';

// Tab Tiket Saya: menampilkan data hasil input form (tiket yang sudah dibeli).
class TicketsTab extends StatelessWidget {
  const TicketsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final tickets = AppState.instance.myTickets;
        return ResponsiveBody(children: [
          Text('Tiket Saya', style: AppTheme.display(22)),
          const SizedBox(height: 4),
          Text('Tunjukkan QR e-tiket ke petugas di pintu masuk.', style: TextStyle(fontSize: 12, color: AppColors.white(.7))),
          const SizedBox(height: 18),
          if (tickets.isEmpty)
            GlassCard(
              child: Column(children: [
                const Icon(Icons.confirmation_number_outlined, size: 36),
                const SizedBox(height: 10),
                const Text('Belum ada tiket hari ini.', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 14),
                PrimaryButton(label: 'Beli Tiket Masuk', height: 44, onPressed: () => Navigator.pushNamed(context, AppRoutes.buyTicket)),
              ]),
            )
          else
            for (final t in tickets)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.eticket, arguments: t.code),
                  child: Row(children: [
                    CircleAvatar(radius: 20, backgroundColor: AppColors.leaf.withValues(alpha: .45), child: const Icon(Icons.qr_code_2, size: 20, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.code, style: AppTheme.mono(13, weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${t.people} orang · ${rupiah(t.total)} · dibeli ${t.boughtAt}', style: TextStyle(fontSize: 10, color: AppColors.white(.7))),
                      ]),
                    ),
                    TicketStatusChip(t.status),
                  ]),
                ),
              ),
        ]);
      },
    );
  }
}
