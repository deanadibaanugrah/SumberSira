import 'ticket.dart';

// Satu tarif parkir dari server (GET /pricing), mis. key "motor", label "Motor", harga 3000.
class ParkingTarif {
  const ParkingTarif({required this.key, required this.label, required this.price});

  factory ParkingTarif.fromJson(Map<String, dynamic> j) => ParkingTarif(
        key: j['key'] as String,
        label: (j['label'] as String?) ?? '',
        price: (j['price'] as num?)?.toInt() ?? 0,
      );

  final String key;
  final String label;
  final int price;
}

// Tarif dari backend (GET /pricing): harga tiket per orang, kapasitas, dan tarif parkir.
// Hanya untuk pratinjau di form; total sebenarnya tetap dihitung server saat tiket dibuat.
class PricingData {
  const PricingData({
    required this.ticketPricePerPerson,
    required this.capacity,
    required this.parking,
  });

  factory PricingData.fromJson(Map<String, dynamic> j) => PricingData(
        ticketPricePerPerson: (j['ticketPricePerPerson'] as num?)?.toInt() ?? Ticket.pricePerPerson,
        capacity: (j['capacity'] as num?)?.toInt() ?? 300,
        parking: [
          for (final e in (j['parking'] as List? ?? const [])) ParkingTarif.fromJson(e as Map<String, dynamic>),
        ],
      );

  final int ticketPricePerPerson;
  final int capacity;
  final List<ParkingTarif> parking;

  // Tarif parkir untuk satu pilihan di form. Bila server tidak mengirim kuncinya, pakai tarif bawaan enum.
  int tarif(Parking p) {
    for (final t in parking) {
      if (t.key == p.name) return t.price;
    }
    return p.price;
  }
}
