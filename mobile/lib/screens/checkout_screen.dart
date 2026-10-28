import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Checkout (Ringkasan Booking): menampilkan jam dan item dari bagian Sewa & Wahana, lalu meminta
// nama dan nomor WhatsApp. Pembayaran hanya QRIS. Nomor WhatsApp menjadi kunci riwayat booking.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.draft});

  // [P5 Kirim data antar halaman] Isi booking diterima dari BookingSection lewat arguments.
  final BookingDraft draft;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  late final _whatsapp = TextEditingController(text: AppState.instance.savedWhatsapp);

  @override
  void dispose() {
    _name.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  // Bayar dengan QRIS: cek validator, lalu buka halaman scan QRIS sambil membawa pesanan.
  // Booking baru disimpan setelah pembayaran QRIS selesai.
  void _pay() {
    if (!_formKey.currentState!.validate()) return;
    AppState.instance.saveWhatsapp(_whatsapp.text);
    final request = BookingRequest(draft: widget.draft, name: _name.text, whatsapp: _whatsapp.text);
    Navigator.pushNamed(context, AppRoutes.payment, arguments: request);
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const PageAppBar(title: 'Ringkasan Booking'),
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ResponsiveBody(children: [
            // Ringkasan pesanan: jam kunjungan lalu item yang dipesan.
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpace.card),
                  child: Row(children: [
                    const Icon(CupertinoIcons.clock, size: 22, color: AppColors.leaf),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Waktu kunjungan', style: AppText.footnote),
                        const SizedBox(height: 2),
                        Text(labelJam(draft.slot), style: AppText.number(20, weight: FontWeight.w700, color: AppColors.forest)),
                      ]),
                    ),
                  ]),
                ),
                const Divider(indent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Text('Item dipesan', style: AppText.footnote),
                    const SizedBox(height: 4),
                    for (final l in draft.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.leaf12, borderRadius: BorderRadius.circular(8)),
                            child: Text('${l.qty}x', style: AppText.number(13, weight: FontWeight.w700, color: AppColors.forest)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(l.name, style: AppText.body)),
                          Text(rupiah(l.subtotal), style: AppText.number(15)),
                        ]),
                      ),
                  ]),
                ),
              ]),
            ),
            const SectionLabel('Data pemesan'),
            // [P6 TextFormField + validator] Nama wajib diisi, nomor WhatsApp harus format Indonesia.
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', hintText: 'Masukkan nama lengkap', prefixIcon: Icon(CupertinoIcons.person, size: 20)),
              validator: (v) => Validators.required(v, 'Nama'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _whatsapp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No. WhatsApp', hintText: '08xxxxxxxxxx', prefixIcon: Icon(CupertinoIcons.phone, size: 20)),
              validator: Validators.whatsapp,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(CupertinoIcons.info_circle, size: 15, color: AppColors.abu),
                SizedBox(width: 6),
                Expanded(child: Text('Invoice dikirim ke nomor ini dan riwayatnya bisa dicari di Tiket & Booking.', style: AppText.footnote)),
              ]),
            ),
            // Pembayaran sewa dan wahana hanya lewat QRIS.
            const GroupedList(header: 'Metode pembayaran', children: [
              ListRow(
                icon: CupertinoIcons.qrcode,
                title: 'QRIS',
                subtitle: 'Scan pakai aplikasi bank atau e-wallet',
                trailing: Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.leaf, size: 24),
              ),
            ]),
          ]),
        ),
      ),
      bottomNavigationBar: TotalBar(label: 'Total', amount: draft.total, button: 'Bayar dengan QRIS', onPressed: _pay),
    );
  }
}
