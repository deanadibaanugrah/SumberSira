import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../viewmodel/chat_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/glass.dart';

// Chatbot Tanya Sira yang mengambang di Beranda.
// Tertutup: gelembung kaca Hijau Tua berisi ikon chat yang bisa digeser ke mana saja.
// Diketuk: membesar menjadi panel chat kaca (bukan layar penuh, bukan halaman baru).
// Jawaban berasal dari backend (POST /chat); pertanyaan yang belum cocok dicatat untuk admin.
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
  // Riwayat chat ada di ChatController supaya tidak hilang saat kotak chat ditutup.
  final _chat = ChatController.instance;

  void _setOpen(bool open) {
    setState(() => _open = open);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // Batas geser gelembung supaya tidak keluar layar.
        final maxX = max(_margin, box.maxWidth - _size - _margin);
        final maxY = max(_margin, box.maxHeight - _size - _margin);
        final start = _pos ?? Offset(maxX, maxY - 8);
        final pos = Offset(
          start.dx.clamp(_margin, maxX),
          start.dy.clamp(_margin, maxY),
        );

        // Ukuran kotak chat, dan posisinya tumbuh dari sisi tempat gelembung berada.
        final panelW = min(340.0, box.maxWidth - _margin * 2);
        final panelH = min(500.0, box.maxHeight - _margin * 2);
        final onRight = pos.dx + _size / 2 > box.maxWidth / 2;
        final onBottom = pos.dy + _size / 2 > box.maxHeight / 2;
        final panelX = (onRight ? pos.dx + _size - panelW : pos.dx).clamp(
          _margin,
          max(_margin, box.maxWidth - panelW - _margin),
        );
        final panelY = (onBottom ? pos.dy + _size - panelH : pos.dy).clamp(
          _margin,
          max(_margin, box.maxHeight - panelH - _margin),
        );

        return Stack(
          children: [
            // Satu kotak yang berubah dari lingkaran kecil menjadi kotak chat (animasi posisi dan ukuran).
            AnimatedPositioned(
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
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
                        child: _ChatPanel(
                          chat: _chat,
                          onClose: () => _setOpen(false),
                        ),
                      ),
                    )
                  : Glass(
                      tone: GlassTone.tint,
                      radius: _size / 2,
                      child: _bubble(pos),
                    ),
            ),
          ],
        );
      },
    );
  }

  // Gelembung chat: diketuk = buka chat, digeser = pindah posisi.
  Widget _bubble(Offset pos) => Semantics(
    button: true,
    label: 'Buka chatbot Tanya Sira',
    child: GestureDetector(
      // down = gerakan dihitung sejak jari menyentuh, jadi gelembung ikut jari tanpa tertinggal.
      dragStartBehavior: DragStartBehavior.down,
      onTap: () => _setOpen(true),
      onPanStart: (_) => setState(() => _dragging = true),
      onPanUpdate: (d) => setState(() => _pos = (_pos ?? pos) + d.delta),
      onPanEnd: (_) => setState(() => _dragging = false),
      child: const Icon(
        CupertinoIcons.chat_bubble_2_fill,
        color: Colors.white,
        size: 26,
      ),
    ),
  );
}

// Isi kotak chat: header, pilihan cara bertanya, daftar pesan, pertanyaan cepat, dan kolom tulis pertanyaan.
class _ChatPanel extends StatefulWidget {
  const _ChatPanel({required this.chat, required this.onClose});

  final ChatController chat;
  final VoidCallback onClose;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _shown = 0;

  ChatController get chat => widget.chat;

  @override
  void initState() {
    super.initState();
    _shown = chat.messages.length;
    chat.addListener(_onChat);
    _scrollToBottom(jump: true);
  }

  @override
  void dispose() {
    chat.removeListener(_onChat);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Pesan baru masuk (jawaban bot atau balasan pengelola): gulir ke bawah.
  void _onChat() {
    if (chat.messages.length != _shown || chat.busy) {
      _shown = chat.messages.length;
      _scrollToBottom();
    }
  }

  // Gulir ke pesan paling bawah setelah tampilan selesai digambar.
  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      jump
          ? _scroll.jumpTo(end)
          : _scroll.animateTo(
              end,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
    });
  }

  // Kirim pertanyaan dari kolom tulis atau dari tombol pertanyaan cepat.
  void _send([String? text]) {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty || chat.busy) return;
    chat.send(question);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListenableBuilder(
        listenable: chat,
        builder: (context, _) => Column(
          children: [
            // Header panel chat dengan tombol tutup.
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    color: AppColors.leaf,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanya Sira', style: AppText.headline),
                        Row(
                          children: [
                            StatusDot(
                              chat.online ? AppColors.leaf : AppColors.coral,
                              size: 7,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              chat.online
                                  ? 'AI Assistant · Online'
                                  : 'AI Assistant · Offline',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup chat',
                    onPressed: widget.onClose,
                    icon: const Icon(
                      CupertinoIcons.xmark,
                      color: AppColors.ink,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                children: [
                  for (final (i, m) in chat.messages.indexed) ...[
                    _bubble(m),
                    // Pertanyaan cepat dari backend tampil di bawah sapaan pertama.
                    if (i == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final q in chat.quickQuestions)
                              ActionChip(
                                label: Text(
                                  q,
                                  style: AppText.footnote.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.forest,
                                  ),
                                ),
                                onPressed: chat.busy ? null : () => _send(q),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppColors.leaf12,
                                side: BorderSide.none,
                                shape: const StadiumBorder(),
                              ),
                          ],
                        ),
                      ),
                  ],
                  if (chat.busy) _typing(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.leaf,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Kirim',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      fixedSize: const Size(44, 44),
                    ),
                    onPressed: chat.busy ? null : _send,
                    icon: const Icon(
                      CupertinoIcons.paperplane_fill,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gelembung "sedang mengetik" selama menunggu server.
  Widget _typing() => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const Text(
            'Tanya Sira sedang mencari jawaban...',
            style: AppText.footnote,
          ),
        ),
      ],
    ),
  );

  // Gelembung pesan: bot di kiri (putih), pengunjung di kanan (Hijau Tua). Pesan bot memuat asal jawabannya.
  Widget _bubble(ChatMessage m) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: m.fromBot
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  m.text,
                  style: AppText.subheadline.copyWith(
                    color: m.fromBot ? AppColors.ink : Colors.white,
                    height: 1.4,
                  ),
                ),
                if (m.fromBot && m.source.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    m.source,
                    style: AppText.caption.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
