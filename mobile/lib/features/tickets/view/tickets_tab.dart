import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/api_client.dart';
import '../../../data/app_state.dart';
import '../../../models/booking.dart';
import '../../../models/ticket.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/format.dart';
import '../../../utils/routes.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_background.dart';
import '../../booking/view/booking_section.dart';
import '../../booking/viewmodel/booking_controller.dart';
import '../../../widgets/common.dart';
import '../../crowd/view/crowd_widgets.dart';
import '../../../widgets/glass.dart';
import 'eticket_screen.dart';

// Tab Tiket & Booking, dibagi tiga segmen supaya satu tugas per tampilan:
// Tiket Masuk (beli tiket), Sewa & Wahana (booking), dan Riwayat (tiket dan invoice per nomor WhatsApp, tanpa login).
// Nomor terakhir yang dipakai membeli terisi otomatis (shared_preferences).
const double _ticketCardHeight = 208;
const double _ticketCardSeam = 80;
const double _ticketNotchRadius = 11;

class _TicketCardClipper extends CustomClipper<Path> {
  const _TicketCardClipper();

  @override
  Path getClip(Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      );
    final notches = Path()
      ..addOval(
        Rect.fromCircle(
          center: const Offset(0, _ticketCardSeam),
          radius: _ticketNotchRadius,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, _ticketCardSeam),
          radius: _ticketNotchRadius,
        ),
      );
    return Path.combine(PathOperation.difference, outline, notches);
  }

  @override
  bool shouldReclip(covariant _TicketCardClipper oldClipper) => false;
}

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
  // Pencarian riwayat ke server sedang berjalan, dan pesan bila server tidak terjangkau.
  bool _syncing = false;
  String? _syncError;

  @override
  void initState() {
    super.initState();
    // Diisi di sini (bukan saat pertama dibaca) supaya perubahan nomor sesudahnya pasti terdeteksi.
    _lastSaved = _state.savedWhatsapp;
    _query = _lastSaved;
    _whatsapp = TextEditingController(text: _lastSaved);
    _state.addListener(_onStateChanged);
    _sync(_query);
  }

  // Mengambil riwayat tiket nomor ini dari server. Bila gagal, riwayat yang tersimpan di perangkat tetap tampil.
  Future<void> _sync(String wa) async {
    if (wa.isEmpty) return;
    setState(() {
      _syncing = true;
      _syncError = null;
    });
    try {
      await _state.syncHistory(wa);
    } on ApiException catch (e) {
      if (mounted) {
        _syncError = e.offline ? 'Tidak dapat terhubung ke server.' : e.message;
      }
    }
    if (mounted) setState(() => _syncing = false);
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
    _sync(_query);
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
            photo: 'assets/images/onboarding-air-jernih.jpg',
            child: HeaderSegments(
              labels: const ['Tiket Masuk', 'Sewa & Wahana', 'Riwayat'],
              index: _segment,
              onChanged: (i) => setState(() => _segment = i),
            ),
          ),
          // Total dan tombol Lanjut Booking mengambang di atas tab bar saat segmen Sewa & Wahana dibuka.
          overlay: _segment == 1
              ? Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: BookingBar(controller: _booking),
                )
              : null,
          // Segmen yang tidak dibuka hanya disembunyikan (Offstage), jadi pilihan dan pencarian tidak hilang.
          children: [
            Offstage(offstage: _segment != 0, child: _ticketSegment(context)),
            Offstage(
              offstage: _segment != 1,
              child: BookingSection(controller: _booking),
            ),
            Offstage(
              offstage: _segment != 2,
              child: _historySegment(context, tickets, bookings),
            ),
          ],
        );
      },
    );
  }

  // Segmen Tiket Masuk: kartu foto beli tiket (seluruh kartu bisa diketuk) dan info singkat sebelum datang.
  Widget _ticketSegment(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 20),
      Pressable(
        onTap: () => Navigator.pushNamed(context, AppRoutes.buyTicket),
        semanticLabel: 'Beli tiket masuk online',
        child: ClipPath(
          clipper: const _TicketCardClipper(),
          clipBehavior: Clip.antiAlias,
          child: ColoredBox(
            color: AppColors.forest,
            child: SizedBox(
              height: _ticketCardHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bagian atas tiket: ikon, judul, dan keterangan singkat.
                  SizedBox(
                    height: _ticketCardSeam,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: AppColors.kaca,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.ticket_fill,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Beli Tiket Masuk Online',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.headline.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Tunjukkan QR di pintu, tanpa antre',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.footnote.copyWith(
                                    color: AppColors.putih72,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bagian bawah tiket: harga dan tombol putih "Beli tiket".
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _state.hargaTiket == null
                                        ? '—'
                                        : rupiah(_state.hargaTiket!),
                                    style: AppText.hero(
                                      40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '/ orang',
                                  style: AppText.footnote.copyWith(
                                    color: AppColors.putih72,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            height: 46,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(23),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Beli tiket',
                                  style: AppText.headline.copyWith(
                                    fontSize: 15,
                                    color: AppColors.forest,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.arrow_right,
                                  size: 18,
                                  color: AppColors.forest,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      GroupedList(
        header: 'Sebelum datang',
        children: [
          ListRow(
            icon: CupertinoIcons.clock,
            title: 'Jam buka',
            subtitle: 'Weekday 08.00-16.00 · Weekend s/d 17.00',
          ),
          ListRow(
            icon: CupertinoIcons.person_2,
            title: 'Balita gratis',
            subtitle: 'Tiket untuk usia 3 tahun ke atas',
          ),
          ListRow(
            icon: Icons.local_parking,
            title: 'Parkir',
            subtitle: _state.parkirText,
          ),
        ],
      ),
    ],
  );

  // Segmen Riwayat: cari tiket dan invoice dengan nomor WhatsApp yang dipakai saat membeli.
  Widget _historySegment(
    BuildContext context,
    List<Ticket> tickets,
    List<Booking> bookings,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionLabel('Nomor WhatsApp', top: 20),
      Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _search(),
                decoration: const InputDecoration(
                  hintText: '081234567890',
                  prefixIcon: Icon(CupertinoIcons.phone, size: 20),
                ),
                validator: Validators.whatsapp,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 84,
              child: PrimaryButton(label: 'Cari', onPressed: _search),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      if (_syncing)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(minHeight: 3),
        ),
      if (_syncError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _syncError!,
            style: AppText.footnote.copyWith(color: AppColors.coral),
          ),
        ),
      if (_query.isEmpty)
        _empty(
          'Masukkan nomor WhatsApp yang dipakai saat membeli untuk melihat riwayat tiket dan invoice.',
        )
      else if (tickets.isEmpty && bookings.isEmpty)
        _empty('Belum ada tiket atau invoice untuk nomor $_query.')
      else ...[
        if (tickets.isNotEmpty)
          GroupedList(
            header: 'Tiket · $_query',
            children: [for (final t in tickets) _ticketRow(context, t)],
          ),
        if (bookings.isNotEmpty)
          GroupedList(
            header: 'Invoice Sewa & Wahana',
            children: [for (final b in bookings) _bookingRow(context, b)],
          ),
      ],
    ],
  );

  Widget _empty(String text) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      child: Column(
        children: [
          const Icon(CupertinoIcons.ticket, size: 32, color: AppColors.leaf),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: AppText.subheadline),
        ],
      ),
    ),
  );

  Widget _ticketRow(BuildContext context, Ticket t) => ListRow(
    icon: CupertinoIcons.qrcode,
    title: t.code,
    titleStyle: AppText.number(17),
    subtitle:
        '${t.people} orang · ${t.total == null ? '—' : rupiah(t.total!)} · dibeli ${t.boughtAt}',
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TicketStatusChip(t.status),
        const SizedBox(width: 6),
        const Icon(
          CupertinoIcons.chevron_forward,
          size: 16,
          color: AppColors.abu,
        ),
      ],
    ),
    // [P5 Navigator.push] Membuka e-tiket dan mengirim kode lewat constructor ETicketScreen.
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ETicketScreen(code: t.code)),
    ),
  );

  Widget _bookingRow(BuildContext context, Booking b) => ListRow(
    icon: CupertinoIcons.doc_text,
    title: b.code,
    titleStyle: AppText.number(17),
    subtitle: '${b.itemsText} · ${labelJam(b.slot)}',
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rupiah(b.total),
          style: AppText.number(15, color: AppColors.forest),
        ),
        const SizedBox(width: 6),
        const Icon(
          CupertinoIcons.chevron_forward,
          size: 16,
          color: AppColors.abu,
        ),
      ],
    ),
    // [P5 Named Route + argumen] Membuka invoice dengan mengirim kode booking.
    onTap: () =>
        Navigator.pushNamed(context, AppRoutes.invoice, arguments: b.code),
  );
}
