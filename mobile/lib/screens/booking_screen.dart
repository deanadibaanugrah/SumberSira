import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/wahana.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Sewa & Booking: daftar alat sewa dan wahana dibaca dari mock JSON, pilih jam dan jumlah item.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const _slots = ['08-10', '10-12', '12-14', '14-16'];
  static const _busySlots = {'10-12', '12-14', '14-16'};
  late final Future<List<Wahana>> _items = _load();
  final Map<String, int> _qty = {};
  String _slot = _slots.first;

  // Membaca assets/data/wahana.json (mock JSON) lalu mengubahnya menjadi daftar objek Wahana.
  // async/await karena membaca file butuh waktu; hasilnya ditampilkan lewat FutureBuilder.
  Future<List<Wahana>> _load() async {
    final raw = await rootBundle.loadString('assets/data/wahana.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Wahana.fromJson(e as Map<String, dynamic>)).toList();
  }

  int _total(List<Wahana> items) => items.fold(0, (sum, w) => sum + (_qty[w.id] ?? 0) * w.price);

  // Tombol Pesan: minimal satu item, lalu tampilkan ringkasan booking.
  void _order(List<Wahana> items) {
    final chosen = items.where((w) => (_qty[w.id] ?? 0) > 0).toList();
    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal satu wahana dulu.')));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.forest,
        title: Text('Booking Berhasil!', style: AppTheme.display(18)),
        content: Text(
          'Jam $_slot\n${chosen.map((w) => '${_qty[w.id]}x ${w.name}').join('\n')}\n\nTotal ${rupiah(_total(items))}',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.leaf),
            onPressed: () {
              Navigator.pop(context);
              setState(_qty.clear);
            },
            child: const Text('Oke'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Wahana>>(
      future: _items,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Wahana>[];
        return Scaffold(
          body: AppBackground(
            child: ResponsiveBody(children: [
              const PageHeader(title: 'Sewa & Booking Wahana'),
              const SectionLabel('Pilih Jam Kunjungan', top: 0),
              Row(children: [
                for (final s in _slots)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GlassCard(
                        radius: 18,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: s == _slot ? AppColors.leaf.withValues(alpha: .8) : null,
                        onTap: () => setState(() => _slot = s),
                        child: Center(child: Text(s, style: AppTheme.mono(11))),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(height: 6),
              Text('Jam ${_busySlots.join(', ')} biasanya ramai.', style: TextStyle(fontSize: 10, color: AppColors.white(.65))),
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
                          child: Icon(w.category == 'Wahana' ? Icons.attractions_outlined : Icons.pool_outlined, size: 18, color: Colors.white),
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
            ]),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(color: AppColors.ink, border: Border(top: BorderSide(color: AppColors.white(.15)))),
              child: Row(children: [
                Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Total', style: TextStyle(fontSize: 10, color: AppColors.white(.7))),
                    Text(rupiah(_total(items)), style: AppTheme.mono(15, weight: FontWeight.w600)),
                  ]),
                ),
                SizedBox(width: 170, child: PrimaryButton(label: 'Pesan Sekarang', height: 44, onPressed: () => _order(items))),
              ]),
            ),
          ),
        );
      },
    );
  }
}
