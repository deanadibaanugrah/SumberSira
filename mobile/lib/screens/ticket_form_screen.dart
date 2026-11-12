import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/app_state.dart';
import '../data/api_client.dart';
import '../data/dummy_data.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/crowd_widgets.dart';
import '../widgets/glass.dart';

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
  List<String> _slots = DummyData.arrivalSlots; // diganti dari backend begitu terhubung
  String _arrival = DummyData.arrivalSlots.first;  PaymentMethod _payment = PaymentMethod.qris;
  bool _agree = false;

  int get _total => _adults * Ticket.pricePerPerson + _parking.price;

  // Ikon tiap pilihan parkir dan metode pembayaran.
  static const _parkingIcons = {
    Parking.none: Icons.directions_walk_rounded,
    Parking.motor: Icons.two_wheeler_outlined,
    Parking.mobil: Icons.directions_car_outlined,
    Parking.bus: Icons.directions_bus_outlined,
  };
  static const _paymentIcons = {PaymentMethod.qris: CupertinoIcons.qrcode, PaymentMethod.cash: Icons.payments_outlined};

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  // Jam datang diambil dari backend (GET /time-slots). Kalau gagal, daftar bawaan tetap dipakai.
  Future<void> _loadSlots() async {
    try {
      final slots = await ApiClient.fetchTimeSlots();
      if (!mounted || slots.isEmpty) return;
      setState(() {
        _slots = slots;
        if (!slots.contains(_arrival)) _arrival = slots.first;
      });
    } catch (_) {
      // server tidak terjangkau: tetap pakai daftar bawaan
    }
  }
  void dispose() {
    _name.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  // Tombol bayar: cek validator, cek persetujuan, lalu bayar (QRIS lewat sheet, tunai langsung jadi).
  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Centang persetujuan aturan kunjungan dulu.')));
      return;
    }
    if (_payment == PaymentMethod.qris) {
      final paid = await showGlassSheet<bool>(context, builder: (_) => _QrisSheet(total: _total));
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
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const PageAppBar(title: 'Beli Tiket Masuk'),
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ResponsiveBody(children: [
            // Keramaian saat ini (live) sebagai pertimbangan sebelum datang.
            ListenableBuilder(
              listenable: AppState.instance,
              builder: (_, _) => AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  const LiveDot(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Sekarang ${AppState.instance.inside} orang di dalam · ${AppState.instance.crowdLabel} (${AppState.instance.percent}%)',
                        style: AppText.subheadline.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ),
            // [P6 intl] Tanggal hari ini dalam Bahasa Indonesia (catatan di bawah grup).
            GroupedList(
              header: 'Jumlah pengunjung',
              indent: 16,
              footer: 'Berlaku untuk hari ini, ${tanggalHariIni()}',
              children: [
                _counterRow('Usia 3 tahun ke atas', '${rupiah(Ticket.pricePerPerson)} / orang', _adults, 1, 30, (v) => setState(() => _adults = v)),
                _counterRow('Anak di bawah 3 tahun', 'Gratis', _kids, 0, 10, (v) => setState(() => _kids = v)),
              ],
            ),
            const SectionLabel('Perkiraan jam datang'),
            // [P4 DropdownButton] Memilih satu jam dari daftar; onChanged mengubah state lewat setState().
            DropdownButtonFormField<String>(
              key: ValueKey(_slots.join('|')),
              initialValue: _arrival,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              icon: const Icon(CupertinoIcons.chevron_down, size: 16, color: AppColors.abu),
              decoration: const InputDecoration(prefixIcon: Icon(CupertinoIcons.clock, size: 20)),
              items: [
                for (final slot in _slots) DropdownMenuItem(value: slot, child: Text(slot, style: AppText.number(17, weight: FontWeight.w400))),              ],
              onChanged: (value) => setState(() => _arrival = value!),
            ),
            const SectionLabel('Parkir kendaraan'),
            // Pilih satu jenis parkir (cara kerjanya seperti RadioButton, tampilannya kotak pilihan).
            Row(children: [
              for (final (i, p) in Parking.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _parkingTile(p)),
              ],
            ]),
            const SectionLabel('Data pemesan'),
            // [P6 TextFormField + validator] Validator mengembalikan pesan error, atau null kalau isian benar.
            TextFormField(  
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Nama sesuai identitas', prefixIcon: Icon(CupertinoIcons.person, size: 20)),
              validator: (v) => Validators.required(v, 'Nama'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _whatsapp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'No. WhatsApp, mis. 081234567890', prefixIcon: Icon(CupertinoIcons.phone, size: 20)),
              validator: Validators.whatsapp,
            ),
            // [P4 RadioButton] Pilih tepat satu metode pembayaran dari satu kelompok pilihan.
            RadioGroup<PaymentMethod>(
              groupValue: _payment,
              onChanged: (value) => setState(() => _payment = value!),
              child: GroupedList(header: 'Metode pembayaran', children: [
                for (final m in PaymentMethod.values)
                  RadioListTile<PaymentMethod>(
                    value: m,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                    secondary: Icon(_paymentIcons[m], size: 20, color: AppColors.leaf),
                    title: Text(m.label, style: AppText.body),
                  ),
              ]),
            ),
            const SizedBox(height: 12),
            // [P4 Checkbox] Persetujuan aturan kunjungan (true/false), wajib dicentang sebelum bayar.
            AppCard(
              color: _agree ? AppColors.leaf12 : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: CheckboxListTile(
                value: _agree,
                onChanged: (value) => setState(() => _agree = value ?? false),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('Saya sudah membaca aturan kunjungan (tidak memakai sabun dan sampo di kolam).', style: AppText.subheadline.copyWith(color: AppColors.ink)),
              ),
            ),
          ]),
        ),
      ),
      // Bar kaca mengambang: total harga dan tombol aksi. Ditaruh di bottomNavigationBar supaya tidak ikut tergulir.
      bottomNavigationBar: TotalBar(
        label: 'Total (${_adults + _kids} orang)',
        amount: _total,
        button: _payment == PaymentMethod.qris ? 'Bayar dengan QRIS' : 'Pesan, Bayar di Loket',
        onPressed: _pay,
      ),
    );
  }

  Widget _counterRow(String title, String subtitle, int value, int min, int max, ValueChanged<int> onChanged) => ListRow(
        title: title,
        subtitle: subtitle,
        subtitleStyle: AppText.number(13, weight: FontWeight.w500, color: AppColors.abu),
        trailing: StepperControl(value: value, min: min, max: max, label: title, onChanged: onChanged),
      );

  // Kotak pilihan parkir: ikon kendaraan, nama, dan tarif. Yang dipilih berlatar Hijau Daun 12% dan bergaris Hijau Daun.
  Widget _parkingTile(Parking p) {
    final active = p == _parking;
    return Semantics(
      selected: active,
      child: AppCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: active ? AppColors.leaf12 : Colors.white,
        borderColor: active ? AppColors.leaf : null,
        onTap: () => setState(() => _parking = p),
        child: Column(children: [
          Icon(_parkingIcons[p], size: 24, color: active ? AppColors.leaf : AppColors.abu),
          const SizedBox(height: 6),
          Text(p.label, style: AppText.footnote.copyWith(color: active ? AppColors.forest : AppColors.ink, fontWeight: FontWeight.w600)),
          const SizedBox(height: 1),
          Text(p.price == 0 ? '-' : rupiah(p.price), style: AppText.number(11, weight: FontWeight.w500, color: AppColors.abu)),
        ]),
      ),
    );
  }
}

// Sheet pembayaran QRIS (simulasi): QR berisi nominal, lalu tombol "Saya Sudah Bayar".
class _QrisSheet extends StatelessWidget {
  const _QrisSheet({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Bayar dengan QRIS', textAlign: TextAlign.center, style: AppText.headline),
      const SizedBox(height: 4),
      const Text('Scan dengan aplikasi bank atau e-wallet.', textAlign: TextAlign.center, style: AppText.footnote),
      const SizedBox(height: 18),
      Center(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
          // Package qr_flutter: membuat gambar QR dari teks (warna Ink sesuai palet).
          child: QrImageView(
            data: 'QRIS SUMBER SIRA $total',
            size: 190,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.ink),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text(rupiah(total), textAlign: TextAlign.center, style: AppText.hero(34)),
      const SizedBox(height: 20),
      // [P5 Navigator.pop] Menutup sheet sambil mengirim hasil (false = batal, true = sudah bayar).
      PrimaryButton(label: 'Saya Sudah Bayar', onPressed: () => Navigator.pop(context, true)),
      const SizedBox(height: 4),
      TextButton(
        style: TextButton.styleFrom(foregroundColor: AppColors.abu, minimumSize: const Size.fromHeight(44)),
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
    ]);
  }
}
