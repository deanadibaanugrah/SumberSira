import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'glass.dart';

// [P3 StatelessWidget] Kartu konten: permukaan putih solid, sudut 20, tanpa bayangan.
// onTap opsional (sedikit mengecil saat ditekan); color dan borderColor untuk kartu yang dipilih.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpace.card), this.radius = AppSpace.radius, this.onTap, this.color, this.borderColor});

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: shape,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 1.5),
      ),
      child: Padding(padding: padding, child: child),
    );
    return onTap == null ? card : Pressable(onTap: onTap, child: card);
  }
}

// Ikon di dalam kotak Hijau Daun 12%. Hanya untuk satu grup per layar (mis. menu cepat Beranda);
// di tempat lain ikon tampil tanpa wadah.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.size = 48});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.leaf12, borderRadius: BorderRadius.circular(size * .3)),
      child: Icon(icon, size: size * .5, color: AppColors.leaf),
    );
  }
}

// Navigation bar halaman turunan: kaca terang di atas isi yang digulir, tombol kembali dan judul di tengah.
// Dipakai dengan Scaffold(extendBodyBehindAppBar: true) supaya isi terlihat samar di belakang kaca.
class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar({super.key, required this.title, this.showBack = true});

  final String title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final solid = MediaQuery.highContrastOf(context);
    final bar = DecoratedBox(
      decoration: BoxDecoration(color: solid ? Colors.white : AppColors.glass, border: const Border(bottom: BorderSide(color: AppColors.line))),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Stack(alignment: Alignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.headline),
            ),
            if (showBack)
              Positioned(
                left: 6,
                child: IconButton(
                  tooltip: 'Kembali',
                  constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                  icon: const Icon(CupertinoIcons.chevron_back, size: 24, color: AppColors.leaf),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
          ]),
        ),
      ),
    );
    return ClipRect(child: solid ? bar : BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: bar));
  }
}

// [P4 ElevatedButton] Tombol primer berbentuk kapsul Hijau Tua; onPressed dijalankan saat ditekan.
// glass = versi kaca (Hijau Tua 85%) untuk CTA yang mengambang. inverted = tombol putih di atas latar gelap.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.loading = false, this.height = 50, this.inverted = false, this.glass = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final double height;
  final bool inverted;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final bg = inverted ? Colors.white : (glass ? AppColors.glassTint : AppColors.forest);
    final fg = inverted ? AppColors.forest : Colors.white;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: AppColors.line,
          disabledForegroundColor: AppColors.abu,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: const StadiumBorder(),
          textStyle: AppText.headline,
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.forest))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
      ),
    );
  }
}

// Tombol kedua: latar Hijau Daun 12% dan teks Hijau Tua (mis. Kirim ke WhatsApp, Petunjuk Arah).
class TintedButton extends StatelessWidget {
  const TintedButton({super.key, required this.label, required this.icon, required this.onPressed, this.height = 50});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        minimumSize: Size.fromHeight(height),
        foregroundColor: AppColors.forest,
        backgroundColor: AppColors.leaf12,
        shape: const StadiumBorder(),
        textStyle: AppText.headline,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

// Stepper gaya iOS: tombol - angka + di dalam kapsul. Area sentuh tiap tombol 44 x 44.
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
      height: 44,
      decoration: BoxDecoration(color: AppColors.leaf12, borderRadius: BorderRadius.circular(22)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _button(CupertinoIcons.minus, value > min ? () => onChanged(value - 1) : null, 'Kurangi $label'),
        SizedBox(width: 26, child: Text('$value', textAlign: TextAlign.center, style: AppText.number(17, color: AppColors.forest))),
        _button(CupertinoIcons.plus, value < max ? () => onChanged(value + 1) : null, 'Tambah $label'),
      ]),
    );
  }

  Widget _button(IconData icon, VoidCallback? onTap, String tooltip) => Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          child: SizedBox.square(dimension: 44, child: Icon(icon, size: 19, color: onTap == null ? AppColors.leaf30 : AppColors.forest)),
        ),
      );
}

// Judul kecil di atas grup form atau list (gaya iOS: huruf kapital kecil berwarna Abu).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.top = 24});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, top, 16, 8),
      child: Text(text.toUpperCase(), style: AppText.caption.copyWith(letterSpacing: .6)),
    );
  }
}

// Judul bagian (Title 2). Keterangan maksimal satu baris. trailing = aksi kecil di kanan (opsional).
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.top = AppSpace.section, this.trailing});

  final String title;
  final String? subtitle;
  final double top;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.title2),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.footnote),
            ],
          ]),
        ),
        ?trailing,
      ]),
    );
  }
}

// List bergaya inset grouped: baris-baris di dalam satu kartu putih, dipisah garis tipis.
// header = judul kecil di atas grup, footer = catatan di bawah grup.
class GroupedList extends StatelessWidget {
  const GroupedList({super.key, required this.children, this.header, this.footer, this.indent = 52, this.top = 24});

  final List<Widget> children;
  final String? header;
  final String? footer;
  final double indent;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (header != null) SectionLabel(header!, top: top),
      ClipRRect(
        borderRadius: BorderRadius.circular(AppSpace.radius),
        child: ColoredBox(
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final (i, row) in children.indexed) ...[
              if (i > 0) Divider(indent: indent),
              row,
            ],
          ]),
        ),
      ),
      if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text(footer!, style: AppText.footnote)),
    ]);
  }
}

// Satu baris di GroupedList: ikon tanpa wadah, judul, keterangan, dan isi kanan (chevron, nilai, switch).
class ListRow extends StatelessWidget {
  const ListRow({super.key, this.icon, required this.title, this.subtitle, this.trailing, this.onTap, this.iconColor = AppColors.leaf, this.titleStyle, this.subtitleStyle});

  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 11, 14, 11),
        child: Row(children: [
          if (icon != null) ...[Icon(icon, size: 20, color: iconColor), const SizedBox(width: 16)],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: titleStyle ?? AppText.body),
              if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: subtitleStyle ?? AppText.footnote)],
            ]),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          if (trailing == null && onTap != null) const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppColors.abu),
        ]),
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

// Baris label dan nilai di rincian e-tiket dan invoice. strong = total (angka hero).
class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: strong ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [
        SizedBox(width: 118, child: Text(label, style: AppText.subheadline)),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: strong ? AppText.hero(24) : AppText.subheadline.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// Titik warna status. Putih (status Sedang) diberi garis tepi Ink 10% supaya terlihat di latar terang.
class StatusDot extends StatelessWidget {
  const StatusDot(this.color, {super.key, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: color == Colors.white ? Border.all(color: AppColors.line) : null),
      );
}

// Chip status kecil: titik warna + label. tinted = latar Hijau Daun 12%; onDark = kaca di header gelap.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.dot, this.tinted = false, this.onDark = false, this.muted = false});

  final String label;
  final Color dot;
  final bool tinted;
  final bool onDark;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final Color bg = onDark ? AppColors.kaca : (tinted ? AppColors.leaf12 : Colors.white);
    final Color fg = onDark ? Colors.white : (tinted ? AppColors.forest : (muted ? AppColors.abu : AppColors.ink));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: tinted ? null : Border.all(color: onDark ? AppColors.kaca : AppColors.line),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        StatusDot(dot, size: 7),
        const SizedBox(width: 6),
        Text(label, style: AppText.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// Isi bar bawah form pemesanan (kaca mengambang): total di kiri, tombol aksi kaca Hijau Tua di kanan.
class TotalBar extends StatelessWidget {
  const TotalBar({super.key, required this.label, required this.amount, required this.button, required this.onPressed, this.buttonWidth = 190});

  final String label;
  final int amount;
  final String button;
  final VoidCallback onPressed;
  final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    return FloatingBar(
      child: Row(children: [
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.footnote),
            const SizedBox(height: 2),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(rupiah(amount), style: AppText.hero(24))),
          ]),
        ),
        const SizedBox(width: 12),
        SizedBox(width: buttonWidth, child: PrimaryButton(label: button, glass: true, onPressed: onPressed)),
      ]),
    );
  }
}

// Garis putus-putus dengan lekukan setengah lingkaran di kiri-kanan, seperti sobekan tiket.
class TicketDivider extends StatelessWidget {
  const TicketDivider({super.key, this.notch = AppColors.abuMuda});

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
              for (var i = 0; i < count; i++) Container(width: 5, height: 1.5, color: AppColors.line),
            ]);
          }),
        ),
        Positioned(left: -12, child: CircleAvatar(radius: 12, backgroundColor: notch)),
        Positioned(right: -12, child: CircleAvatar(radius: 12, backgroundColor: notch)),
      ]),
    );
  }
}
