import 'package:flutter/cupertino.dart';
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

  // Ikon garis yang sesuai dengan nama item (gaya SF Symbols bila ada padanannya).
  IconData get icon => switch (id) {
        'ban-kecil' || 'ban-besar' => CupertinoIcons.smallcircle_circle,
        'loker' => CupertinoIcons.lock,
        'kereta-sawah' => CupertinoIcons.tram_fill,
        'bebek-gayung' => Icons.rowing_outlined,
        'atv' => Icons.two_wheeler_outlined,
        'flying-fox' => Icons.paragliding_outlined,
        'komedi-putar' => Icons.attractions_outlined,
        _ => CupertinoIcons.ticket,
      };
}
