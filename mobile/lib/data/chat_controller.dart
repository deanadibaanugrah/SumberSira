import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/live.dart';
import 'api_client.dart';
import 'dummy_data.dart';

// Satu pesan di kotak chat. fromBot true = balasan Tanya Sira, false = pertanyaan pengunjung.
class ChatMessage {
  const ChatMessage({required this.fromBot, required this.text, this.source = '', this.offerManagerFor});

  final bool fromBot;
  final String text;
  // Asal jawaban, mis. "FAQ pengelola" atau "AI, dari data Sumber Sira". Kosong untuk pesan biasa.
  final String source;
  // Bila terisi, di bawah pesan ada tombol "Tanya pengelola" untuk meneruskan pertanyaan ini.
  final String? offerManagerFor;
}

// Dua cara bertanya: jawab cepat (FAQ pengelola, lalu AI dari data Sumber Sira) atau tanya pengelola (lambat, dibalas manusia).
enum ChatMode { fast, manager }

// Jawaban cadangan dari kata kunci, dipakai hanya saat server tidak terjangkau.
String? jawabanTanyaSira(String question) {
  final q = question.toLowerCase();
  for (final f in DummyData.faq) {
    if (f.keys.any(q.contains)) return f.answer;
  }
  return null;
}

// Pengatur chat Tanya Sira. Disimpan di sini (bukan di widget) supaya riwayat tidak hilang saat kotak chat ditutup,
// dan balasan pengelola tetap bisa diterima walau kotak chat sedang tertutup.
class ChatController extends ChangeNotifier {
  ChatController._();
  static final ChatController instance = ChatController._();

  static const _deviceKey = 'chat_device_id';
  static const _awaitingKey = 'chat_menunggu_balasan';

  final List<ChatMessage> messages = [
    const ChatMessage(fromBot: true, text: 'Halo! Aku Tanya Sira 👋 Ada yang bisa dibantu soal Sumber Sira?'),
  ];
  ChatMode mode = ChatMode.fast;
  bool busy = false;
  // Jumlah balasan pengelola yang masuk saat kotak chat tertutup (untuk titik penanda di gelembung).
  int unread = 0;
  // True selama kotak chat terbuka.
  bool panelOpen = false;

  String _deviceId = '';
  final Set<String> _awaiting = {};
  Timer? _poll;

  // ID acak per perangkat. Dipakai server untuk mengirim balasan pengelola ke perangkat yang bertanya, tanpa login.
  String get deviceId => _deviceId;

  // Membaca ID perangkat dan daftar pertanyaan yang masih menunggu balasan. Dipanggil sekali di main().
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceKey);
    if (id == null || id.isEmpty) {
      final rnd = Random.secure();
      id = 'app-${List.generate(20, (_) => rnd.nextInt(16).toRadixString(16)).join()}';
      await prefs.setString(_deviceKey, id);
    }
    _deviceId = id;
    _awaiting.addAll(prefs.getStringList(_awaitingKey) ?? const <String>[]);
    if (_awaiting.isNotEmpty) _startPolling();
  }

  Future<void> _saveAwaiting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_awaitingKey, _awaiting.toList());
  }

  void setMode(ChatMode value) {
    mode = value;
    notifyListeners();
  }

  void setPanelOpen(bool open) {
    panelOpen = open;
    if (open) {
      unread = 0;
      checkReplies();
    }
    notifyListeners();
  }

  void _add(ChatMessage m) {
    messages.add(m);
    notifyListeners();
  }

  // Kirim pertanyaan sesuai mode yang dipilih.
  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || busy) return;
    _add(ChatMessage(fromBot: false, text: question));
    mode == ChatMode.fast ? await _ask(question) : await askManager(question, echo: false);
  }

  // Jawab cepat: FAQ pengelola, lalu AI dari data Sumber Sira. Tanpa jawaban, ditawarkan bertanya ke pengelola.
  Future<void> _ask(String question) async {
    busy = true;
    notifyListeners();
    try {
      final r = await ApiClient.askChat(question, _deviceId);
      if (r.answer != null) {
        _add(ChatMessage(fromBot: true, text: r.answer!, source: r.source.label));
      } else {
        _add(ChatMessage(
          fromBot: true,
          text: 'Aku belum menemukan jawabannya di data Sumber Sira. Mau kutanyakan ke pengelola? Balasannya lebih lama karena menunggu pengelola menjawab.',
          offerManagerFor: question,
        ));
      }
    } on ApiException catch (e) {
      if (e.offline) {
        final local = jawabanTanyaSira(question);
        _add(ChatMessage(
          fromBot: true,
          text: local ?? 'Server belum terjangkau, jadi aku belum bisa menjawab. Coba lagi sebentar lagi ya.',
          source: local == null ? '' : 'Data di perangkat (tanpa koneksi)',
        ));
      } else {
        _add(ChatMessage(fromBot: true, text: e.message));
      }
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // Kirim pertanyaan ke pengelola. Jawabannya ditulis manusia, jadi baru muncul di sini setelah pengelola membalas.
  // echo true dipakai saat dari tombol "Tanya pengelola" (pertanyaannya belum tampil sebagai gelembung pengunjung).
  Future<void> askManager(String question, {bool echo = true}) async {
    if (busy) return;
    if (echo) _add(ChatMessage(fromBot: false, text: question));
    busy = true;
    notifyListeners();
    try {
      final q = await ApiClient.askManager(question, _deviceId);
      _awaiting.add(q.id);
      await _saveAwaiting();
      _startPolling();
      _add(const ChatMessage(
        fromBot: true,
        text: 'Pertanyaanmu sudah dikirim ke pengelola. Balasannya akan muncul di sini begitu pengelola menjawab, biasanya butuh waktu lebih lama dari jawaban cepat.',
        source: 'Pengelola',
      ));
    } on ApiException catch (e) {
      _add(ChatMessage(fromBot: true, text: e.offline ? 'Pertanyaan belum terkirim karena server tidak terjangkau. Coba lagi sebentar lagi.' : e.message));
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _startPolling() {
    _poll ??= Timer.periodic(const Duration(seconds: 10), (_) => checkReplies());
  }

  // Memeriksa apakah pengelola sudah membalas pertanyaan yang menunggu. Setiap balasan hanya ditampilkan sekali.
  Future<void> checkReplies() async {
    if (_awaiting.isEmpty || _deviceId.isEmpty) return;
    try {
      final list = await ApiClient.fetchManagerQuestions(_deviceId);
      for (final q in list) {
        if (!q.answered || !_awaiting.remove(q.id)) continue;
        _add(ChatMessage(fromBot: true, text: 'Jawaban pengelola untuk "${q.question}":\n${q.answer ?? ''}', source: ChatSource.manager.label));
        if (!panelOpen) unread++;
      }
      await _saveAwaiting();
      if (_awaiting.isEmpty) {
        _poll?.cancel();
        _poll = null;
      }
      notifyListeners();
    } on ApiException {
      // server tidak terjangkau: coba lagi pada pemeriksaan berikutnya
    }
  }
}
