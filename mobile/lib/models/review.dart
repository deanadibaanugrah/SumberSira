// Satu ulasan pengunjung: nama, jumlah bintang (1 sampai 5), dan isi ulasan.
// Data berasal dari backend (GET /reviews); id dipakai untuk menghapus dari web admin.
class Review {
  const Review({this.id = '', required this.name, required this.stars, required this.text, this.createdAt});

  final String id;
  final String name;
  final int stars;
  final String text;
  // Waktu kirim dari server (UTC). Ditampilkan dalam WIB lewat helper waktu.
  final DateTime? createdAt;

  // Inisial untuk avatar bulat, mis. "Bu Rani S." -> "B".
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();

  // Bentuk dari backend: { id, name, stars, text, createdAt }.
  factory Review.fromApi(Map<String, dynamic> json) => Review(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        stars: (json['stars'] as num?)?.toInt() ?? 0,
        text: json['text'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );
}

// Ringkasan ulasan dari GET /reviews: daftar terbaru, rata-rata bintang, dan jumlah ulasan.
// Semua angka dihitung server, bukan dari data contoh di perangkat.
class ReviewSummary {
  const ReviewSummary({required this.items, required this.rating, required this.count});

  final List<Review> items;
  final double rating;
  final int count;

  factory ReviewSummary.fromApi(Map<String, dynamic> json) => ReviewSummary(
        items: [for (final e in (json['items'] as List<dynamic>? ?? const [])) Review.fromApi(e as Map<String, dynamic>)],
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}
