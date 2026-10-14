import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/booking.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';
import 'eticket_screen.dart';

// Tab Tiket Saya: riwayat tiket dan booking dicari lewat nomor WhatsApp, tanpa login.
// Nomor terakhir yang dipakai membeli tiket terisi otomatis (shared_preferences).
class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  final _formKey = GlobalKey<FormState>();
  final _state = AppState.instance;
  late final _whatsapp = TextEditingController(text: _state.savedWhatsapp);
  // Nomor yang sedang ditampilkan riwayatnya.
  late String _query = _state.savedWhatsapp;
  late String _lastSaved = _state.savedWhatsapp;

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
  }

  // Setelah membeli tiket dengan nomor baru, kolom pencarian ikut berganti ke nomor itu.
  void _onStateChanged() {
    if (_state.savedWhatsapp == _lastSaved) return;
    setState(() {
      _lastSaved = _state.savedWhatsapp;
      _query = _lastSaved;
      _whatsapp.text = _lastSaved;
    });
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _whatsapp.dispose();
    super.dispose();
  }

  // Tombol Cari: cek format nomor dulu, lalu tampilkan riwayat nomor itu.
  void _search() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _query = nomorWa(_whatsapp.text));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final tickets = _state.ticketsFor(_query);
        final bookings = _state.bookingsFor(_query);
        return ResponsiveBody(children: [
          Text('Tiket Saya', style: AppTheme.display(22)),
          const SizedBox(height: 4),
          Text('Riwayat tiket tersimpan per nomor WhatsApp, tanpa login.', style: TextStyle(fontSize: 12, color: AppColors.white(.7))),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: TextFormField(
                    controller: _whatsapp,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _search(),
                    decoration: const InputDecoration(labelText: 'Nomor WhatsApp', hintText: '081234567890', isDense: true),
                    validator: Validators.whatsapp,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(width: 76, child: PrimaryButton(label: 'Cari', height: 46, onPressed: _search)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          if (_query.isEmpty)
            _emptyCard(context, 'Masukkan nomor WhatsApp yang dipakai saat membeli tiket untuk melihat riwayatnya.')
          else if (tickets.isEmpty && bookings.isEmpty)
            _emptyCard(context, 'Belum ada tiket untuk nomor $_query.')
          else ...[
            Text('Riwayat $_query', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
            const SizedBox(height: 8),
            for (final t in tickets) _ticketCard(context, t),
            if (bookings.isNotEmpty) ...[
              const SectionLabel('Voucher Sewa & Wahana', top: 10),
              for (final b in bookings) _bookingCard(context, b),
            ],
          ],
        ]);
      },
    );
  }

  Widget _emptyCard(BuildContext context, String text) => GlassCard(
        child: Column(children: [
          const Icon(Icons.confirmation_number_outlined, size: 36),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Beli Tiket Masuk', height: 44, onPressed: () => Navigator.pushNamed(context, AppRoutes.buyTicket)),
        ]),
      );

  Widget _ticketCard(BuildContext context, Ticket t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          // [P5 Navigator.push] Membuka e-tiket dan mengirim kode lewat constructor ETicketScreen.
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ETicketScreen(code: t.code))),
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
      );

  Widget _bookingCard(BuildContext context, Booking b) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          // [P5 Named Route + argumen] Membuka e-voucher dengan mengirim kode booking.
          onTap: () => Navigator.pushNamed(context, AppRoutes.voucher, arguments: b.code),
          child: Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppColors.leaf.withValues(alpha: .45), child: const Icon(Icons.local_activity_outlined, size: 20, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.code, style: AppTheme.mono(12, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${b.itemsText} · ${labelJam(b.slot)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: AppColors.white(.7))),
              ]),
            ),
            Text(rupiah(b.total), style: AppTheme.mono(11)),
          ]),
        ),
      );
}
