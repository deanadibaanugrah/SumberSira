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

  // Ikon tiap pilihan parkir dan metode pembayaran.
  static const _parkingIcons = {
    Parking.none: Icons.directions_walk_rounded,
    Parking.motor: Icons.two_wheeler_rounded,
    Parking.mobil: Icons.directions_car_rounded,
    Parking.bus: Icons.directions_bus_rounded,
  };
  static const _paymentIcons = {PaymentMethod.qris: Icons.qr_code_2_rounded, PaymentMethod.cash: Icons.payments_outlined};

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
      appBar: const PageAppBar(title: 'Tiket Masuk Online'),
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ResponsiveBody(children: [
            ListenableBuilder(
              listenable: AppState.instance,
              builder: (_, _) => AppCard(
                color: AppColors.mint,
                borderColor: AppColors.pale,
                shadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  const LiveDot(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Sekarang ${AppState.instance.inside} orang di dalam · ${AppState.instance.crowdLabel} (${AppState.instance.percent}%)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.forest)),
                  ),
                ]),
              ),
            ),
            const SectionLabel('Jumlah Pengunjung', step: 1),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // [P6 intl] Tanggal hari ini dalam Bahasa Indonesia.
                Row(children: [
                  const Icon(Icons.event_outlined, size: 17, color: AppColors.leaf),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Berlaku untuk hari ini, ${tanggalHariIni()}', style: const TextStyle(fontSize: 12.5, color: AppColors.muted))),
                ]),
                const SizedBox(height: 6),
                _counterRow('Usia 3 tahun ke atas', '${rupiah(Ticket.pricePerPerson)} / orang', _adults, 1, 30, (v) => setState(() => _adults = v)),
                const Divider(),
                _counterRow('Anak di bawah 3 tahun', 'Gratis', _kids, 0, 10, (v) => setState(() => _kids = v)),
              ]),
            ),
            const SectionLabel('Perkiraan Jam Datang', step: 2),
            // [P4 DropdownButton] Memilih satu jam dari daftar; onChanged mengubah state lewat setState().
            DropdownButtonFormField<String>(
              initialValue: _arrival,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.schedule_rounded, size: 20)),
              items: [
                for (final slot in DummyData.arrivalSlots) DropdownMenuItem(value: slot, child: Text(slot, style: const TextStyle(fontSize: 14))),
              ],
              onChanged: (value) => setState(() => _arrival = value!),
            ),
            const SectionLabel('Parkir Kendaraan', step: 3),
            // Pilih satu jenis parkir (cara kerjanya seperti RadioButton, tampilannya kartu sesuai desain).
            Row(children: [
              for (final (i, p) in Parking.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _parkingTile(p)),
              ],
            ]),
            const SectionLabel('Data Pemesan', step: 4),
            // [P6 TextFormField + validator] Validator mengembalikan pesan error, atau null kalau isian benar.
            TextFormField(  
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Nama sesuai identitas', prefixIcon: Icon(Icons.person_outline_rounded, size: 20)),
              validator: (v) => Validators.required(v, 'Nama'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _whatsapp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'No. WhatsApp, mis. 081234567890', prefixIcon: Icon(Icons.phone_outlined, size: 20)),
              validator: Validators.whatsapp,
            ),
            const SectionLabel('Metode Pembayaran', step: 5),
            // [P4 RadioButton] Pilih tepat satu metode pembayaran dari satu kelompok pilihan.
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: RadioGroup<PaymentMethod>(
                groupValue: _payment,
                onChanged: (value) => setState(() => _payment = value!),
                child: Column(children: [
                  for (final (i, m) in PaymentMethod.values.indexed) ...[
                    if (i > 0) const Divider(indent: 16, endIndent: 16),
                    RadioListTile<PaymentMethod>(
                      value: m,
                      controlAffinity: ListTileControlAffinity.trailing,
                      secondary: IconBadge(_paymentIcons[m]!, size: 38),
                      title: Text(m.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
              ),
            ),
            const SizedBox(height: 12),
            // [P4 Checkbox] Persetujuan aturan kunjungan (true/false), wajib dicentang sebelum bayar.
            AppCard(
              color: _agree ? AppColors.mint : Colors.white,
              borderColor: _agree ? AppColors.pale : AppColors.line,
              shadow: false,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: CheckboxListTile(
                value: _agree,
                onChanged: (value) => setState(() => _agree = value ?? false),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Saya sudah membaca aturan kunjungan (tidak memakai sabun dan sampo di kolam).', style: TextStyle(fontSize: 13, height: 1.35)),
              ),
            ),
          ]),
        ),
      ),
      // Bar bawah: total harga dan tombol aksi. Ditaruh di bottomNavigationBar supaya tidak ikut tergulir.
      bottomNavigationBar: TotalBar(
        label: 'Total (${_adults + _kids} orang)',
        amount: _total,
        button: _payment == PaymentMethod.qris ? 'Bayar dengan QRIS' : 'Pesan, Bayar di Loket',
        onPressed: _pay,
      ),
    );
  }

  Widget _counterRow(String title, String subtitle, int value, int min, int max, ValueChanged<int> onChanged) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(subtitle, style: AppTheme.price(13)),
            ]),
          ),
          StepperControl(value: value, min: min, max: max, label: title, onChanged: onChanged),
        ]),
      );

  // Kartu pilihan parkir: ikon kendaraan, nama, dan tarif. Yang dipilih berwarna hijau tua.
  Widget _parkingTile(Parking p) {
    final active = p == _parking;
    final fg = active ? Colors.white : AppColors.ink;
    return AppCard(
      radius: 16,
      shadow: !active,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: active ? AppColors.forest : Colors.white,
      borderColor: active ? AppColors.forest : AppColors.line,
      onTap: () => setState(() => _parking = p),
      child: Column(children: [
        Icon(_parkingIcons[p], size: 24, color: active ? Colors.white : AppColors.leaf),
        const SizedBox(height: 6),
        Text(p.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: fg)),
        const SizedBox(height: 2),
        Text(p.price == 0 ? '-' : rupiah(p.price), style: TextStyle(fontSize: 11, color: active ? AppColors.white(.8) : AppColors.muted)),
      ]),
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
      title: Text('Bayar dengan QRIS', textAlign: TextAlign.center, style: AppTheme.display(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.pale, width: 1.5)),
          // Package qr_flutter: membuat gambar QR dari teks.
          child: QrImageView(data: 'QRIS SUMBER SIRA $total', size: 170),
        ),
        const SizedBox(height: 14),
        Text(rupiah(total), style: AppTheme.price(24)),
        const SizedBox(height: 4),
        const Text('Scan dengan aplikasi bank atau e-wallet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.muted)),
      ]),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        // [P5 Navigator.pop] Menutup dialog sambil mengirim hasil (false = batal, true = sudah bayar).
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.muted),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.forest, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Saya Sudah Bayar', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
