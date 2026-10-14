import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Checkout (Ringkasan Booking): menampilkan jam dan item dari layar Booking, lalu meminta
// nama, nomor WhatsApp, dan metode pembayaran. Nomor WhatsApp menjadi kunci riwayat booking.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.draft});

  // [P5 Kirim data antar halaman] Isi booking diterima dari BookingScreen lewat arguments.
  final BookingDraft draft;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  late final _whatsapp = TextEditingController(text: AppState.instance.savedWhatsapp);
  // true = Cash di Lokasi, false = QRIS.
  bool _cash = true;

  @override
  void dispose() {
    _name.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  // Konfirmasi & Bayar: cek validator, simpan booking, lalu ganti layar ini dengan e-voucher.
  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    final booking = AppState.instance.addBooking(draft: widget.draft, name: _name.text, whatsapp: _whatsapp.text, cash: _cash);
    AppState.instance.saveWhatsapp(_whatsapp.text);
    Navigator.pushReplacementNamed(context, AppRoutes.voucher, arguments: booking.code);
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return Scaffold(
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ResponsiveBody(children: [
            const PageHeader(title: 'Ringkasan Booking'),
            const SectionLabel('Waktu Kunjungan', top: 0),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.leaf.withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.white(.25)),
                ),
                child: Text(labelJam(draft.slot), style: AppTheme.mono(12)),
              ),
            ),
            const SectionLabel('Item Dipesan'),
            for (final l in draft.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(child: Text('${l.qty}x ${l.name}', style: const TextStyle(fontSize: 13))),
                  Text(rupiah(l.subtotal), style: AppTheme.mono(12)),
                ]),
              ),
            const SizedBox(height: 8),
            Divider(color: AppColors.white(.15)),
            const SectionLabel('Data Pemesan', top: 8),
            // [P6 TextFormField + validator] Nama wajib diisi, nomor WhatsApp harus format Indonesia.
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', hintText: 'Masukkan nama lengkap'),
              validator: (v) => Validators.required(v, 'Nama'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _whatsapp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No. WhatsApp', hintText: '08xxxxxxxxxx'),
              validator: Validators.whatsapp,
            ),
            const SizedBox(height: 4),
            Text('E-voucher dikirim ke nomor ini dan riwayatnya bisa dicari di Tiket Saya.',
                style: TextStyle(fontSize: 10, color: AppColors.white(.65))),
            const SectionLabel('Metode Pembayaran'),
            // [P4 ChoiceChip] Pilih satu metode pembayaran; pilihan aktif berwarna Hijau Daun.
            Wrap(spacing: 10, children: [
              for (final (cash, label) in [(true, 'Cash di Lokasi'), (false, 'QRIS')])
                ChoiceChip(
                  label: Text(label),
                  selected: _cash == cash,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _cash = cash),
                  selectedColor: AppColors.leaf.withValues(alpha: .7),
                  backgroundColor: AppColors.white(.1),
                  side: BorderSide(color: AppColors.white(.25)),
                  shape: const StadiumBorder(),
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
            ]),
          ]),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppColors.ink, border: Border(top: BorderSide(color: AppColors.white(.15)))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(children: [
              Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total', style: TextStyle(fontSize: 10, color: AppColors.white(.7))),
                  Text(rupiah(draft.total), style: AppTheme.mono(15, weight: FontWeight.w600)),
                ]),
              ),
              SizedBox(width: 200, child: PrimaryButton(label: 'Konfirmasi & Bayar', height: 44, onPressed: _confirm)),
            ]),
          ),
        ),
      ),
    );
  }
}
