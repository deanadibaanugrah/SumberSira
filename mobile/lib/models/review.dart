// Satu ulasan pengunjung: nama, jumlah bintang (1 sampai 5), dan isi ulasan.
class Review {
  const Review({required this.name, required this.stars, required this.text});

  final String name;
  final int stars;
  final String text;

  // Inisial untuk avatar bulat, mis. "Bu Rani S." -> "B".
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}
