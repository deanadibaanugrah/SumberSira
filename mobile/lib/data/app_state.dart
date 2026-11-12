import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';
import '../models/review.dart';
import '../models/ticket.dart';
import '../utils/format.dart';
import 'dummy_data.dart';

// Penyimpanan data sederhana tanpa backend. Layar yang mendengarkan AppState
// otomatis diperbarui (ChangeNotifier) saat ada tiket baru, booking baru, atau tiket discan.
// Aplikasi pengunjung tidak memakai login: riwayat tiket dan booking dikelompokkan per nomor WhatsApp.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  static const int capacity = 300;

  final List<Ticket> tickets = DummyData.seedTickets();
  final List<Booking> bookings = [];
  final List<Review> reviews = [...DummyData.reviews];

  // Kunci data yang disimpan di perangkat, tetap ada walau aplikasi ditutup.
  static const _waKey = 'whatsapp_terakhir';
  static const _reminderKey = 'pengingat_jam_sepi';
  static const _onboardingKey = 'sudah_onboarding';
  static const _ticketsKey = 'riwayat_tiket';
  static const _bookingsKey = 'riwayat_booking';
  String savedWhatsapp = '';
  bool quietReminder = false;
  bool onboardingDone = false;

  // [P6 Plugin shared_preferences] Membaca pengaturan dan riwayat tersimpan saat aplikasi dibuka.
  // [P2 Null Safety] Operator ?? memberi nilai bawaan kalau data belum pernah disimpan.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    savedWhatsapp = prefs.getString(_waKey) ?? '';
    quietReminder = prefs.getBool(_reminderKey) ?? false;
    onboardingDone = prefs.getBool(_onboardingKey) ?? false;
    for (final raw in prefs.getStringList(_ticketsKey) ?? const <String>[]) {
      tickets.add(Ticket.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
    for (final raw in prefs.getStringList(_bookingsKey) ?? const <String>[]) {
      bookings.add(Booking.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
  }

  // Menyimpan tiket dan booking milik perangkat ini sebagai daftar teks JSON.
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ticketsKey, [for (final t in tickets.where((t) => t.mine)) jsonEncode(t.toJson())]);
    await prefs.setStringList(_bookingsKey, [for (final b in bookings) jsonEncode(b.toJson())]);
  }

  // Menyimpan pilihan pengingat jam sepi (Switch di Profil).
  Future<void> setQuietReminder(bool value) async {
    quietReminder = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, value);
  }

  // Onboarding cukup tampil sekali. Setelah selesai atau dilewati, Splash langsung ke Beranda.
  Future<void> finishOnboarding() async {
    onboardingDone = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // Menyimpan nomor WhatsApp terakhir: form berikutnya terisi otomatis dan Tiket Saya
  // langsung menampilkan riwayat nomor ini.
  Future<void> saveWhatsapp(String value) async {
    savedWhatsapp = nomorWa(value);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_waKey, savedWhatsapp);
  }

  // Tiket yang dibeli lewat aplikasi ini, yang terbaru di atas.
  List<Ticket> get myTickets => tickets.where((t) => t.mine).toList().reversed.toList();

  // Riwayat tiket untuk satu nomor WhatsApp, yang terbaru di atas.
  List<Ticket> ticketsFor(String whatsapp) {
    final wa = nomorWa(whatsapp);
    if (wa.isEmpty) return [];
    return tickets.where((t) => t.whatsapp.isNotEmpty && nomorWa(t.whatsapp) == wa).toList().reversed.toList();
  }

  // Riwayat booking sewa dan wahana untuk satu nomor WhatsApp, yang terbaru di atas.
  List<Booking> bookingsFor(String whatsapp) {
    final wa = nomorWa(whatsapp);
    if (wa.isEmpty) return [];
    return bookings.where((b) => nomorWa(b.whatsapp) == wa).toList().reversed.toList();
  }

  // Live Crowd = jumlah orang dari tiket yang sudah discan masuk, dibagi kapasitas.
  int get inside => tickets.where((t) => t.status == TicketStatus.inside).fold(0, (sum, t) => sum + t.people);
  int get percent => (inside / capacity * 100).round();
  String get crowdLabel => labelFor(percent);

  // Label keramaian dari persen kapasitas: di bawah 40% Sepi, sampai 75% Sedang, di atasnya Ramai.
  static String labelFor(int percent) => percent < 40 ? 'Sepi' : (percent <= 75 ? 'Sedang' : 'Ramai');

  // Membuat tiket baru dari form. Kodenya melanjutkan nomor tiket terakhir.
  Ticket buyTicket({required String name, required String whatsapp, required int adults, required int kids, required Parking parking, PaymentMethod payment = PaymentMethod.qris, String arrival = ''}) {
    final next = tickets.map((t) => int.parse(t.code.substring(3))).reduce(max) + 1;
    final ticket = Ticket(
      code: 'TK-$next',
      name: name.trim(),
      whatsapp: nomorWa(whatsapp),
      adults: adults,
      kids: kids,
      parking: parking,
      payment: payment,
      arrival: arrival,
      boughtAt: jamSekarang(),
      date: tanggalHariIni(),
      mine: true,
    );
    tickets.add(ticket);
    notifyListeners();
    _saveHistory();
    return ticket;
  }

  // Menyimpan booking setelah pembayaran QRIS selesai. Kode: SS-tanggal-nomor urut, mis. SS-20261014-043.
  Booking addBooking(BookingRequest request) {
    final booking = Booking(
      code: 'SS-${tanggalKode()}-${(43 + bookings.length).toString().padLeft(3, '0')}',
      name: request.name.trim(),
      whatsapp: nomorWa(request.whatsapp),
      slot: request.draft.slot,
      lines: request.draft.lines,
      orderedAt: jamSekarang(),
      date: tanggalHariIni(),
    );
    bookings.add(booking);
    notifyListeners();
    _saveHistory();
    return booking;
  }

  Ticket? find(String code) {
    for (final t in tickets) {
      if (t.code == code) return t;
    }
    return null;
  }

  Booking? findBooking(String code) {
    for (final b in bookings) {
      if (b.code == code) return b;
    }
    return null;
  }

  // Simulasi scan petugas di pintu masuk: status jadi Di dalam dan Live Crowd naik.
  void checkIn(String code) {
    final t = find(code);
    if (t == null || t.status != TicketStatus.waiting) return;
    t.status = TicketStatus.inside;
    t.checkInAt = jamSekarang();
    notifyListeners();
    if (t.mine) _saveHistory();
  }

  // Ulasan baru tampil paling atas (disimpan di memori saja).
  void addReview(Review review) {
    reviews.insert(0, review);
    notifyListeners();
  }

  // Rata-rata bintang, dihitung dari ringkasan 132 ulasan (4,8) ditambah ulasan baru di aplikasi.
  double get rating {
    const baseCount = 132, baseRating = 4.8;
    final added = reviews.length - DummyData.reviews.length;
    final newStars = reviews.take(added).fold(0, (sum, r) => sum + r.stars);
    return (baseRating * baseCount + newStars) / (baseCount + added);
  }

  int get reviewCount => 132 + reviews.length - DummyData.reviews.length;
}
