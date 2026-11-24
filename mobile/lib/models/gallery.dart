// Satu foto galeri dari backend. GET /gallery hanya mengembalikan foto yang sudah disetujui admin;
// hasil POST /gallery membawa status "pending" sampai ditinjau.
class GalleryPhoto {
  const GalleryPhoto({
    required this.id,
    required this.url,
    required this.title,
    required this.owner,
    this.ai = false,
    this.status = 'approved',
    this.createdAt,
  });

  final String id;
  final String url;
  final String title;
  final String owner;
  // True bila foto berasal dari AI Photo Studio.
  final bool ai;
  // pending | approved | rejected.
  final String status;
  final DateTime? createdAt;

  factory GalleryPhoto.fromApi(Map<String, dynamic> json) => GalleryPhoto(
    id: json['id'] as String? ?? '',
    url: json['url'] as String? ?? '',
    title: json['title'] as String? ?? '',
    owner: json['owner'] as String? ?? '',
    ai: json['ai'] as bool? ?? false,
    status: json['status'] as String? ?? 'approved',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );
}

// Hasil POST /ai-photo: foto asli dan hasil perbaikan yang disimpan di server.
class AiPhotoResult {
  const AiPhotoResult({
    required this.id,
    required this.status,
    required this.originalUrl,
    required this.resultUrl,
    this.error,
    this.strength = 60,
    this.engine = '',
  });

  final String id;
  final String status;
  final String originalUrl;
  final String resultUrl;
  final String? error;
  // Kekuatan perbaikan 0 sampai 100 dan mesinnya: "ai" = dinilai AI dulu, "otomatis" = statistik foto saja.
  final int strength;
  final String engine;

  // Job selesai bila status "done"; selain itu hasil belum bisa dibagikan.
  bool get done => status == 'done';

  factory AiPhotoResult.fromApi(Map<String, dynamic> json) => AiPhotoResult(
    id: json['id'] as String? ?? '',
    status: json['status'] as String? ?? '',
    originalUrl: json['originalUrl'] as String? ?? '',
    resultUrl: json['resultUrl'] as String? ?? '',
    error: json['error'] as String?,
    strength: (json['strength'] as num?)?.toInt() ?? 60,
    engine: json['engine'] as String? ?? '',
  );
}
