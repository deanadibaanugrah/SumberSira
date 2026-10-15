import 'package:flutter/material.dart';

// Satu alat sewa atau wahana, dibaca dari mock JSON (assets/data/wahana.json).
class Wahana {
  const Wahana({required this.id, required this.name, required this.category, required this.price, this.unit = ''});

  // Membuat objek dari satu item JSON.
  factory Wahana.fromJson(Map<String, dynamic> json) => Wahana(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        price: json['price'] as int,
        unit: (json['unit'] as String?) ?? '',
      );

  final String id;
  final String name;
  final String category;
  final int price;
  final String unit;

  // Nama untuk layar booking, mis. "ATV (15 menit)" atau "Kereta Sawah (per kepala)".
  String get label {
    if (unit.isEmpty) return name;
    return unit.contains('menit') ? '$name ($unit)' : '$name (per $unit)';
  }

  // Ikon yang sesuai dengan nama item, mirip ikon di web admin (pelampung, gembok, kereta, dst.).
  IconData get icon => switch (id) {
        'ban-kecil' || 'ban-besar' => Icons.support,
        'loker' => Icons.lock_outline,
        'kereta-sawah' => Icons.train_outlined,
        'bebek-gayung' => Icons.sailing_outlined,
        'atv' => Icons.two_wheeler,
        'flying-fox' => Icons.paragliding,
        'komedi-putar' => Icons.attractions,
        _ => Icons.local_activity_outlined,
      };
}
