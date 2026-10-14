import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';

// Chatbot Tanya Sira (versi frontend): menjawab dari daftar FAQ berdasarkan kata kunci.
// [Rencana AI] Nanti fungsi _answer diganti panggilan ke model AI di backend, tampilan tetap sama.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  // Daftar pesan: fromBot true = balasan Tanya Sira, false = pertanyaan pengunjung.
  final _messages = <({bool fromBot, String text})>[
    (fromBot: true, text: 'Halo! Aku Tanya Sira 👋 Ada yang bisa dibantu soal Sumber Sira?'),
  ];
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Cari FAQ yang kata kuncinya muncul di pertanyaan. Kalau tidak ada, beri jawaban cadangan.
  String _answer(String question) {
    final q = question.toLowerCase();
    for (final f in DummyData.faq) {
      if (f.keys.any(q.contains)) return f.answer;
    }
    return 'Maaf, aku belum tahu jawabannya. Pertanyaanmu dicatat untuk admin ya 🙏';
  }

  // Kirim pertanyaan: tambah pesan pengunjung, lalu balasan bot, lalu gulir ke bawah.
  void _send([String? text]) {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    setState(() {
      _messages.add((fromBot: false, text: question));
      _messages.add((fromBot: true, text: _answer(question)));
    });
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(children: [
                _header(context),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      for (final (i, m) in _messages.indexed) ...[
                        _bubble(m.fromBot, m.text),
                        // Pertanyaan cepat tampil di bawah sapaan pertama.
                        if (i == 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 46, bottom: 12),
                            child: Wrap(spacing: 8, runSpacing: 8, children: [
                              for (final q in DummyData.quickQuestions)
                                ActionChip(
                                  label: Text(q, style: const TextStyle(fontSize: 11, color: Colors.white)),
                                  onPressed: () => _send(q),
                                  backgroundColor: AppColors.leaf.withValues(alpha: .35),
                                  side: BorderSide(color: AppColors.white(.25)),
                                  shape: const StadiumBorder(),
                                ),
                            ]),
                          ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Tulis pertanyaan...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: AppColors.white(.25))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: AppColors.white(.25))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      tooltip: 'Kirim',
                      style: IconButton.styleFrom(backgroundColor: AppColors.leaf, fixedSize: const Size(48, 48)),
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(children: [
          Material(
            color: AppColors.white(.12),
            shape: CircleBorder(side: BorderSide(color: AppColors.white(.22))),
            child: IconButton(
              tooltip: 'Kembali',
              iconSize: 16,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(radius: 20, backgroundColor: AppColors.leaf, child: Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tanya Sira', style: AppTheme.display(18)),
            Text('AI Assistant • Online', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
          ]),
        ]),
      );

  // Gelembung chat: bot di kiri (kaca + avatar), pengunjung di kanan (Hijau Daun).
  Widget _bubble(bool fromBot, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: fromBot ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fromBot) ...[
              CircleAvatar(radius: 14, backgroundColor: AppColors.leaf.withValues(alpha: .8), child: const Icon(Icons.smart_toy_outlined, size: 14, color: Colors.white)),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: fromBot ? AppColors.white(.12) : AppColors.leaf,
                  borderRadius: BorderRadius.circular(18),
                  border: fromBot ? Border.all(color: AppColors.white(.22)) : null,
                ),
                child: Text(text, style: const TextStyle(fontSize: 12.5, height: 1.35)),
              ),
            ),
          ],
        ),
      );
}
