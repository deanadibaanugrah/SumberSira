import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/app_state.dart';
import '../../../data/api_client.dart';
import '../../crowd/viewmodel/crowd_state.dart';
import '../../../models/payment.dart';
import '../../../models/ticket.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/format.dart';
import '../../../utils/routes.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/common.dart';
import '../../crowd/view/crowd_widgets.dart';
import '../../../widgets/glass.dart';
import '../../../widgets/motion.dart';

// Form beli tiket masuk. StatefulWidget karena isinya berubah saat pengguna mengisi.
// Unsur materi: Form + TextFormField + validator (P6), TextEditingController, DropdownButton,
// RadioButton, Checkbox, dan setState (P4), lalu pindah ke halaman e-tiket membawa data (P5).
class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({super.key});

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _state = AppState.instance;
  // [P6 Form] Kunci form untuk menjalankan semua validator sekaligus lewat validate().
  final _formKey = GlobalKey<FormState>();
  // [P4 TextEditingController] Membaca isi kolom nama dan WhatsApp (nomor terakhir diisi dari shared_preferences).
  final _name = TextEditingController();
  late final _whatsapp = TextEditingController(
    text: AppState.instance.savedWhatsapp,
  );
  // State form. Setiap perubahan lewat setState() supaya tampilan dan total ikut berubah.
  int _adults = 2;
  int _kids = 0;
  Parking _parking = Parking.motor;
  // Jam datang hanya dari backend (GET /time-slots). Kosong sampai server menjawab.
  List<String> _slots = const [];
  String _arrival = '';
  bool _loadingSlots = true;
  String? _slotsError;
  PaymentMethod _payment = PaymentMethod.qris;
  bool _agree = false;
  // True selama tiket dikirim ke server (tombol bayar menampilkan loading).
  bool _paying = false;

  // Total pratinjau memakai tarif server. Null bila tarif belum termuat: tampilkan "—",
  // jangan menebak harga. Angka final tetap dihitung server saat tiket dibuat.
  int? get _total {
    final harga = _state.hargaTiket;
    final tarif = _parking == Parking.none ? 0 : _state.parkirTarif[_parking];
    if (harga == null || tarif == null) return null;
    return _adults * harga + tarif;
  }

  // Ikon tiap pilihan parkir dan metode pembayaran.
  static const _parkingIcons = {
    Parking.none: Icons.directions_walk_rounded,
    Parking.motor: Icons.two_wheeler_outlined,
    Parking.mobil: Icons.directions_car_outlined,
    Parking.bus: Icons.directions_bus_outlined,
  };
  static const _paymentIcons = {
    PaymentMethod.qris: CupertinoIcons.qrcode,
    PaymentMethod.cash: Icons.payments_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadSlots();
    // Tarif terbaru dari server (GET /pricing); ketika sampai, form di-render ulang lewat listener AppState.
    _state.addListener(_tarifBerubah);
    _state.refreshPricing();
  }

  void _tarifBerubah() {
    if (mounted) setState(() {});
  }

  // Jam datang diambil dari backend (GET /time-slots). Gagal: tampilkan pesan dan tombol coba lagi,
  // bukan daftar jam bawaan yang belum tentu diterima server.
  Future<void> _loadSlots() async {
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
    });
    try {
      final slots = await ApiClient.fetchTimeSlots();
      if (!mounted) return;
      setState(() {
        _slots = slots;
        _loadingSlots = false;
        if (slots.isEmpty) {
          _arrival = '';
          _slotsError = 'Belum ada jam datang yang aktif di server.';
        } else if (!slots.contains(_arrival)) {
          _arrival = slots.first;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _slots = const [];
        _arrival = '';
        _loadingSlots = false;
        _slotsError = e.message;
      });
    }
  }

  @override
  void dispose() {
    _state.removeListener(_tarifBerubah);
    _name.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  // Tombol bayar: cek validator dan persetujuan, buat tiket di server (POST /tickets), lalu
  // QRIS membuka sheet pembayaran mengikuti pola bagian 6 planning; tunai langsung ke e-tiket
  // dengan status "menunggu pembayaran di loket". Tiket dibuat di server supaya petugas bisa
  // memindainya dan Live Crowd ikut naik. Harga dihitung server.
  Future<void> _pay() async {
    if (_paying) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Centang persetujuan aturan kunjungan dulu.'),
        ),
      );
      return;
    }
    if (_arrival.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jam datang belum tersedia dari server. Muat ulang dulu.',
          ),
        ),
      );
      return;
    }
    if (_state.hargaTiket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tarif belum termuat dari server. Periksa koneksi lalu coba lagi.',
          ),
        ),
      );
      return;
    }
    setState(() => _paying = true);
    try {
      final ticket = await _state.buyTicketOnline(
        name: _name.text,
        whatsapp: _whatsapp.text,
        adults: _adults,
        kids: _kids,
        parking: _parking,
        payment: _payment,
        arrival: _arrival,
      );
      _state.saveWhatsapp(_whatsapp.text);
      if (!mounted) return;
      // QRIS: tiket sudah ada di server dengan pembayaran pending; QR asli ditunggu lunas lewat sheet.
      if (_payment == PaymentMethod.qris) {
        await showGlassSheet<bool>(
          context,
          builder: (_) => _QrisSheet(ticket: ticket),
        );
        if (!mounted) return;
      }
      // [P5 Named Route] Pindah ke e-tiket sambil mengirim kode tiket sebagai argumen.
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.eticket,
        arguments: ticket.code,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      // Tidak membuat tiket palsu di perangkat: tiket yang tidak tercatat di server tidak bisa discan petugas.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.offline
                ? 'Tiket belum dibuat: tidak bisa terhubung ke server. Periksa koneksi lalu coba lagi.'
                : e.message,
          ),
        ),
      );
    }
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
          child: ResponsiveBody(
            children: [
              // Keramaian saat ini (live) sebagai pertimbangan sebelum datang.
              ListenableBuilder(
                listenable: CrowdState.instance,
                builder: (_, _) {
                  final c = CrowdState.instance;
                  return AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        LiveDot(
                          color: c.ready ? AppColors.leaf : AppColors.abu,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            c.ready
                                ? 'Sekarang ${c.inside} orang di dalam · ${c.crowdLabel} (${c.percent}%)'
                                : 'Data keramaian belum tersedia dari server.',
                            style: AppText.subheadline.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // [P6 intl] Tanggal hari ini dalam Bahasa Indonesia (catatan di bawah grup).
              GroupedList(
                header: 'Jumlah pengunjung',
                indent: 16,
                footer: 'Berlaku untuk hari ini, ${tanggalHariIni()}',
                children: [
                  _counterRow(
                    'Usia 3 tahun ke atas',
                    _state.hargaTiket == null
                        ? 'Tarif belum tersedia'
                        : '${rupiah(_state.hargaTiket!)} / orang',
                    _adults,
                    1,
                    30,
                    (v) => setState(() => _adults = v),
                  ),
                  _counterRow(
                    'Anak di bawah 3 tahun',
                    'Gratis',
                    _kids,
                    0,
                    10,
                    (v) => setState(() => _kids = v),
                  ),
                ],
              ),
              const SectionLabel('Perkiraan jam datang'),
              if (_loadingSlots)
                const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Memuat jam datang dari server...',
                        style: AppText.footnote,
                      ),
                    ],
                  ),
                )
              else if (_slotsError != null)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 18,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_slotsError!, style: AppText.footnote),
                      ),
                      PressScale(
                        child: TextButton(
                          onPressed: _loadSlots,
                          child: const Text('Coba lagi'),
                        ),
                      ),
                    ],
                  ),
                )
              else
                // [P4 DropdownButton] Memilih satu jam dari daftar server; onChanged mengubah state lewat setState().
                DropdownButtonFormField<String>(
                  key: ValueKey(_slots.join('|')),
                  initialValue: _arrival,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: AppColors.abu,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(CupertinoIcons.clock, size: 20),
                  ),
                  items: [
                    for (final slot in _slots)
                      DropdownMenuItem(
                        value: slot,
                        child: Text(
                          slot,
                          style: AppText.number(17, weight: FontWeight.w400),
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _arrival = value!),
                ),
              const SectionLabel('Parkir kendaraan'),
              // Pilih satu jenis parkir (cara kerjanya seperti RadioButton, tampilannya kotak pilihan).
              Row(
                children: [
                  for (final (i, p) in Parking.values.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _parkingTile(p)),
                  ],
                ],
              ),
              const SectionLabel('Data pemesan'),
              // [P6 TextFormField + validator] Validator mengembalikan pesan error, atau null kalau isian benar.
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Nama sesuai identitas',
                  prefixIcon: Icon(CupertinoIcons.person, size: 20),
                ),
                validator: (v) => Validators.required(v, 'Nama'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'No. WhatsApp, mis. 081234567890',
                  prefixIcon: Icon(CupertinoIcons.phone, size: 20),
                ),
                validator: Validators.whatsapp,
              ),
              // [P4 RadioButton] Pilih tepat satu metode pembayaran dari satu kelompok pilihan.
              RadioGroup<PaymentMethod>(
                groupValue: _payment,
                onChanged: (value) => setState(() => _payment = value!),
                child: GroupedList(
                  header: 'Metode pembayaran',
                  children: [
                    for (final m in PaymentMethod.values)
                      RadioListTile<PaymentMethod>(
                        value: m,
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                        secondary: Icon(
                          _paymentIcons[m],
                          size: 20,
                          color: AppColors.leaf,
                        ),
                        title: Text(m.label, style: AppText.body),
                      ),
                  ],
                ),
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
                  title: Text(
                    'Saya sudah membaca aturan kunjungan (tidak memakai sabun dan sampo di kolam).',
                    style: AppText.subheadline.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bar kaca mengambang: total harga dan tombol aksi. Ditaruh di bottomNavigationBar supaya tidak ikut tergulir.
      bottomNavigationBar: TotalBar(
        label: 'Total (${_adults + _kids} orang)',
        amount: _total,
        button: _payment == PaymentMethod.qris
            ? 'Bayar dengan QRIS'
            : 'Pesan, Bayar di Loket',
        onPressed: _pay,
        loading: _paying,
      ),
    );
  }

  Widget _counterRow(
    String title,
    String subtitle,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) => ListRow(
    title: title,
    subtitle: subtitle,
    subtitleStyle: AppText.number(
      13,
      weight: FontWeight.w500,
      color: AppColors.abu,
    ),
    trailing: StepperControl(
      value: value,
      min: min,
      max: max,
      label: title,
      onChanged: onChanged,
    ),
  );

  // Kotak pilihan parkir: ikon kendaraan, nama, dan tarif dari server. Yang dipilih berlatar Hijau Daun 12% dan bergaris Hijau Daun.
  Widget _parkingTile(Parking p) {
    final active = p == _parking;
    final tarif = p == Parking.none ? 0 : _state.parkirTarif[p];
    return Semantics(
      selected: active,
      child: AppCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: active ? AppColors.leaf12 : Colors.white,
        borderColor: active ? AppColors.leaf : null,
        onTap: () => setState(() => _parking = p),
        child: Column(
          children: [
            Icon(
              _parkingIcons[p],
              size: 24,
              color: active ? AppColors.leaf : AppColors.abu,
            ),
            const SizedBox(height: 6),
            Text(
              p.label,
              style: AppText.footnote.copyWith(
                color: active ? AppColors.forest : AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              tarif == null
                  ? '—'
                  : tarif == 0
                  ? '-'
                  : rupiah(tarif),
              style: AppText.number(
                11,
                weight: FontWeight.w500,
                color: AppColors.abu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sheet pembayaran QRIS: QR asli dari server (dibuat bersama tiket). Status pembayaran diperiksa
// ke server tiap 3 detik selama sheet tampil. Backend mode simulasi menampilkan tombol "Saya Sudah
// Bayar"; mode sungguhan hanya menampilkan indikator menunggu sampai dibayar dari aplikasi pembayaran.
class _QrisSheet extends StatefulWidget {
  const _QrisSheet({required this.ticket});

  final Ticket ticket;

  @override
  State<_QrisSheet> createState() => _QrisSheetState();
}

class _QrisSheetState extends State<_QrisSheet> {
  late PaymentInfo _pay;
  Timer? _poll;
  // True selama tombol "Saya Sudah Bayar" (mode simulasi) sedang memproses.
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    // Data pembayaran dari respons pembuatan tiket; id dipakai untuk polling.
    _pay = PaymentInfo(
      id: widget.ticket.paymentId ?? '',
      status: widget.ticket.paymentStatus.name,
      amount: widget.ticket.total ?? 0,
      provider: widget.ticket.paymentProvider,
      qrString: widget.ticket.qrString,
      qrUrl: widget.ticket.qrUrl,
      expiresAt: widget.ticket.expiresAt,
    );
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _periksa());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  // Polling GET /payments/:id (bagian 6 planning). Berhenti sendiri saat status sudah final.
  Future<void> _periksa() async {
    if (_pay.id.isEmpty || _pay.selesai || _pay.tutup) return;
    try {
      final p = await ApiClient.fetchPayment(_pay.id);
      if (!mounted) return;
      setState(() => _pay = p);
      if (p.selesai) _tuntaskan();
    } on ApiException {
      // server tidak terjangkau: dicoba lagi pada polling berikutnya
    }
  }

  // Lunas: hentikan polling lalu tutup sheet; pemanggil melanjutkan ke e-tiket.
  void _tuntaskan() {
    _poll?.cancel();
    Navigator.pop(context, true);
  }

  // Tombol "Saya Sudah Bayar" (hanya mode simulasi backend): minta server menandai lunas.
  Future<void> _sudahBayar() async {
    if (_confirming || _pay.id.isEmpty) return;
    setState(() => _confirming = true);
    try {
      final p = await ApiClient.simulatePayment(_pay.id);
      if (!mounted) return;
      setState(() {
        _pay = p;
        _confirming = false;
      });
      if (p.selesai) _tuntaskan();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // Teks QR untuk dipindai; bila server hanya mengirim URL gambar, tampilkan gambar itu.
  Widget _qr() {
    final q = _pay.qrString;
    if (q != null && q.isNotEmpty) {
      return QrImageView(
        data: q,
        size: 190,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.ink,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.ink,
        ),
      );
    }
    final url = _pay.qrUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(url, width: 190, height: 190, fit: BoxFit.cover),
      );
    }
    // Cadangan: QR kode tiket, sama dengan yang discan petugas.
    return QrImageView(
      data: widget.ticket.code,
      size: 190,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: AppColors.ink,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: AppColors.ink,
      ),
    );
  }

  // Pesan ketika pembayaran tidak bisa dilanjutkan (expired, failed, cancelled).
  String get _pesanAkhir => switch (_pay.status) {
    'expired' => 'Batas waktu pembayaran habis.',
    'failed' => 'Pembayaran gagal diproses.',
    _ => 'Pembayaran dibatalkan.',
  };

  @override
  Widget build(BuildContext context) {
    final tutup = _pay.tutup;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bayar dengan QRIS',
          textAlign: TextAlign.center,
          style: AppText.display(22),
        ),
        const SizedBox(height: 4),
        const Text(
          'Scan dengan aplikasi bank atau e-wallet.',
          textAlign: TextAlign.center,
          style: AppText.footnote,
        ),
        const SizedBox(height: 18),
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            // Package qr_flutter: membuat gambar QR dari teks QRIS asli dari server (warna Ink sesuai palet).
            child: Opacity(opacity: tutup ? .45 : 1, child: _qr()),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          rupiah(_pay.amount),
          textAlign: TextAlign.center,
          style: AppText.hero(34),
        ),
        const SizedBox(height: 14),
        if (tutup) ...[
          Text(
            _pesanAkhir,
            textAlign: TextAlign.center,
            style: AppText.subheadline.copyWith(
              color: AppColors.coral,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tiket sudah tercatat. Cek statusnya lagi lewat Riwayat.',
            textAlign: TextAlign.center,
            style: AppText.footnote,
          ),
        ] else ...[
          // Indikator menunggu: mode sungguhan tetap di sini sampai pembayaran terkonfirmasi server.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.leaf,
                ),
              ),
              const SizedBox(width: 10),
              Text('Menunggu pembayaran...', style: AppText.subheadline),
            ],
          ),
        ],
        const SizedBox(height: 20),
        if (tutup) ...[
          PrimaryButton(
            label: 'Tutup',
            onPressed: () => Navigator.pop(context, false),
          ),
        ] else ...[
          // [P5 Navigator.pop] Tombol simulasi (mode uji backend) menandai lunas lalu menutup sheet.
          if (_pay.simulasi)
            PrimaryButton(
              label: 'Saya Sudah Bayar',
              onPressed: _sudahBayar,
              loading: _confirming,
            ),
          const SizedBox(height: 4),
          PressScale(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.abu,
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
