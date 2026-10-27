import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

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
// Tertutup: lingkaran berisi kepala robot yang bisa digeser ke mana saja.
// Diketuk: membesar menjadi kotak chat (bukan layar penuh, bukan halaman baru).
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _open ? Colors.white : AppColors.forest,
              borderRadius: BorderRadius.circular(_open ? 24 : _size / 2),
              border: Border.all(color: _open ? AppColors.line : AppColors.white(.9), width: _open ? 1 : 3),
              boxShadow: const [BoxShadow(color: Color(0x401B4332), blurRadius: 22, offset: Offset(0, 8))],
            ),
            child: _open
                // OverflowBox: isi kotak chat langsung disusun ukuran penuh, jadi tidak berantakan selama animasi membesar.
                ? OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: panelW,
                    maxWidth: panelW,
                    minHeight: panelH,
                    maxHeight: panelH,
                    child: _ChatPanel(messages: _messages, onSend: _send, onClose: () => setState(() => _open = false)),
                  )
                : _bubble(pos),
          ),
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
          child: const Center(child: Icon(Icons.smart_toy, color: Colors.white, size: 28)),
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
        // Header kotak chat (hijau tua) dengan tombol tutup.
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          color: AppColors.forest,
          child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: AppColors.white(.15), child: const Icon(Icons.smart_toy, color: Colors.white, size: 19)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tanya Sira', style: AppTheme.display(17, color: Colors.white)),
                Row(children: [
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.lightLeaf, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('AI Assistant • Online', style: TextStyle(fontSize: 11, color: AppColors.white(.8))),
                ]),
              ]),
            ),
            IconButton(tooltip: 'Tutup chat', onPressed: widget.onClose, icon: const Icon(Icons.close_rounded, color: Colors.white, size: 21)),
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
                    padding: const EdgeInsets.only(left: 32, bottom: 12),
                    child: Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final q in DummyData.quickQuestions)
                        ActionChip(
                          label: Text(q, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forest)),
                          onPressed: () => _send(q),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.pale, width: 1.3),
                          shape: const StadiumBorder(),
                        ),
                    ]),
                  ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _input,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Tulis pertanyaan...',
                  isDense: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.leaf, width: 1.4)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Kirim',
              style: IconButton.styleFrom(backgroundColor: AppColors.forest, fixedSize: const Size(44, 44)),
              onPressed: _send,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ]),
        ),
      ]),
    );
  }

  // Gelembung pesan: bot di kiri (mint + avatar), pengunjung di kanan (Hijau Tua).
  Widget _bubble(ChatMessage m) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: m.fromBot ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.fromBot) ...[
              const CircleAvatar(radius: 12, backgroundColor: AppColors.pale, child: Icon(Icons.smart_toy, size: 13, color: AppColors.forest)),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: m.fromBot ? AppColors.mint : AppColors.forest,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(m.fromBot ? 4 : 18),
                    topRight: Radius.circular(m.fromBot ? 18 : 4),
                    bottomLeft: const Radius.circular(18),
                    bottomRight: const Radius.circular(18),
                  ),
                ),
                child: Text(m.text, style: TextStyle(fontSize: 13, height: 1.4, color: m.fromBot ? AppColors.ink : Colors.white)),
              ),
            ),
          ],
        ),
      );
}
