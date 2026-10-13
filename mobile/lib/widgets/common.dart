import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// [P3 StatelessWidget] Kartu kaca (glassmorphism) yang dipakai hampir di semua layar. onTap opsional.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 20, this.onTap, this.color});

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.white(.12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: AppColors.white(.22))),
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

// Header halaman: tombol kembali bulat + judul serif.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 18),
      child: Row(
        children: [
          Material(
            color: AppColors.white(.12),
            shape: CircleBorder(side: BorderSide(color: AppColors.white(.22))),
            child: IconButton(
              tooltip: 'Kembali',
              iconSize: 16,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack ?? () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTheme.display(18), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

// [P4 ElevatedButton] Tombol utama berbentuk pill Hijau Daun; onPressed dijalankan saat ditekan.
// loading = tampil putaran saat proses.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.loading = false, this.height = 50});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.leaf,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.leaf.withValues(alpha: .5),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ]),
      ),
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
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: AppColors.leaf.withValues(alpha: .9), borderRadius: BorderRadius.circular(15)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _button(Icons.remove, value > min ? () => onChanged(value - 1) : null, 'Kurangi $label'),
        SizedBox(width: 24, child: Text('$value', textAlign: TextAlign.center, style: AppTheme.mono(12, weight: FontWeight.w600))),
        _button(Icons.add, value < max ? () => onChanged(value + 1) : null, 'Tambah $label'),
      ]),
    );
  }

  Widget _button(IconData icon, VoidCallback? onTap, String tooltip) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 16,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: AppColors.white(enabled ? .15 : .06), shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: AppColors.white(enabled ? 1 : .4)),
        ),
      ),
    );
  }
}

// Judul kecil di atas sebuah bagian form.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.top = 20});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
