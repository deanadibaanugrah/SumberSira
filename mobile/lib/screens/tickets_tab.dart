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
        return TabBody(
          header: const TabHeader(
            title: 'Tiket & Booking',
            subtitle: 'Beli tiket masuk, lihat riwayat per nomor WhatsApp (tanpa login), dan booking sewa & wahana.',
          ),
          children: [
            // Tombol beli tiket masuk (dipindah dari Beranda): kartu foto, seluruh kartu bisa diketuk.
            _buyTicketCard(context),
            const SectionTitle('Tiket Saya', subtitle: 'Cari tiket dan invoice dengan nomor WhatsApp yang dipakai saat membeli.'),
            Form(
              key: _formKey,
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: TextFormField(
                      controller: _whatsapp,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        labelText: 'Nomor WhatsApp',
                        hintText: '081234567890',
                        isDense: true,
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                      validator: Validators.whatsapp,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(width: 82, child: PrimaryButton(label: 'Cari', height: 50, onPressed: _search)),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            if (_query.isEmpty)
              _emptyCard('Masukkan nomor WhatsApp yang dipakai saat membeli untuk melihat riwayat tiket dan invoice.')
            else if (tickets.isEmpty && bookings.isEmpty)
              _emptyCard('Belum ada tiket atau invoice untuk nomor $_query.')
            else ...[
              Text('Riwayat $_query', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
              const SizedBox(height: 10),
              for (final t in tickets) _ticketCard(context, t),
              if (bookings.isNotEmpty) ...[
                const SectionLabel('Invoice Sewa & Wahana', top: 8),
                for (final b in bookings) _bookingCard(context, b),
              ],
            ],
            // Isi Sewa & Booking tampil di bawah Tiket Saya (dulu menu terpisah).
            const SectionTitle('Sewa & Booking', subtitle: 'Pilih jam, tambah alat sewa atau wahana, lalu lanjut booking.', top: 24),
            const BookingSection(),
          ],
        );
      },
    );
  }

  Widget _buyTicketCard(BuildContext context) => Material(
        color: AppColors.forest,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.buyTicket),
          child: SizedBox(
            height: 168,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/images/komunitas-2.jpg', fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.forest.withValues(alpha: .95), AppColors.forest.withValues(alpha: .25)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.confirmation_number_outlined, size: 18, color: AppColors.lightLeaf),
                    const SizedBox(width: 6),
                    Text('Rp5.000/orang', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.white(.9))),
                  ]),
                  const SizedBox(height: 8),
                  Text('Beli Tiket Masuk Online', style: AppTheme.display(21, color: Colors.white)),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 220,
                    child: Text('Tunjukkan QR di pintu, tanpa antre', style: TextStyle(fontSize: 12.5, color: AppColors.white(.85))),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Beli Tiket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.forest)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 17, color: AppColors.forest),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      );

  Widget _emptyCard(String text) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(children: [
          const IconBadge(Icons.confirmation_number_outlined, size: 52, circle: true),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4)),
        ]),
      );

  Widget _ticketCard(BuildContext context, Ticket t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          // [P5 Navigator.push] Membuka e-tiket dan mengirim kode lewat constructor ETicketScreen.
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ETicketScreen(code: t.code))),
          child: Row(children: [
            const IconBadge(Icons.qr_code_2_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(t.code, style: AppTheme.mono(14.5, weight: FontWeight.w700, color: AppColors.forest))),
                  TicketStatusChip(t.status),
                ]),
                const SizedBox(height: 4),
                Text('${t.people} orang · ${rupiah(t.total)} · dibeli ${t.boughtAt}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ]),
        ),
      );

  Widget _bookingCard(BuildContext context, Booking b) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          // [P5 Named Route + argumen] Membuka invoice dengan mengirim kode booking.
          onTap: () => Navigator.pushNamed(context, AppRoutes.invoice, arguments: b.code),
          child: Row(children: [
            const IconBadge(Icons.local_activity_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.code, style: AppTheme.mono(13, weight: FontWeight.w700, color: AppColors.forest)),
                const SizedBox(height: 3),
                Text('${b.itemsText} · ${labelJam(b.slot)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
            ),
            const SizedBox(width: 8),
            Text(rupiah(b.total), style: AppTheme.price(13.5)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ]),
        ),
      );
}
