import 'package:flutter/foundation.dart';

import '../../../data/api_client.dart';

// Satu pesan di kotak chat. fromBot true = balasan Tanya Sira, false = pertanyaan pengunjung.
class ChatMessage {
  const ChatMessage({
    required this.fromBot,
    required this.text,
    this.source = '',
  });

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
    const ChatMessage(
      fromBot: true,
      text:
          'Halo! 👋 Selamat datang di Tanya Sira.\n'
          'Ada yang ingin kamu ketahui seputar Sumber Sira? Yuk, tanyakan apa saja. Aku siap membantu memberikan informasi yang kamu butuhkan!',
    ),
  ];
  bool busy = false;
  // Status koneksi terakhir ke backend. Header chat memakai ini supaya tidak menulis "Online" saat server mati.
  bool online = true;
  // Pertanyaan cepat dari backend (GET /chat/quick-questions). Kosong sampai server menjawab;
  // tidak ada daftar bawaan supaya tombol cepat selalu sama dengan yang diatur pengelola.
  List<String> quickQuestions = const [];

  // Ambil pertanyaan cepat saat aplikasi dibuka. Gagal terhubung: daftar tetap kosong.
  Future<void> init() async {
    try {
      final list = await ApiClient.fetchQuickQuestions();
      final berubah =
          !online ||
          (list.isNotEmpty && !listEquals(list, quickQuestions));
      online = true;
      if (list.isNotEmpty) {
        quickQuestions = list;
      }
      if (berubah) notifyListeners();
    } on ApiException catch (e) {
      // Server tidak terjangkau: tidak ada tombol cepat dan status chat menjadi Offline.
      final status = !e.offline;
      if (online != status) {
        online = status;
        notifyListeners();
      }
    } catch (e) {
      // Balasan server yang bentuknya tidak terduga juga tidak boleh menghentikan aplikasi.
      if (online) {
        online = false;
        notifyListeners();
      }
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
    // Riwayat singkat dikirim sebelum pertanyaan baru dimasukkan (maksimal 6 pesan terakhir).
    final riwayat = [
      for (final m
          in messages.length > 6
              ? messages.sublist(messages.length - 6)
              : messages)
        (fromBot: m.fromBot, text: m.text),
    ];
    _add(ChatMessage(fromBot: false, text: question));
    busy = true;
    notifyListeners();
    try {
      final jawaban = await ApiClient.askChat(question, history: riwayat);
      online = true;
      _add(
        ChatMessage(
          fromBot: true,
          text: jawaban.answer,
          // matched = ada jawabannya (dari FAQ pengelola atau dari AI yang hanya memakai data resmi);
          // bila tidak, server mencatat pertanyaannya untuk admin.
          source: jawaban.matched
              ? (jawaban.source == 'ai'
                    ? 'Dijawab AI dari data resmi'
                    : 'FAQ pengelola')
              : 'Pertanyaan dicatat untuk admin',
        ),
      );
    } on ApiException catch (e) {
      online = !e.offline;
      _add(
        ChatMessage(
          fromBot: true,
          text: e.offline
              ? 'Server belum terjangkau. Periksa koneksi internet kamu, lalu coba lagi.'
              : e.message,
        ),
      );
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
