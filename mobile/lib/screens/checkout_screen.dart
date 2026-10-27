import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Checkout (Ringkasan Booking): menampilkan jam dan item dari bagian Sewa & Booking, lalu meminta
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
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    const IconBadge(Icons.schedule_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Waktu Kunjungan', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                        const SizedBox(height: 2),
                        Text(labelJam(draft.slot), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.forest)),
                      ]),
                    ),
                  ]),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Text('Item Dipesan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    for (final l in draft.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(8)),
                            child: Text('${l.qty}x', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.forest)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(l.name, style: const TextStyle(fontSize: 14))),
                          Text(rupiah(l.subtotal), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                  ]),
                ),
              ]),
            ),
            const SectionLabel('Data Pemesan'),
            // [P6 TextFormField + validator] Nama wajib diisi, nomor WhatsApp harus format Indonesia.
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', hintText: 'Masukkan nama lengkap', prefixIcon: Icon(Icons.person_outline_rounded, size: 20)),
              validator: (v) => Validators.required(v, 'Nama'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _whatsapp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No. WhatsApp', hintText: '08xxxxxxxxxx', prefixIcon: Icon(Icons.phone_outlined, size: 20)),
              validator: Validators.whatsapp,
            ),
            const SizedBox(height: 8),
            const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.muted),
              SizedBox(width: 6),
              Expanded(
                child: Text('Invoice dikirim ke nomor ini dan riwayatnya bisa dicari di Tiket Saya.', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
              ),
            ]),
            const SectionLabel('Metode Pembayaran'),
            // Pembayaran sewa dan wahana hanya lewat QRIS.
            const AppCard(
              color: AppColors.mint,
              borderColor: AppColors.leaf,
              shadow: false,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(children: [
                IconBadge(Icons.qr_code_2_rounded, background: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('QRIS', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.forest)),
                    SizedBox(height: 2),
                    Text('Scan pakai aplikasi bank atau e-wallet', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  ]),
                ),
                Icon(Icons.check_circle_rounded, color: AppColors.leaf, size: 24),
              ]),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: TotalBar(label: 'Total', amount: draft.total, button: 'Bayar dengan QRIS', onPressed: _pay),
    );
  }
}
