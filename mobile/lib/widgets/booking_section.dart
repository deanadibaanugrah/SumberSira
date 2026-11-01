import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../data/api_client.dart';
import '../data/dummy_data.dart';
import '../models/booking.dart';
import '../models/wahana.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import 'common.dart';
import 'glass.dart';

// Isi Sewa & Booking: jam kunjungan (selang 1 jam) dan jumlah tiap alat sewa atau wahana (dibaca dari mock JSON).
// Disimpan di controller supaya daftar (BookingSection) dan bar total mengambang (BookingBar) memakai data yang sama.
class BookingController extends ChangeNotifier {
  BookingController() {
    _bookingCount = AppState.instance.bookings.length;
    AppState.instance.addListener(_onStateChanged);
  }

  late Future<List<Wahana>> items = _load();
  List<Wahana> _loaded = const [];
  bool offline = false; // true = server tidak terjangkau, memakai data bawaan di assets
  final Map<String, int> qty = {};
  String slot = DummyData.bookingSlots.first;
  late int _bookingCount;

  // Membaca assets/data/wahana.json (mock JSON) lalu mengubahnya menjadi daftar objek Wahana.
  // async/await karena membaca file butuh waktu; hasilnya ditampilkan lewat FutureBuilder.
    // Mengambil wahana dari backend (GET /rides). Kalau server tidak terjangkau, aplikasi memakai
  // data bawaan assets/data/wahana.json supaya tetap bisa dicoba, dan banner "Coba lagi" ditampilkan.
  Future<List<Wahana>> _load() async {
    try {
      _loaded = await ApiClient.fetchWahana();
      offline = false;
    } catch (_) {
      final raw = await rootBundle.loadString('assets/data/wahana.json');
      _loaded = (jsonDecode(raw) as List<dynamic>).map((e) => Wahana.fromJson(e as Map<String, dynamic>)).toList();
      offline = true;
    }
    notifyListeners();
    return _loaded;
  }

  // Tombol "Coba lagi" di banner: muat ulang dari server.
  void reload() {
    items = _load();
    notifyListeners();
  }

  int get total => _loaded.fold(0, (sum, w) => sum + (qty[w.id] ?? 0) * w.price);

  void setSlot(String value) {
    slot = value;
    notifyListeners();
  }

  void setQty(String id, int value) {
    qty[id] = value;
    notifyListeners();
  }

  // Tombol Lanjut Booking: minimal satu item, lalu buka Checkout sambil membawa isi booking.
  void next(BuildContext context) {
    final chosen = _loaded.where((w) => (qty[w.id] ?? 0) > 0).toList();
    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu wahana dulu.'), margin: EdgeInsets.fromLTRB(16, 0, 16, 84)),
      );
      return;
    }
    final draft = BookingDraft(
      slot: slot,
      lines: [for (final w in chosen) BookingLine(name: w.label, qty: qty[w.id]!, price: w.price)],
    );
    // [P5 Kirim data antar halaman] Isi booking dikirim sebagai arguments ke rute Checkout.
    Navigator.pushNamed(context, AppRoutes.checkout, arguments: draft);
  }

  // Setelah booking berhasil dibayar, pilihan item dikosongkan lagi.
  void _onStateChanged() {
    final count = AppState.instance.bookings.length;
    if (count == _bookingCount) return;
    _bookingCount = count;
    qty.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChanged);
    super.dispose();
  }
}

// Daftar Sewa & Booking: pilihan jam di atas, lalu list per kategori (Sewa Alat, Wahana) dengan stepper.
class BookingSection extends StatelessWidget {
  const BookingSection({super.key, required this.controller});

  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => FutureBuilder<List<Wahana>>(
        future: controller.items,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Wahana>[];
          // Daftar dikelompokkan per kategori dari JSON supaya mudah dicari.
          final categories = {for (final w in items) w.category};
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SectionLabel('Jam kunjungan', top: 20),
            // Jam booking selang 1 jam, bisa digeser ke samping. Yang dipilih berwarna Hijau Tua.
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: DummyData.bookingSlots.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final s = DummyData.bookingSlots[i];
                  final active = s == controller.slot;
                  return Pressable(
                    onTap: () => controller.setSlot(s),
                    semanticLabel: 'Jam ${labelJam(s)}',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: active ? AppColors.forest : Colors.white, borderRadius: BorderRadius.circular(22)),
                      child: Text(labelJam(s), style: AppText.number(15, color: active ? Colors.white : AppColors.ink)),
                    ),
                  );
                },
              ),
            ),
            if (controller.offline)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(children: [
                  const Icon(Icons.cloud_off_outlined, size: 18, color: AppColors.abu),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Server tidak terjangkau. Menampilkan data bawaan.', style: AppText.footnote)),
                  TextButton(onPressed: controller.reload, child: const Text('Coba lagi')),
                ]),
              ),
            if (snapshot.connectionState != ConnectionState.done)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else
              for (final c in categories)
                GroupedList(header: c, children: [for (final w in items.where((w) => w.category == c)) _itemRow(w)]),
          ]);
        },
      ),
    );
  }

  // Satu baris alat sewa atau wahana: ikon tanpa wadah, nama, harga, dan stepper jumlah.
  Widget _itemRow(Wahana w) {
    final qty = controller.qty[w.id] ?? 0;
    return ListRow(
      icon: w.icon,
      title: w.label,
      subtitle: rupiah(w.price),
      subtitleStyle: AppText.number(13, weight: qty > 0 ? FontWeight.w700 : FontWeight.w500, color: qty > 0 ? AppColors.forest : AppColors.abu),
      trailing: StepperControl(value: qty, label: w.name, onChanged: (v) => controller.setQty(w.id, v)),
    );
  }
}

// Bar kaca mengambang di atas tab bar: total dan jam yang dipilih, lalu tombol Lanjut Booking.
class BookingBar extends StatelessWidget {
  const BookingBar({super.key, required this.controller});

  final BookingController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => TotalBar(
          label: 'Total · ${labelJam(controller.slot)}',
          amount: controller.total,
          button: 'Lanjut Booking',
          buttonWidth: 172,
          onPressed: () => controller.next(context),
        ),
      );
}
