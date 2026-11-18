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

  // Semua angka wajib ada di respons server. Tidak ada nilai cadangan supaya tarif di layar
  // tidak pernah berbeda dari yang dipakai backend saat membuat tiket.
  factory PricingData.fromJson(Map<String, dynamic> j) => PricingData(
        ticketPricePerPerson: (j['ticketPricePerPerson'] as num).toInt(),
        capacity: (j['capacity'] as num).toInt(),
        parking: [
          for (final e in (j['parking'] as List? ?? const [])) ParkingTarif.fromJson(e as Map<String, dynamic>),
        ],
      );

  final int ticketPricePerPerson;
  final int capacity;
  final List<ParkingTarif> parking;

  // Tarif parkir untuk satu pilihan di form. Null bila server tidak mengirim kuncinya.
  int? tarif(Parking p) {
    for (final t in parking) {
      if (t.key == p.name) return t.price;
    }
    return null;
  }
}
