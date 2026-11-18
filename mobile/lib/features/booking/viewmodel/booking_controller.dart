import 'package:flutter/material.dart';

import '../../../data/app_state.dart';
import '../../../data/api_client.dart';
import '../../../models/booking.dart';
import '../../../models/wahana.dart';
import '../../../utils/routes.dart';

// Isi Sewa & Booking: jam kunjungan (selang 1 jam) dan jumlah tiap alat sewa atau wahana dari backend.
// Disimpan di controller supaya daftar (BookingSection) dan bar total mengambang (BookingBar) memakai data yang sama.
class BookingController extends ChangeNotifier {
  BookingController() {
    _bookingCount = AppState.instance.bookings.length;
    _revision = AppState.instance.wahanaRevision;
    AppState.instance.addListener(_onStateChanged);
  }

  late Future<List<Wahana>> items = _load();
  List<Wahana> _loaded = const [];
  // Pesan galat dari server; daftar tetap kosong (tidak ada katalog cadangan di perangkat).
  String? error;
  bool loading = true;
  final Map<String, int> qty = {};
  // Pilihan jam booking dari server (GET /booking-slots). Kosong sampai server menjawab.
  List<String> slots = const [];
  String? slot;
  late int _bookingCount;
  late int _revision;

  // Mengambil wahana dari backend (GET /rides) dan pilihan jam dari backend (GET /booking-slots).
  // Gagal terhubung: daftar dikosongkan dan banner "Coba lagi" ditampilkan; tidak ada data bawaan.
  Future<List<Wahana>> _load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final rides = await ApiClient.fetchWahana();
      final pilihan = await ApiClient.fetchBookingSlots();
      _loaded = rides;
      slots = [for (final s in pilihan) s.id];
      if (!slots.contains(slot)) slot = slots.isEmpty ? null : slots.first;
      if (_loaded.isEmpty) error = 'Belum ada wahana aktif di server.';
    } on ApiException catch (e) {
      _loaded = const [];
      slots = const [];
      slot = null;
      error = e.message;
    } catch (_) {
      _loaded = const [];
      slots = const [];
      slot = null;
      error = 'Gagal memuat daftar wahana dari server.';
    } finally {
      loading = false;
      notifyListeners();
    }
    return _loaded;
  }

  // Tombol "Coba lagi" di banner: muat ulang dari server.
  void reload() {
    items = _load();
    notifyListeners();
  }

  int get total =>
      _loaded.fold(0, (sum, w) => sum + (qty[w.id] ?? 0) * w.price);

  void setSlot(String value) {
    slot = value;
    notifyListeners();
  }

  void setQty(String id, int value) {
    qty[id] = value;
    notifyListeners();
  }

  // Tombol Lanjut Booking: minimal satu item, lalu buka Checkout sambil membawa isi booking.
  // Setiap baris membawa rideId supaya Checkout bisa mengirim items:[{rideId, qty}] ke server.
  void next(BuildContext context) {
    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam booking belum tersedia dari server.'),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 84),
        ),
      );
      return;
    }
    final chosen = _loaded.where((w) => (qty[w.id] ?? 0) > 0).toList();
    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu wahana dulu.'),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 84),
        ),
      );
      return;
    }
    final draft = BookingDraft(
      slot: slot!,
      lines: [
        for (final w in chosen)
          BookingLine(
            name: w.label,
            qty: qty[w.id]!,
            price: w.price,
            rideId: w.id,
          ),
      ],
    );
    // [P5 Kirim data antar halaman] Isi booking dikirim sebagai arguments ke rute Checkout.
    Navigator.pushNamed(context, AppRoutes.checkout, arguments: draft);
  }

  // Setelah booking berhasil dibayar, pilihan item dikosongkan lagi. Daftar wahana dimuat ulang
  // saat AppState menandai daftarnya basi (mis. ada wahana dinonaktifkan admin).
  void _onStateChanged() {
    final s = AppState.instance;
    if (s.wahanaRevision != _revision) {
      _revision = s.wahanaRevision;
      reload();
    }
    final count = s.bookings.length;
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
