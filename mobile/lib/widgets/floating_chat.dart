import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'glass.dart';

// Satu pesan chat: fromBot true = balasan Tanya Sira, false = pertanyaan pengunjung.
typedef ChatMessage = ({bool fromBot, String text});

// Jawaban Tanya Sira (versi frontend): cari FAQ yang kata kuncinya muncul di pertanyaan.
// [Rencana AI] Nanti fungsi ini diganti panggilan ke model AI di backend, tampilan tetap sama.
String jawabanTanyaSira(String question) {
  final q = question.toLowerCase();
  for (final f in DummyData.faq) {
    if (f.keys.any(q.contains)) return f.answer;
  }
  return 'Maaf, aku belum tahu jawabannya. Pertanyaanmu dicatat untuk admin ya 🙏';
}

// Chatbot Tanya Sira yang mengambang di Beranda.
// Tertutup: gelembung kaca Hijau Tua berisi ikon chat yang bisa digeser ke mana saja.
// Diketuk: membesar menjadi panel chat kaca (bukan layar penuh, bukan halaman baru).
class FloatingChat extends StatefulWidget {
  const FloatingChat({super.key});

  @override
  State<FloatingChat> createState() => _FloatingChatState();
}

class _FloatingChatState extends State<FloatingChat> {
  static const _size = 58.0;
  static const _margin = 12.0;

  // Posisi kiri-atas gelembung. null = belum digeser, pakai posisi awal di kanan bawah.
  Offset? _pos;
  bool _open = false;
  bool _dragging = false;
  // Riwayat chat disimpan di sini supaya tidak hilang saat kotak chat ditutup.
  final _messages = <ChatMessage>[
    (fromBot: true, text: 'Halo! Aku Tanya Sira 👋 Ada yang bisa dibantu soal Sumber Sira?'),
  ];

  void _send(String question) => setState(() {
        _messages.add((fromBot: false, text: question));
        _messages.add((fromBot: true, text: jawabanTanyaSira(question)));
      });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      // Batas geser gelembung supaya tidak keluar layar.
      final maxX = max(_margin, box.maxWidth - _size - _margin);
      final maxY = max(_margin, box.maxHeight - _size - _margin);
      final start = _pos ?? Offset(maxX, maxY - 8);
      final pos = Offset(start.dx.clamp(_margin, maxX), start.dy.clamp(_margin, maxY));

      // Ukuran kotak chat, dan posisinya tumbuh dari sisi tempat gelembung berada.
      final panelW = min(340.0, box.maxWidth - _margin * 2);
      final panelH = min(460.0, box.maxHeight - _margin * 2);
      final onRight = pos.dx + _size / 2 > box.maxWidth / 2;
      final onBottom = pos.dy + _size / 2 > box.maxHeight / 2;
      final panelX = (onRight ? pos.dx + _size - panelW : pos.dx).clamp(_margin, max(_margin, box.maxWidth - panelW - _margin));
      final panelY = (onBottom ? pos.dy + _size - panelH : pos.dy).clamp(_margin, max(_margin, box.maxHeight - panelH - _margin));

      return Stack(children: [
        // Satu kotak yang berubah dari lingkaran kecil menjadi kotak chat (animasi posisi dan ukuran).
        AnimatedPositioned(
          duration: _dragging ? Duration.zero : const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          left: _open ? panelX.toDouble() : pos.dx,
          top: _open ? panelY.toDouble() : pos.dy,
          width: _open ? panelW : _size,
          height: _open ? panelH : _size,
          child: _open
              // OverflowBox: isi panel langsung disusun ukuran penuh, jadi tidak berantakan selama animasi membesar.
              ? Glass(
                  radius: 28,
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: panelW,
                    maxWidth: panelW,
                    minHeight: panelH,
                    maxHeight: panelH,
                    child: _ChatPanel(messages: _messages, onSend: _send, onClose: () => setState(() => _open = false)),
                  ),
                )
              : Glass(tone: GlassTone.tint, radius: _size / 2, child: _bubble(pos)),
        ),
      ]);
    });
  }

  // Gelembung kepala robot: diketuk = buka chat, digeser = pindah posisi.
  Widget _bubble(Offset pos) => Semantics(
        button: true,
        label: 'Buka chatbot Tanya Sira',
        child: GestureDetector(
          // down = gerakan dihitung sejak jari menyentuh, jadi gelembung ikut jari tanpa tertinggal.
          dragStartBehavior: DragStartBehavior.down,
          onTap: () => setState(() => _open = true),
          onPanStart: (_) => setState(() => _dragging = true),
          onPanUpdate: (d) => setState(() => _pos = (_pos ?? pos) + d.delta),
          onPanEnd: (_) => setState(() => _dragging = false),
          child: const Center(child: Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.white, size: 26)),
        ),
      );
}

// Isi kotak chat: header, daftar pesan, pertanyaan cepat, dan kolom tulis pertanyaan.
class _ChatPanel extends StatefulWidget {
  const _ChatPanel({required this.messages, required this.onSend, required this.onClose});

  final List<ChatMessage> messages;
  final ValueChanged<String> onSend;
  final VoidCallback onClose;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom(jump: true);
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Gulir ke pesan paling bawah setelah tampilan selesai digambar.
  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      jump ? _scroll.jumpTo(end) : _scroll.animateTo(end, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  // Kirim pertanyaan dari kolom tulis atau dari tombol pertanyaan cepat.
  void _send([String? text]) {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    widget.onSend(question);
    _input.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(children: [
        // Header panel chat dengan tombol tutup.
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
          child: Row(children: [
            const Icon(CupertinoIcons.chat_bubble_2_fill, color: AppColors.leaf, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tanya Sira', style: AppText.headline),
                Row(children: [
                  const StatusDot(AppColors.leaf, size: 7),
                  const SizedBox(width: 5),
                  Text('AI Assistant · Online', style: AppText.caption),
                ]),
              ]),
            ),
            IconButton(tooltip: 'Tutup chat', onPressed: widget.onClose, icon: const Icon(CupertinoIcons.xmark, color: AppColors.ink, size: 19)),
          ]),
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            children: [
              for (final (i, m) in widget.messages.indexed) ...[
                _bubble(m),
                // Pertanyaan cepat tampil di bawah sapaan pertama.
                if (i == 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final q in DummyData.quickQuestions)
                        ActionChip(
                          label: Text(q, style: AppText.footnote.copyWith(fontWeight: FontWeight.w600, color: AppColors.forest)),
                          onPressed: () => _send(q),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppColors.leaf12,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                    ]),
                  ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _input,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: AppText.subheadline.copyWith(color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Tulis pertanyaan...',
                  hintStyle: AppText.subheadline,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.leaf, width: 1.5)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Kirim',
              style: IconButton.styleFrom(backgroundColor: AppColors.forest, fixedSize: const Size(44, 44)),
              onPressed: _send,
              icon: const Icon(CupertinoIcons.paperplane_fill, color: Colors.white, size: 18),
            ),
          ]),
        ),
      ]),
    );
  }

  // Gelembung pesan: bot di kiri (putih), pengunjung di kanan (Hijau Tua).
  Widget _bubble(ChatMessage m) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: m.fromBot ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: m.fromBot ? Colors.white : AppColors.forest,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(m.fromBot ? 6 : 20),
                    topRight: Radius.circular(m.fromBot ? 20 : 6),
                    bottomLeft: const Radius.circular(20),
                    bottomRight: const Radius.circular(20),
                  ),
                ),
                child: Text(m.text, style: AppText.subheadline.copyWith(color: m.fromBot ? AppColors.ink : Colors.white, height: 1.4)),
              ),
            ),
          ],
        ),
      );
}
