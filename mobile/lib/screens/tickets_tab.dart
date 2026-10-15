import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/booking.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/booking_section.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';
import 'eticket_screen.dart';

// Tab Tiket & Booking: tombol beli tiket, Tiket Saya (riwayat tiket dan invoice dicari lewat
// nomor WhatsApp, tanpa login), lalu di bawahnya Sewa & Booking.
// Nomor terakhir yang dipakai membeli terisi otomatis (shared_preferences).
class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  final _formKey = GlobalKey<FormState>();
  final _state = AppState.instance;
  late final TextEditingController _whatsapp;
  // Nomor yang sedang ditampilkan riwayatnya, dan nomor tersimpan terakhir yang sudah diketahui.
  late String _query;
  late String _lastSaved;

  @override
  void initState() {
    super.initState();
    // Diisi di sini (bukan saat pertama dibaca) supaya perubahan nomor sesudahnya pasti terdeteksi.
    _lastSaved = _state.savedWhatsapp;
    _query = _lastSaved;
    _whatsapp = TextEditingController(text: _lastSaved);
    _state.addListener(_onStateChanged);
  }

  // Setelah membeli tiket atau booking dengan nomor baru, kolom pencarian ikut berganti ke nomor itu.
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
          Text('Tiket & Booking', style: AppTheme.display(22)),
          const SizedBox(height: 4),
          Text('Beli tiket masuk, lihat riwayat per nomor WhatsApp (tanpa login), dan booking sewa & wahana.',
              style: TextStyle(fontSize: 12, color: AppColors.white(.7))),
          const SizedBox(height: 16),
          // Tombol beli tiket masuk (dipindah dari Beranda).
          GlassCard(
            color: AppColors.leaf.withValues(alpha: .45),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => Navigator.pushNamed(context, AppRoutes.buyTicket),
            child: const Row(children: [
              CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.confirmation_number_outlined, color: AppColors.forest, size: 20)),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Beli Tiket Masuk Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('Rp5.000/orang · tunjukkan QR di pintu, tanpa antre', style: TextStyle(fontSize: 10)),
                ]),
              ),
              Icon(Icons.arrow_forward, size: 18),
            ]),
          ),
          const SectionLabel('Tiket Saya'),
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
          const SizedBox(height: 14),
          if (_query.isEmpty)
            _emptyCard('Masukkan nomor WhatsApp yang dipakai saat membeli untuk melihat riwayat tiket dan invoice.')
          else if (tickets.isEmpty && bookings.isEmpty)
            _emptyCard('Belum ada tiket atau invoice untuk nomor $_query.')
          else ...[
            Text('Riwayat $_query', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
            const SizedBox(height: 8),
            for (final t in tickets) _ticketCard(context, t),
            if (bookings.isNotEmpty) ...[
              const SectionLabel('Invoice Sewa & Wahana', top: 10),
              for (final b in bookings) _bookingCard(context, b),
            ],
          ],
          // Isi Sewa & Booking tampil di bawah Tiket Saya (dulu menu terpisah).
          const SizedBox(height: 12),
          Divider(color: AppColors.white(.15)),
          const SizedBox(height: 8),
          Text('Sewa & Booking', style: AppTheme.display(18)),
          const SizedBox(height: 12),
          const BookingSection(),
        ]);
      },
    );
  }

  Widget _emptyCard(String text) => GlassCard(
        child: Column(children: [
          const Icon(Icons.confirmation_number_outlined, size: 32),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
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
          // [P5 Named Route + argumen] Membuka invoice dengan mengirim kode booking.
          onTap: () => Navigator.pushNamed(context, AppRoutes.invoice, arguments: b.code),
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
