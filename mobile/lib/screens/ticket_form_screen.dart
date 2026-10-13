import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/app_state.dart';
import '../data/dummy_data.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';

// Form beli tiket masuk. StatefulWidget karena isinya berubah saat pengguna mengisi.
// Unsur materi: Form + TextFormField + validator (P6), TextEditingController, DropdownButton,
// RadioButton, Checkbox, dan setState (P4), lalu pindah ke halaman e-tiket membawa data (P5).
class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({super.key});

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  // [P6 Form] Kunci form untuk menjalankan semua validator sekaligus lewat validate().
  final _formKey = GlobalKey<FormState>();
  // [P4 TextEditingController] Membaca isi kolom nama dan WhatsApp (nomor terakhir diisi dari shared_preferences).
  final _name = TextEditingController();
  late final _whatsapp = TextEditingController(text: AppState.instance.savedWhatsapp);
  // State form. Setiap perubahan lewat setState() supaya tampilan dan total ikut berubah.
  int _adults = 2;
  int _kids = 0;
  Parking _parking = Parking.motor;
  String _arrival = DummyData.arrivalSlots.first;
  PaymentMethod _payment = PaymentMethod.qris;
  bool _agree = false;

  int get _total => _adults * Ticket.pricePerPerson + _parking.price;

  @override
  void dispose() {
    _name.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  // Tombol bayar: cek validator, cek persetujuan, lalu bayar (QRIS lewat dialog, tunai langsung jadi).
  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Centang persetujuan aturan kunjungan dulu.')));
      return;
    }
    if (_payment == PaymentMethod.qris) {
      final paid = await showDialog<bool>(context: context, builder: (_) => _QrisDialog(total: _total));
      if (paid != true || !mounted) return;
    }
    final ticket = AppState.instance.buyTicket(
      name: _name.text,
      whatsapp: _whatsapp.text,
      adults: _adults,
      kids: _kids,
      parking: _parking,
      payment: _payment,
      arrival: _arrival,
    );
    AppState.instance.saveWhatsapp(_whatsapp.text);
    // [P5 Named Route] Pindah ke e-tiket sambil mengirim kode tiket sebagai argumen.
    Navigator.pushReplacementNamed(context, AppRoutes.eticket, arguments: ticket.code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ResponsiveBody(children: [
            const PageHeader(title: 'Tiket Masuk Online'),
            ListenableBuilder(
              listenable: AppState.instance,
              builder: (_, _) => GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  const LiveDot(color: AppColors.leaf),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Sekarang ${AppState.instance.inside} orang di dalam · ${AppState.instance.crowdLabel} (${AppState.instance.percent}%)',
                        style: const TextStyle(fontSize: 11)),
                  ),
                ]),
              ),
            ),
            const SectionLabel('Jumlah Pengunjung'),
            // [P6 intl] Tanggal hari ini dalam Bahasa Indonesia.
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Berlaku untuk hari ini, ${tanggalHariIni()}', style: TextStyle(fontSize: 10, color: AppColors.white(.65))),
            ),
            _counterRow('Usia 3 tahun ke atas', '${rupiah(Ticket.pricePerPerson)} / orang', _adults, 1, 30, (v) => setState(() => _adults = v)),
            const SizedBox(height: 8),
            _counterRow('Anak di bawah 3 tahun', 'Gratis', _kids, 0, 10, (v) => setState(() => _kids = v)),
            const SectionLabel('Perkiraan Jam Datang'),
            // [P4 DropdownButton] Memilih satu jam dari daftar; onChanged mengubah state lewat setState().
            DropdownButtonFormField<String>(
              initialValue: _arrival,
              dropdownColor: AppColors.forest,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.schedule, size: 18)),
              items: [
                for (final slot in DummyData.arrivalSlots) DropdownMenuItem(value: slot, child: Text(slot, style: const TextStyle(fontSize: 13))),
              ],
              onChanged: (value) => setState(() => _arrival = value!),
            ),
            const SectionLabel('Parkir Kendaraan'),
            // Pilih satu jenis parkir (cara kerjanya seperti RadioButton, tampilannya kartu sesuai desain).
            Row(children: [
              for (final p in Parking.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GlassCard(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: p == _parking ? AppColors.leaf.withValues(alpha: .8) : null,
                      onTap: () => setState(() => _parking = p),
                      child: Column(children: [
                        Text(p.label, style: TextStyle(fontSize: 11, fontWeight: p == _parking ? FontWeight.w600 : FontWeight.w400)),
                        Text(p.price == 0 ? '-' : rupiah(p.price), style: AppTheme.mono(9, color: AppColors.white(.75))),
                      ]),
                    ),
                  ),
                ),
            ]),
            const SectionLabel('Data Pemesan'),
            // [P6 TextFormField + validator] Validator mengembalikan pesan error, atau null kalau isian benar.
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Nama sesuai identitas', prefixIcon: Icon(Icons.person_outline, size: 18)),
              validator: (v) => Validators.required(v, 'Nama'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _whatsapp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'No. WhatsApp, mis. 081234567890', prefixIcon: Icon(Icons.phone_outlined, size: 18)),
              validator: Validators.whatsapp,
            ),
            const SectionLabel('Metode Pembayaran'),
            // [P4 RadioButton] Pilih tepat satu metode pembayaran dari satu kelompok pilihan.
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: RadioGroup<PaymentMethod>(
                groupValue: _payment,
                onChanged: (value) => setState(() => _payment = value!),
                child: Column(children: [
                  for (final m in PaymentMethod.values)
                    RadioListTile<PaymentMethod>(value: m, dense: true, title: Text(m.label, style: const TextStyle(fontSize: 12))),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            // [P4 Checkbox] Persetujuan aturan kunjungan (true/false), wajib dicentang sebelum bayar.
            CheckboxListTile(
              value: _agree,
              onChanged: (value) => setState(() => _agree = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Saya sudah membaca aturan kunjungan (tidak memakai sabun dan sampo di kolam).', style: TextStyle(fontSize: 11)),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: _BottomPayBar(
        label: 'Total (${_adults + _kids} orang)',
        amount: _total,
        button: _payment == PaymentMethod.qris ? 'Bayar dengan QRIS' : 'Pesan, Bayar di Loket',
        onPressed: _pay,
      ),
    );
  }

  Widget _counterRow(String title, String subtitle, int value, int min, int max, ValueChanged<int> onChanged) => GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 3),
              Text(subtitle, style: AppTheme.mono(11, color: AppColors.white(.8))),
            ]),
          ),
          StepperControl(value: value, min: min, max: max, label: title, onChanged: onChanged),
        ]),
      );
}

// Bar bawah: total harga dan tombol aksi. Ditaruh di bottomNavigationBar supaya tidak ikut tergulir.
class _BottomPayBar extends StatelessWidget {
  const _BottomPayBar({required this.label, required this.amount, required this.button, required this.onPressed});

  final String label;
  final int amount;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.ink, border: Border(top: BorderSide(color: AppColors.white(.15)))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(children: [
            Expanded(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 10, color: AppColors.white(.7))),
                Text(rupiah(amount), style: AppTheme.mono(15, weight: FontWeight.w600)),
              ]),
            ),
            SizedBox(width: 190, child: PrimaryButton(label: button, height: 44, onPressed: onPressed)),
          ]),
        ),
      ),
    );
  }
}

// Dialog pembayaran QRIS (simulasi): QR berisi nominal, lalu tombol "Saya Sudah Bayar".
class _QrisDialog extends StatelessWidget {
  const _QrisDialog({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.forest,
      title: Text('Bayar dengan QRIS', style: AppTheme.display(18)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          // Package qr_flutter: membuat gambar QR dari teks.
          child: QrImageView(data: 'QRIS SUMBER SIRA $total', size: 170),
        ),
        const SizedBox(height: 12),
        Text(rupiah(total), style: AppTheme.mono(18, weight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Scan dengan aplikasi bank atau e-wallet.', style: TextStyle(fontSize: 11, color: AppColors.white(.7))),
      ]),
      actions: [
        // [P5 Navigator.pop] Menutup dialog sambil mengirim hasil (false = batal, true = sudah bayar).
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.white))),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.leaf),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Saya Sudah Bayar'),
        ),
      ],
    );
  }
}
