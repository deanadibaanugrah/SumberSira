// Model data "live" dari backend: keramaian, grafik per jam, dan chat Tanya Sira.

// Live Crowd saat ini, dihitung backend dari tiket yang discan masuk dan belum keluar.
class CrowdInfo {
  const CrowdInfo({required this.inside, required this.percent, required this.label, required this.capacity});

  factory CrowdInfo.fromJson(Map<String, dynamic> j) => CrowdInfo(
        inside: j['inside'] as int,
        percent: j['percent'] as int,
        label: j['label'] as String,
        capacity: (j['capacity'] as int?) ?? 300,
      );

  final int inside;
  final int percent;
  final String label;
  final int capacity;
}

// Grafik per jam hari ini (08 sampai 16): [today] kenyataan dari tiket yang discan, [usual] kebiasaan hari-hari sebelumnya.
class HourlyCrowd {
  const HourlyCrowd({required this.hours, required this.today, required this.usual, required this.quietest});

  factory HourlyCrowd.fromJson(Map<String, dynamic> j) => HourlyCrowd(
        hours: [for (final h in j['hours'] as List) h as int],
        today: [for (final v in j['today'] as List) v as int],
        usual: j['usual'] == null ? null : [for (final v in j['usual'] as List) (v as num?)?.toInt()],
        quietest: j['quietest'] as int?,
      );

  final List<int> hours;
  final List<int> today;
  final List<int?>? usual;
  // Jam yang biasanya paling sepi menurut riwayat, null bila belum ada riwayat.
  final int? quietest;
}

// Asal jawaban chat cepat.
enum ChatSource {
  faq('FAQ pengelola'),
  ai('AI, dari data Sumber Sira'),
  kb('Data Sumber Sira'),
  manager('Pengelola'),
  unknown('');

  const ChatSource(this.label);
  final String label;

  static ChatSource parse(String? s) => values.firstWhere((v) => v.name == s, orElse: () => ChatSource.unknown);
}

// Hasil POST /chat/ask. answer null = belum ada jawaban, dan pengunjung bisa memilih bertanya ke pengelola.
class ChatAnswer {
  const ChatAnswer({required this.source, required this.answer, required this.canAskManager});

  factory ChatAnswer.fromJson(Map<String, dynamic> j) => ChatAnswer(
        source: ChatSource.parse(j['source'] as String?),
        answer: j['answer'] as String?,
        canAskManager: (j['canAskManager'] as bool?) ?? j['answer'] == null,
      );

  final ChatSource source;
  final String? answer;
  final bool canAskManager;
}

// Pertanyaan yang dikirim ke pengelola, beserta balasannya bila sudah dijawab.
class ManagerQuestion {
  const ManagerQuestion({required this.id, required this.question, required this.answered, this.answer});

  factory ManagerQuestion.fromJson(Map<String, dynamic> j) => ManagerQuestion(
        id: j['id'] as String,
        question: j['question'] as String,
        answered: j['status'] == 'answered',
        answer: j['answer'] as String?,
      );

  final String id;
  final String question;
  final bool answered;
  final String? answer;
}
