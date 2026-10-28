import 'package:flutter/cupertino.dart';
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
import '../widgets/glass.dart';
import 'eticket_screen.dart';

// Tab Tiket & Booking, dibagi tiga segmen supaya satu tugas per tampilan:
// Tiket Masuk (beli tiket), Sewa & Wahana (booking), dan Riwayat (tiket dan invoice per nomor WhatsApp, tanpa login).
// Nomor terakhir yang dipakai membeli terisi otomatis (shared_preferences).
class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  final _formKey = GlobalKey<FormState>();
  final _state = AppState.instance;
  final _booking = BookingController();
  late final TextEditingController _whatsapp;
  // Segmen yang sedang dibuka (0 Tiket Masuk, 1 Sewa & Wahana, 2 Riwayat).
  int _segment = 0;
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
    _booking.dispose();
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
        return TabPage(
          title: 'Tiket & Booking',
          bottomExtra: _segment == 1 ? 84 : 0,
          header: TabHeader(
            title: 'Tiket & Booking',
            subtitle: 'Tanpa login, riwayat dicari lewat nomor WhatsApp',
            child: HeaderSegments(
              labels: const ['Tiket Masuk', 'Sewa & Wahana', 'Riwayat'],
              index: _segment,
              onChanged: (i) => setState(() => _segment = i),
            ),
          ),
          // Total dan tombol Lanjut Booking mengambang di atas tab bar saat segmen Sewa & Wahana dibuka.
          overlay: _segment == 1 ? Positioned(left: 0, right: 0, bottom: 10, child: BookingBar(controller: _booking)) : null,
          // Segmen yang tidak dibuka hanya disembunyikan (Offstage), jadi pilihan dan pencarian tidak hilang.
          children: [
            Offstage(offstage: _segment != 0, child: _ticketSegment(context)),
            Offstage(offstage: _segment != 1, child: BookingSection(controller: _booking)),
            Offstage(offstage: _segment != 2, child: _historySegment(context, tickets, bookings)),
          ],
        );
      },
    );
  }

  // Segmen Tiket Masuk: kartu foto beli tiket (seluruh kartu bisa diketuk) dan info singkat sebelum datang.
  Widget _ticketSegment(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 20),
        Pressable(
          onTap: () => Navigator.pushNamed(context, AppRoutes.buyTicket),
          semanticLabel: 'Beli tiket masuk online',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 268,
              child: Stack(fit: StackFit.expand, children: [
                Image.asset('assets/images/komunitas-2.jpg', fit: BoxFit.cover),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Glass(
                    radius: 20,
                    shadow: false,
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Beli Tiket Masuk Online', style: AppText.headline),
                          const SizedBox(height: 2),
                          const Text('Tunjukkan QR di pintu, tanpa antre', style: AppText.footnote),
                          const SizedBox(height: 10),
                          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                            Text(rupiah(Ticket.pricePerPerson), style: AppText.hero(28)),
                            const SizedBox(width: 4),
                            const Text('/ orang', style: AppText.footnote),
                          ]),
                        ]),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
                        child: const Icon(CupertinoIcons.arrow_right, size: 20, color: Colors.white),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
        const GroupedList(header: 'Sebelum datang', children: [
          ListRow(icon: CupertinoIcons.clock, title: 'Jam buka', subtitle: 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
          ListRow(icon: CupertinoIcons.person_2, title: 'Balita gratis', subtitle: 'Tiket untuk usia 3 tahun ke atas'),
          ListRow(icon: CupertinoIcons.car_detailed, title: 'Parkir', subtitle: 'Motor 3rb · Mobil 10rb · Bus 20rb'),
        ]),
      ]);

  // Segmen Riwayat: cari tiket dan invoice dengan nomor WhatsApp yang dipakai saat membeli.
  Widget _historySegment(BuildContext context, List<Ticket> tickets, List<Booking> bookings) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SectionLabel('Nomor WhatsApp', top: 20),
        Form(
          key: _formKey,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: TextFormField(
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _search(),
                decoration: const InputDecoration(hintText: '081234567890', prefixIcon: Icon(CupertinoIcons.phone, size: 20)),
                validator: Validators.whatsapp,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 84, child: PrimaryButton(label: 'Cari', onPressed: _search)),
          ]),
        ),
        const SizedBox(height: 8),
        if (_query.isEmpty)
          _empty('Masukkan nomor WhatsApp yang dipakai saat membeli untuk melihat riwayat tiket dan invoice.')
        else if (tickets.isEmpty && bookings.isEmpty)
          _empty('Belum ada tiket atau invoice untuk nomor $_query.')
        else ...[
          if (tickets.isNotEmpty) GroupedList(header: 'Tiket · $_query', children: [for (final t in tickets) _ticketRow(context, t)]),
          if (bookings.isNotEmpty) GroupedList(header: 'Invoice Sewa & Wahana', children: [for (final b in bookings) _bookingRow(context, b)]),
        ],
      ]);

  Widget _empty(String text) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(children: [
            const Icon(CupertinoIcons.ticket, size: 32, color: AppColors.leaf),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: AppText.subheadline),
          ]),
        ),
      );

  Widget _ticketRow(BuildContext context, Ticket t) => ListRow(
        icon: CupertinoIcons.qrcode,
        title: t.code,
        titleStyle: AppText.number(17),
        subtitle: '${t.people} orang · ${rupiah(t.total)} · dibeli ${t.boughtAt}',
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          TicketStatusChip(t.status),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppColors.abu),
        ]),
        // [P5 Navigator.push] Membuka e-tiket dan mengirim kode lewat constructor ETicketScreen.
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ETicketScreen(code: t.code))),
      );

  Widget _bookingRow(BuildContext context, Booking b) => ListRow(
        icon: CupertinoIcons.doc_text,
        title: b.code,
        titleStyle: AppText.number(17),
        subtitle: '${b.itemsText} · ${labelJam(b.slot)}',
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(rupiah(b.total), style: AppText.number(15, color: AppColors.forest)),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppColors.abu),
        ]),
        // [P5 Named Route + argumen] Membuka invoice dengan mengirim kode booking.
        onTap: () => Navigator.pushNamed(context, AppRoutes.invoice, arguments: b.code),
      );
}
