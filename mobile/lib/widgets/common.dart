import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

// [P3 StatelessWidget] Kartu putih dengan sudut membulat dan bayangan lembut, dipakai hampir di semua layar.
// onTap opsional; color untuk kartu berwarna (mis. mint atau hijau tua).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.onTap,
    this.color,
    this.borderColor,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: shape, boxShadow: shadow ? AppShadows.card : null),
      child: Material(
        color: color ?? Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: shape, side: BorderSide(color: borderColor ?? AppColors.line)),
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

// Ikon di dalam kotak membulat berwarna lembut: motif yang sama di menu, daftar info, dan daftar sewa.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.size = 44, this.color = AppColors.forest, this.background = AppColors.mint, this.circle = false});

  final IconData icon;
  final double size;
  final Color color;
  final Color background;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * .32),
      ),
      child: Icon(icon, size: size * .48, color: color),
    );
  }
}

// AppBar halaman turunan: tombol kembali bulat + judul serif. Tetap di atas saat isi digulir.
class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
          child: IconButton(
            tooltip: 'Kembali',
            iconSize: 20,
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forest),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AppTheme.display(19), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

// [P4 ElevatedButton] Tombol utama berbentuk pill Hijau Tua; onPressed dijalankan saat ditekan.
// loading = tampil putaran saat proses. inverted = tombol putih untuk dipasang di atas kartu hijau tua.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.loading = false, this.height = 52, this.inverted = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final double height;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final bg = inverted ? Colors.white : AppColors.forest;
    final fg = inverted ? AppColors.forest : Colors.white;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: .45),
          disabledForegroundColor: fg.withValues(alpha: .8),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: fg))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 8)],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ]),
      ),
    );
  }
}

// Tombol kedua (garis tepi), mis. Kirim ke WhatsApp atau Petunjuk Arah.
class OutlineAction extends StatelessWidget {
  const OutlineAction({super.key, required this.label, required this.icon, required this.onPressed, this.height = 50});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(height),
        foregroundColor: AppColors.forest,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.pale, width: 1.4),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Text(label),
    );
  }
}

// Tombol - angka + untuk jumlah pengunjung atau item sewa.
class StepperControl extends StatelessWidget {
  const StepperControl({super.key, required this.value, required this.onChanged, this.min = 0, this.max = 99, this.label = ''});

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(19)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _button(Icons.remove_rounded, value > min ? () => onChanged(value - 1) : null, 'Kurangi $label'),
        SizedBox(
          width: 30,
          child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.forest)),
        ),
        _button(Icons.add_rounded, value < max ? () => onChanged(value + 1) : null, 'Tambah $label', filled: true),
      ]),
    );
  }

  Widget _button(IconData icon, VoidCallback? onTap, String tooltip, {bool filled = false}) {
    final enabled = onTap != null;
    final bg = filled ? AppColors.forest : Colors.white;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: enabled ? bg : bg.withValues(alpha: .35), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: filled ? Colors.white : AppColors.forest.withValues(alpha: enabled ? 1 : .35)),
        ),
      ),
    );
  }
}

// Judul kecil di atas sebuah bagian form. step = nomor langkah (opsional) supaya urutan isian jelas.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.top = 22, this.step});

  final String text;
  final double top;
  final int? step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 10),
      child: Row(children: [
        if (step != null) ...[
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.forest,
            child: Text('$step', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink))),
      ]),
    );
  }
}

// Judul bagian besar di halaman (serif), dengan keterangan kecil di bawahnya.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.top = 28});

  final String title;
  final String? subtitle;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTheme.display(20)),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: const TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.35)),
        ],
      ]),
    );
  }
}

// Satu baris info dengan ikon: judul tebal dan keterangan (Jam buka, Tiket masuk, Parkir, dst.).
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        IconBadge(icon, size: 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.3)),
          ]),
        ),
      ]),
    );
  }
}

// Baris label dan nilai di rincian e-tiket dan invoice.
class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.muted))),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: strong ? AppTheme.price(15) : const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

// Bar bawah yang tidak ikut tergulir (dipasang di bottomNavigationBar): latar putih dan bayangan ke atas.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppShadows.bar,
      ),
      child: SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 14), child: child)),
    );
  }
}

// Isi bar bawah form pemesanan: total harga di kiri, tombol aksi di kanan.
class TotalBar extends StatelessWidget {
  const TotalBar({super.key, required this.label, required this.amount, required this.button, required this.onPressed, this.buttonWidth = 200});

  final String label;
  final int amount;
  final String button;
  final VoidCallback onPressed;
  final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      child: Row(children: [
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 2),
            Text(rupiah(amount), style: AppTheme.price(20)),
          ]),
        ),
        SizedBox(width: buttonWidth, child: PrimaryButton(label: button, height: 50, onPressed: onPressed)),
      ]),
    );
  }
}

// Garis putus-putus dengan lekukan setengah lingkaran di kiri-kanan, seperti sobekan tiket.
class TicketDivider extends StatelessWidget {
  const TicketDivider({super.key, this.notch = AppColors.surface});

  final Color notch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: LayoutBuilder(builder: (_, box) {
            final count = (box.maxWidth / 10).floor();
            return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (var i = 0; i < count; i++) Container(width: 5, height: 1.6, color: AppColors.pale),
            ]);
          }),
        ),
        Positioned(left: -12, child: CircleAvatar(radius: 12, backgroundColor: notch)),
        Positioned(right: -12, child: CircleAvatar(radius: 12, backgroundColor: notch)),
      ]),
    );
  }
}
