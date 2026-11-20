import 'package:flutter/material.dart';

import '../../../models/wahana.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/format.dart';
import '../../../widgets/common.dart';
import '../../../widgets/glass.dart';
import '../viewmodel/booking_controller.dart';
import '../../../widgets/motion.dart';

// Daftar Sewa & Booking: pilihan jam di atas, lalu list per kategori (Sewa Alat, Wahana) dengan stepper.
class BookingSection extends StatelessWidget {
  const BookingSection({super.key, required this.controller});

  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => FutureBuilder<List<Wahana>>(
        future: controller.items,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Wahana>[];
          // Daftar dikelompokkan per kategori dari server supaya mudah dicari.
          final categories = {for (final w in items) w.category};
          final error = controller.error;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.slots.isNotEmpty) ...[
                const SectionLabel('Jam kunjungan', top: 20),
                // Jam booking selang 1 jam (id dari server), bisa digeser ke samping. Yang dipilih berwarna Hijau Tua.
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.slots.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final s = controller.slots[i];
                      final active = s == controller.slot;
                      return Pressable(
                        onTap: () => controller.setSlot(s),
                        semanticLabel: 'Jam ${labelJam(s)}',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active ? AppColors.forest : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            labelJam(s),
                            style: AppText.number(
                              15,
                              color: active ? Colors.white : AppColors.ink,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 18,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error, style: AppText.footnote)),
                      PressScale(
                        child: TextButton(
                          onPressed: controller.reload,
                          child: const Text('Coba lagi'),
                        ),
                      ),
                    ],
                  ),
                ),
              if (controller.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                for (final c in categories)
                  GroupedList(
                    header: c,
                    children: [
                      for (final w in items.where((w) => w.category == c))
                        _itemRow(w),
                    ],
                  ),
            ],
          );
        },
      ),
    );
  }

  // Satu baris alat sewa atau wahana: ikon tanpa wadah, nama, harga, dan stepper jumlah.
  Widget _itemRow(Wahana w) {
    final qty = controller.qty[w.id] ?? 0;
    return ListRow(
      icon: w.icon,
      title: w.label,
      subtitle: rupiah(w.price),
      subtitleStyle: AppText.number(
        13,
        weight: qty > 0 ? FontWeight.w700 : FontWeight.w500,
        color: qty > 0 ? AppColors.forest : AppColors.abu,
      ),
      trailing: StepperControl(
        value: qty,
        label: w.name,
        onChanged: (v) => controller.setQty(w.id, v),
      ),
    );
  }
}

// Bar kaca mengambang di atas tab bar: total dan jam yang dipilih, lalu tombol Lanjut Booking.
class BookingBar extends StatelessWidget {
  const BookingBar({super.key, required this.controller});

  final BookingController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => TotalBar(
      label: controller.slot == null
          ? 'Total'
          : 'Total · ${labelJam(controller.slot!)}',
      amount: controller.total,
      button: 'Lanjut Booking',
      buttonWidth: 172,
      onPressed: () => controller.next(context),
    ),
  );
}
