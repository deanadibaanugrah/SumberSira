// Model data "live" dari backend: keramaian dan chat Tanya Sira.

// Live Crowd saat ini, dihitung backend dari tiket yang discan masuk dan belum keluar.
// forecast = prakiraan jumlah pengunjung per jam hari ini menurut kebiasaan (dari backend).
class CrowdInfo {
  const CrowdInfo({
    required this.inside,
    required this.percent,
    required this.label,
    required this.capacity,
    this.updatedAt,
    this.forecast = const [],
  });

  factory CrowdInfo.fromJson(Map<String, dynamic> j) => CrowdInfo(
        inside: j['inside'] as int,
        percent: j['percent'] as int,
        label: j['label'] as String,
        capacity: (j['capacity'] as int?) ?? 300,
        updatedAt: j['updatedAt'] as String?,
        forecast: [
          for (final f in (j['forecast'] as List? ?? const []))
            (hour: (f as Map<String, dynamic>)['hour'] as String, count: (f['count'] as num?)?.toInt() ?? 0),
        ],
      );

  final int inside;
  final int percent;
  final String label;
  final int capacity;
  // Waktu terakhir angka ini diperbarui server (ISO UTC).
  final String? updatedAt;
  // Prakiraan pengunjung per jam, mis. (hour: "08", count: 30).
  final List<({String hour, int count})> forecast;
}

// Jawaban POST /chat. matched false = belum ada FAQ yang cocok; server mencatat pertanyaannya untuk admin.
class ChatAnswer {
  const ChatAnswer({required this.answer, required this.matched});

  factory ChatAnswer.fromJson(Map<String, dynamic> j) => ChatAnswer(
        answer: j['answer'] as String? ?? '',
        matched: j['matched'] as bool? ?? false,
      );

  final String answer;
  final bool matched;
}

