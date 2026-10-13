import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ticket.dart';
import '../utils/format.dart';
import 'dummy_data.dart';

// Penyimpanan data sederhana di memori (tanpa backend). Layar yang mendengarkan AppState
// otomatis diperbarui (ChangeNotifier) saat ada tiket baru atau tiket discan.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  static const int capacity = 300;

  final List<Ticket> tickets = DummyData.seedTickets();

  // Pengaturan yang disimpan di perangkat, tetap ada walau aplikasi ditutup.
  static const _waKey = 'whatsapp_terakhir';
  static const _reminderKey = 'pengingat_jam_sepi';
  String savedWhatsapp = '';
  bool quietReminder = false;

  // [P6 Plugin shared_preferences] Membaca pengaturan tersimpan saat aplikasi dibuka.
  // [P2 Null Safety] Operator ?? memberi nilai bawaan kalau data belum pernah disimpan.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    savedWhatsapp = prefs.getString(_waKey) ?? '';
    quietReminder = prefs.getBool(_reminderKey) ?? false;
  }

  // Menyimpan pilihan pengingat jam sepi (Switch di Profil).
  Future<void> setQuietReminder(bool value) async {
    quietReminder = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, value);
  }

  // Menyimpan nomor WhatsApp terakhir supaya form tiket berikutnya terisi otomatis.
  Future<void> saveWhatsapp(String value) async {
    savedWhatsapp = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_waKey, savedWhatsapp);
  }

  // Tiket yang dibeli lewat aplikasi ini, yang terbaru di atas.
  List<Ticket> get myTickets => tickets.where((t) => t.mine).toList().reversed.toList();

  // Live Crowd = jumlah orang dari tiket yang sudah discan masuk, dibagi kapasitas.
  int get inside => tickets.where((t) => t.status == TicketStatus.inside).fold(0, (sum, t) => sum + t.people);
  int get percent => (inside / capacity * 100).round();
  String get crowdLabel => percent < 40 ? 'Sepi' : (percent <= 75 ? 'Sedang' : 'Ramai');

  // Membuat tiket baru dari form. Kodenya melanjutkan nomor tiket terakhir.
  Ticket buyTicket({required String name, required String whatsapp, required int adults, required int kids, required Parking parking, PaymentMethod payment = PaymentMethod.qris, String arrival = ''}) {
    final next = tickets.map((t) => int.parse(t.code.substring(3))).reduce(max) + 1;
    final ticket = Ticket(
      code: 'TK-$next',
      name: name.trim(),
      whatsapp: whatsapp.trim(),
      adults: adults,
      kids: kids,
      parking: parking,
      payment: payment,
      arrival: arrival,
      boughtAt: jamSekarang(),
      mine: true,
    );
    tickets.add(ticket);
    notifyListeners();
    return ticket;
  }

  Ticket? find(String code) {
    for (final t in tickets) {
      if (t.code == code) return t;
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
  }
}
