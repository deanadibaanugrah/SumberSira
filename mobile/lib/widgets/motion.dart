import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

// Sistem gerak bersama Sumber Sira. Hanya mengatur animasi tampilan, tidak menyentuh logika.
// Semua gerak mengikuti pengaturan "kurangi animasi" di perangkat (langsung berpindah tanpa animasi).
class AppMotion {
  // Pegas untuk efek tekan: cepat berbalik dengan sedikit memantul.
  static const press = SpringDescription(mass: 1, stiffness: 620, damping: 24);

  // Dua tepi kapsul penanda tab memakai pegas berbeda supaya kapsul memanjang saat meluncur:
  // tepi depan bergerak cepat, tepi belakang menyusul pelan lalu menyatu kembali.
  static const pillLead = SpringDescription(
    mass: 1,
    stiffness: 560,
    damping: 32,
  );
  static const pillTrail = SpringDescription(
    mass: 1,
    stiffness: 230,
    damping: 21,
  );

  // Getaran halus saat memilih tab atau menekan tombol penting. Tidak berpengaruh di web.
  static void tick() {
    if (kIsWeb) return;
    HapticFeedback.selectionClick();
  }
}

// Efek tekan berbasis pegas untuk elemen apa pun yang bisa ditekan (tombol, kartu, ikon).
// Memakai Listener, jadi tidak mengganggu cara elemen di dalamnya menangani sentuhan.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.scale = .95,
    this.haptic = false,
  });

  final Widget child;
  final double scale;
  final bool haptic;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );
  Offset? _start;
  bool _pressed = false;
  bool _pending = false;

  void _to(double target) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = target;
      return;
    }
    _c.animateWith(
      SpringSimulation(AppMotion.press, _c.value, target, _c.velocity),
    );
  }

  // Tunda sebentar sebelum mengecil, supaya gulir jari tidak membuat elemen berkedip.
  Future<void> _down(PointerDownEvent e) async {
    _start = e.position;
    _pending = true;
    await Future<void>.delayed(const Duration(milliseconds: 55));
    if (!mounted || !_pending) return;
    _pressed = true;
    if (widget.haptic) AppMotion.tick();
    _to(widget.scale);
  }

  void _release() {
    _pending = false;
    if (_pressed) {
      _pressed = false;
      _to(1);
    }
  }

  void _move(PointerMoveEvent e) {
    final s = _start;
    if (s != null && (e.position - s).distance > 12) _release();
  }

  @override
  void dispose() {
    _pending = false;
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (_, child) => Transform.scale(scale: _c.value, child: child),
      ),
    );
  }
}

// Kapsul penanda yang meluncur di belakang sekumpulan tab. Saat pindah, tepi depan melaju lebih dulu dan
// tepi belakang menyusul, sehingga kapsul memanjang lalu kembali ke ukuran semula (seperti tab bar iOS terbaru).
class LiquidPill extends StatefulWidget {
  const LiquidPill({
    super.key,
    required this.index,
    required this.count,
    required this.decoration,
    this.inset = 0,
  });

  final int index;
  final int count;
  final BoxDecoration decoration;
  final double inset;

  @override
  State<LiquidPill> createState() => _LiquidPillState();
}

class _LiquidPillState extends State<LiquidPill> with TickerProviderStateMixin {
  late final AnimationController _l = AnimationController.unbounded(
    vsync: this,
  );
  late final AnimationController _r = AnimationController.unbounded(
    vsync: this,
  );
  double _slot = 0;
  bool _ready = false;

  double _left(int i) => _slot * i + widget.inset;
  double _right(int i) => _slot * (i + 1) - widget.inset;

  @override
  void didUpdateWidget(LiquidPill old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index || !_ready) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _l.value = _left(widget.index);
      _r.value = _right(widget.index);
      return;
    }
    final toRight = widget.index > old.index;
    final leftSpring = toRight ? AppMotion.pillTrail : AppMotion.pillLead;
    final rightSpring = toRight ? AppMotion.pillLead : AppMotion.pillTrail;
    _l.animateWith(
      SpringSimulation(leftSpring, _l.value, _left(widget.index), _l.velocity),
    );
    _r.animateWith(
      SpringSimulation(
        rightSpring,
        _r.value,
        _right(widget.index),
        _r.velocity,
      ),
    );
  }

  @override
  void dispose() {
    _l.dispose();
    _r.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final slot = box.maxWidth / widget.count;
        if (!_ready || slot != _slot) {
          _slot = slot;
          _l.value = _left(widget.index);
          _r.value = _right(widget.index);
          _ready = true;
        }
        return AnimatedBuilder(
          animation: Listenable.merge([_l, _r]),
          builder: (_, _) {
            final left = _l.value;
            final width = (_r.value - _l.value)
                .clamp(slot * .6, slot * 1.9)
                .toDouble();
            return Stack(
              children: [
                Positioned(
                  left: left,
                  width: width,
                  top: widget.inset,
                  bottom: widget.inset,
                  child: DecoratedBox(decoration: widget.decoration),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
