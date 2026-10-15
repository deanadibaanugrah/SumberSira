import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../data/dummy_data.dart';
import '../models/booking.dart';
import '../models/wahana.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import 'common.dart';

// Bagian Sewa & Booking di menu Tiket & Booking: pilih jam (selang 1 jam), jumlah tiap alat sewa
// atau wahana (dibaca dari mock JSON), lalu Lanjut Booking ke Checkout.
class BookingSection extends StatefulWidget {
  const BookingSection({super.key});

  @override
  State<BookingSection> createState() => _BookingSectionState();
}

class _BookingSectionState extends State<BookingSection> {
  late final Future<List<Wahana>> _items = _load();
  final Map<String, int> _qty = {};
  String _slot = DummyData.bookingSlots.first;
  late int _bookingCount;

  @override
  void initState() {
    super.initState();
    _bookingCount = AppState.instance.bookings.length;
    AppState.instance.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChanged);
    super.dispose();
  }

  // Setelah booking berhasil dibayar, pilihan item dikosongkan lagi.
  void _onStateChanged() {
    final count = AppState.instance.bookings.length;
    if (count == _bookingCount) return;
    setState(() {
      _bookingCount = count;
      _qty.clear();
    });
  }

  // Membaca assets/data/wahana.json (mock JSON) lalu mengubahnya menjadi daftar objek Wahana.
  // async/await karena membaca file butuh waktu; hasilnya ditampilkan lewat FutureBuilder.
  Future<List<Wahana>> _load() async {
    final raw = await rootBundle.loadString('assets/data/wahana.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Wahana.fromJson(e as Map<String, dynamic>)).toList();
  }

  int _total(List<Wahana> items) => items.fold(0, (sum, w) => sum + (_qty[w.id] ?? 0) * w.price);

  // Tombol Lanjut Booking: minimal satu item, lalu buka Checkout sambil membawa isi booking.
  void _next(List<Wahana> items) {
    final chosen = items.where((w) => (_qty[w.id] ?? 0) > 0).toList();
    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal satu wahana dulu.')));
      return;
    }
    final draft = BookingDraft(
      slot: _slot,
      lines: [for (final w in chosen) BookingLine(name: w.label, qty: _qty[w.id]!, price: w.price)],
    );
    // [P5 Kirim data antar halaman] Isi booking dikirim sebagai arguments ke rute Checkout.
    Navigator.pushNamed(context, AppRoutes.checkout, arguments: draft);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Wahana>>(
      future: _items,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Wahana>[];
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SectionLabel('Pilih Jam Kunjungan', top: 0),
          // Jam booking selang 1 jam, bisa digeser ke samping.
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: DummyData.bookingSlots.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final s = DummyData.bookingSlots[i];
                return GlassCard(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  color: s == _slot ? AppColors.leaf.withValues(alpha: .8) : null,
                  onTap: () => setState(() => _slot = s),
                  child: Text(labelJam(s), style: AppTheme.mono(11)),
                );
              },
            ),
          ),
          const SectionLabel('Daftar Sewa & Wahana'),
          if (snapshot.connectionState != ConnectionState.done)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else
            for (final w in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.leaf.withValues(alpha: .35),
                      child: Icon(w.icon, size: 19, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(w.label, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 3),
                        Text(rupiah(w.price), style: AppTheme.mono(11)),
                      ]),
                    ),
                    StepperControl(
                      value: _qty[w.id] ?? 0,
                      label: w.name,
                      onChanged: (v) => setState(() => _qty[w.id] = v),
                    ),
                  ]),
                ),
              ),
          const SizedBox(height: 4),
          // Total dan tombol lanjut di akhir daftar.
          GlassCard(
            color: AppColors.leaf.withValues(alpha: .25),
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total · ${labelJam(_slot)}', style: TextStyle(fontSize: 10, color: AppColors.white(.75))),
                  Text(rupiah(_total(items)), style: AppTheme.mono(15, weight: FontWeight.w600)),
                ]),
              ),
              SizedBox(width: 160, child: PrimaryButton(label: 'Lanjut Booking', height: 44, onPressed: () => _next(items))),
            ]),
          ),
        ]);
      },
    );
  }
}
