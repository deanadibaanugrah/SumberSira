import 'dart:math';

import 'package:flutter/foundation.dart';

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

  // Tiket yang dibeli lewat aplikasi ini, yang terbaru di atas.
  List<Ticket> get myTickets => tickets.where((t) => t.mine).toList().reversed.toList();

  // Live Crowd = jumlah orang dari tiket yang sudah discan masuk, dibagi kapasitas.
  int get inside => tickets.where((t) => t.status == TicketStatus.inside).fold(0, (sum, t) => sum + t.people);
  int get percent => (inside / capacity * 100).round();
  String get crowdLabel => percent < 40 ? 'Sepi' : (percent <= 75 ? 'Sedang' : 'Ramai');

  // Membuat tiket baru dari form. Kodenya melanjutkan nomor tiket terakhir.
  Ticket buyTicket({required String name, required String whatsapp, required int adults, required int kids, required Parking parking}) {
    final next = tickets.map((t) => int.parse(t.code.substring(3))).reduce(max) + 1;
    final ticket = Ticket(
      code: 'TK-$next',
      name: name.trim(),
      whatsapp: whatsapp.trim(),
      adults: adults,
      kids: kids,
      parking: parking,
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
