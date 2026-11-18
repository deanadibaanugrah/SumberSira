import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'dummy_data.dart';

// Satu pesan di kotak chat. fromBot true = balasan Tanya Sira, false = pertanyaan pengunjung.
class ChatMessage {
  const ChatMessage({required this.fromBot, required this.text, this.source = ''});

  final bool fromBot;
  final String text;
  // Keterangan kecil di bawah balasan bot: dari FAQ atau dicatat untuk admin.
  final String source;
}

// Pengatur chat Tanya Sira. Disimpan di sini (bukan di widget) supaya riwayat tidak hilang saat kotak chat ditutup.
// Semua jawaban berasal dari backend: POST /chat. Pertanyaan yang tidak cocok dicatat server untuk admin.
class ChatController extends ChangeNotifier {
  ChatController._();
  static final ChatController instance = ChatController._();

  final List<ChatMessage> messages = [
    const ChatMessage(fromBot: true, text: 'Halo! Aku Tanya Sira 👋 Ada yang bisa dibantu soal Sumber Sira?'),
  ];
  bool busy = false;
  // Pertanyaan cepat dari backend (GET /chat/quick-questions). Selama belum termuat atau server mati,
  // dipakai daftar bawaan agar tombol cepat tetap ada.
  List<String> quickQuestions = DummyData.quickQuestions;

  // Ambil pertanyaan cepat saat aplikasi dibuka. Gagal terhubung: daftar bawaan tetap dipakai.
  Future<void> init() async {
    try {
      final list = await ApiClient.fetchQuickQuestions();
      if (list.isNotEmpty) {
        quickQuestions = list;
        notifyListeners();
      }
    } on ApiException {
      // server tidak terjangkau: tombol cepat bawaan
    } catch (e) {
      // Balasan server yang bentuknya tidak terduga juga tidak boleh menghentikan aplikasi.
      debugPrint('ChatController.init gagal: $e');
    }
  }

  void _add(ChatMessage m) {
    messages.add(m);
    notifyListeners();
  }

  // Kirim pertanyaan ke POST /chat lalu tampilkan jawabannya.
  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || busy) return;
    _add(ChatMessage(fromBot: false, text: question));
    busy = true;
    notifyListeners();
    try {
      final jawaban = await ApiClient.askChat(question);
      _add(ChatMessage(
        fromBot: true,
        text: jawaban.answer,
        // matched = pertanyaan cocok dengan FAQ pengelola; bila tidak, server mencatatnya untuk admin.
        source: jawaban.matched ? 'FAQ pengelola' : 'Pertanyaan dicatat untuk admin',
      ));
    } on ApiException catch (e) {
      _add(ChatMessage(
        fromBot: true,
        text: e.offline ? 'Server belum terjangkau, jadi aku belum bisa menjawab. Coba lagi sebentar lagi ya.' : e.message,
      ));
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
