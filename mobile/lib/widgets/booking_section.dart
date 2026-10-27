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
        // Daftar dikelompokkan per kategori dari JSON (Sewa Alat, Wahana) supaya mudah dicari.
        final categories = {for (final w in items) w.category};
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SectionLabel('Pilih Jam Kunjungan', top: 0, step: 1),
          // Jam booking selang 1 jam, bisa digeser ke samping.
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: DummyData.bookingSlots.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = DummyData.bookingSlots[i];
                final active = s == _slot;
                return AppCard(
                  radius: 22,
                  shadow: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  color: active ? AppColors.forest : Colors.white,
                  borderColor: active ? AppColors.forest : AppColors.line,
                  onTap: () => setState(() => _slot = s),
                  child: Text(
                    labelJam(s),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.ink),
                  ),
                );
              },
            ),
          ),
          const SectionLabel('Daftar Sewa & Wahana', step: 2),
          if (snapshot.connectionState != ConnectionState.done)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else
            for (final c in categories) ...[
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(c.toUpperCase(), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: .8, color: AppColors.muted)),
              ),
              for (final w in items.where((w) => w.category == c)) _itemCard(w),
            ],
          const SizedBox(height: 8),
          // Total dan tombol lanjut di akhir daftar.
          AppCard(
            color: AppColors.forest,
            borderColor: AppColors.forest,
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total · ${labelJam(_slot)}', style: TextStyle(fontSize: 12, color: AppColors.white(.8))),
                  const SizedBox(height: 2),
                  Text(rupiah(_total(items)), style: AppTheme.price(20, color: Colors.white)),
                ]),
              ),
              SizedBox(width: 156, child: PrimaryButton(label: 'Lanjut Booking', height: 48, inverted: true, onPressed: () => _next(items))),
            ]),
          ),
        ]);
      },
    );
  }

  // Satu kartu alat sewa atau wahana. Kartu yang sudah dipilih diberi garis hijau.
  Widget _itemCard(Wahana w) {
    final qty = _qty[w.id] ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        borderColor: qty > 0 ? AppColors.leaf : AppColors.line,
        child: Row(children: [
          IconBadge(w.icon, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(rupiah(w.price), style: AppTheme.price(13.5)),
            ]),
          ),
          StepperControl(
            value: qty,
            label: w.name,
            onChanged: (v) => setState(() => _qty[w.id] = v),
          ),
        ]),
      ),
    );
  }
}
