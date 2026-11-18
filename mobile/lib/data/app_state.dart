import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';
import '../models/review.dart';
import '../models/ticket.dart';
import '../utils/format.dart';
import 'api_client.dart';

// Penyimpanan data aplikasi. Tiket, booking, dan tarif diambil dari backend; Live Crowd dipisah ke CrowdState
// (data/crowd_state.dart). Layar yang mendengarkan AppState otomatis diperbarui (ChangeNotifier) saat ada
// tiket baru, booking baru, atau tiket discan petugas.
// Aplikasi pengunjung tidak memakai login: riwayat tiket dan booking dikelompokkan per nomor WhatsApp.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  static const int capacity = 300;

  final List<Ticket> tickets = [];
  final List<Booking> bookings = [];
  // Ulasan dari server (GET /reviews). Rata-rata dan jumlahnya juga dari server.
  List<Review> reviews = [];
  double reviewRating = 0;
  int reviewCount = 0;
  bool reviewsReady = false;
  bool reviewsLoading = false;
  String? reviewsError;

  // Kunci pengaturan yang disimpan di perangkat, tetap ada walau aplikasi ditutup.
  // Riwayat tidak lagi disimpan di perangkat: tiket dan booking dibaca dari server per nomor WhatsApp.
  // Kunci riwayat lama (riwayat_tiket/riwayat_booking) sengaja dibiarkan terabaikan tanpa galat.
  static const _waKey = 'whatsapp_terakhir';
  static const _reminderKey = 'pengingat_jam_sepi';
  static const _onboardingKey = 'sudah_onboarding';
  String savedWhatsapp = '';
  bool quietReminder = false;
  bool onboardingDone = false;

  // [P6 Plugin shared_preferences] Membaca pengaturan tersimpan saat aplikasi dibuka.
  // [P2 Null Safety] Operator ?? memberi nilai bawaan kalau data belum pernah disimpan.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    savedWhatsapp = prefs.getString(_waKey) ?? '';
    quietReminder = prefs.getBool(_reminderKey) ?? false;
    onboardingDone = prefs.getBool(_onboardingKey) ?? false;
  }

  // Tarif tiket dan parkir dari server (GET /pricing). Bila server tidak terjangkau,
  // dipakai harga bawaan di model (Ticket.pricePerPerson dan tarif di enum Parking).
  int hargaTiket = Ticket.pricePerPerson;
  final Map<Parking, int> parkirTarif = {for (final p in Parking.values) p: p.price};

  // Mengambil tarif terbaru dari server. Gagal diam-diam: tarif bawaan tetap dipakai.
  Future<void> refreshPricing() async {
    try {
      final p = await ApiClient.fetchPricing();
      hargaTiket = p.ticketPricePerPerson;
      for (final t in p.parking) {
        final cocok = Parking.values.where((v) => v.name == t.key).toList();
        if (cocok.isNotEmpty) parkirTarif[cocok.first] = t.price;
      }
      notifyListeners();
    } on ApiException {
      // server tidak terjangkau: tarif bawaan
    }
  }

  // Menyimpan pilihan pengingat jam sepi (Switch di Profil).
  Future<void> setQuietReminder(bool value) async {
    quietReminder = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, value);
  }

  // Onboarding cukup tampil sekali. Setelah selesai atau dilewati, Splash langsung ke Beranda.
  Future<void> finishOnboarding() async {
    onboardingDone = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // Menyimpan nomor WhatsApp terakhir: form berikutnya terisi otomatis dan Tiket Saya
  // langsung menampilkan riwayat nomor ini.
  Future<void> saveWhatsapp(String value) async {
    savedWhatsapp = nomorWa(value);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_waKey, savedWhatsapp);
  }

  // Tiket yang dibeli lewat aplikasi ini, yang terbaru di atas.
  List<Ticket> get myTickets => tickets.where((t) => t.mine).toList().reversed.toList();

  // Riwayat tiket untuk satu nomor WhatsApp, yang terbaru di atas.
  List<Ticket> ticketsFor(String whatsapp) {
    final wa = nomorWa(whatsapp);
    if (wa.isEmpty) return [];
    return tickets.where((t) => t.whatsapp.isNotEmpty && nomorWa(t.whatsapp) == wa).toList().reversed.toList();
  }

  // Riwayat booking sewa dan wahana untuk satu nomor WhatsApp, yang terbaru di atas.
  List<Booking> bookingsFor(String whatsapp) {
    final wa = nomorWa(whatsapp);
    if (wa.isEmpty) return [];
    return bookings.where((b) => nomorWa(b.whatsapp) == wa).toList().reversed.toList();
  }

  // Beli tiket lewat server. Harga dan kode ditentukan server, jadi tiket yang tampil sama dengan yang dilihat petugas.
  // Melempar ApiException bila gagal (server tidak terjangkau atau isian ditolak).
  Future<Ticket> buyTicketOnline({required String name, required String whatsapp, required int adults, required int kids, required Parking parking, PaymentMethod payment = PaymentMethod.qris, String arrival = ''}) async {
    final ticket = await ApiClient.buyTicket(name: name, whatsapp: nomorWa(whatsapp), adults: adults, kids: kids, parking: parking, payment: payment, arrival: arrival);
    _upsert(ticket);
    notifyListeners();
    return ticket;
  }

  // Menambah tiket, atau mengganti yang kodenya sama.
  void _upsert(Ticket ticket) {
    final i = tickets.indexWhere((t) => t.code == ticket.code);
    i >= 0 ? tickets[i] = ticket : tickets.add(ticket);
  }

  // Riwayat tiket satu nomor WhatsApp dari server (tanpa login). Hasilnya digabung ke daftar di memori;
  // tidak ada lagi salinan riwayat di perangkat.
  Future<void> syncHistory(String whatsapp) async {
    final wa = nomorWa(whatsapp);
    if (wa.isEmpty) return;
    final tiket = await ApiClient.fetchTickets(wa);
    final pesanan = await ApiClient.fetchBookings(wa);
    for (final t in tiket) {
      _upsert(t);
    }
    for (final b in pesanan) {
      _upsertBooking(b);
    }
    notifyListeners();
  }

  // Memperbarui satu tiket dari server (GET /tickets/:code?whatsapp=): status check-in dan status
  // pembayaran bisa berubah kapan saja (petugas memindai, tunai dikonfirmasi di loket). Tiket yang
  // belum ada di perangkat diadopsi bila nomor WhatsApp tersimpan cocok. Gagal diam-diam: tampilan
  // tetap memakai data terakhir.
  Future<void> refreshTicket(String code) async {
    final t = find(code);
    // Tiket lama tanpa data server tidak perlu diperbarui.
    if (t != null && !t.synced) return;
    final wa = (t != null && t.whatsapp.isNotEmpty) ? t.whatsapp : savedWhatsapp;
    if (wa.isEmpty) return;
    try {
      final latest = await ApiClient.fetchTicket(code, wa);
      final berubah = t == null ||
          t.status != latest.status ||
          t.checkInAt != latest.checkInAt ||
          t.paymentStatus != latest.paymentStatus;
      _upsert(latest);
      if (berubah) notifyListeners();
    } on ApiException {
      // server tidak terjangkau atau tiket tidak dikenal: tampilkan status terakhir
    }
  }

  // Membuat booking di server (dipanggil dari Checkout, saat pengguna menekan tombol bayar).
  // Kode, total, dan harga per item ditentukan server; jika ada wahana dinonaktifkan admin,
  // melempar ApiException dengan kode RIDE_UNAVAILABLE.
  Future<Booking> createBookingOnline({required BookingDraft draft, required String name, required String whatsapp}) async {
    final item = [for (final l in draft.lines) if (l.rideId != null) (rideId: l.rideId!, qty: l.qty)];
    final booking = await ApiClient.createBooking(name: name, whatsapp: nomorWa(whatsapp), slot: draft.slot, items: item);
    _upsertBooking(booking);
    notifyListeners();
    return booking;
  }

  // Menambah booking, atau mengganti yang kodenya sama.
  void _upsertBooking(Booking booking) {
    final i = bookings.indexWhere((b) => b.code == booking.code);
    i >= 0 ? bookings[i] = booking : bookings.add(booking);
  }

  // Memperbarui satu booking dari server (GET /bookings/:code): status pembayaran bisa berubah.
  // Gagal diam-diam: faktur tetap memakai data terakhir.
  Future<void> refreshBooking(String code) async {
    final b = findBooking(code);
    if (b != null && !b.synced) return;
    final wa = (b != null && b.whatsapp.isNotEmpty) ? b.whatsapp : savedWhatsapp;
    if (wa.isEmpty) return;
    try {
      final latest = await ApiClient.fetchBooking(code, wa);
      final berubah = b == null || b.paymentStatus != latest.paymentStatus;
      _upsertBooking(latest);
      if (berubah) notifyListeners();
    } on ApiException {
      // server tidak terjangkau: tampilkan data terakhir
    }
  }

  // Penanda bahwa daftar wahana perlu dimuat ulang dari server (mis. ada wahana dinonaktifkan admin
  // setelah layar dibuka). BookingController mendengarkan perubahan penanda ini.
  int wahanaRevision = 0;
  void tandaiWahanaStale() {
    wahanaRevision++;
    notifyListeners();
  }

  Ticket? find(String code) {
    for (final t in tickets) {
      if (t.code == code) return t;
    }
    return null;
  }

  Booking? findBooking(String code) {
    for (final b in bookings) {
      if (b.code == code) return b;
    }
    return null;
  }

  // Mengambil ulasan terbaru, rata-rata bintang, dan jumlah ulasan dari server.
  // Gagal terhubung: data terakhir tetap tampil dan pesan galat disimpan untuk layar.
  Future<void> refreshReviews() async {
    reviewsLoading = true;
    reviewsError = null;
    notifyListeners();
    try {
      final summary = await ApiClient.fetchReviews();
      reviews = summary.items;
      reviewRating = summary.rating;
      reviewCount = summary.count;
      reviewsReady = true;
    } on ApiException catch (e) {
      reviewsError = e.message;
    } finally {
      reviewsLoading = false;
      notifyListeners();
    }
  }

  // Kirim ulasan baru ke server (POST /reviews), lalu muat ulang daftar dan rata-ratanya.
  // Nama memakai pemesan tiket terakhir di perangkat; bila belum ada tiket, "Pengunjung".
  Future<void> submitReview({required int stars, required String text}) async {
    final name = myTickets.isNotEmpty ? myTickets.first.name : 'Pengunjung';
    await ApiClient.postReview(name: name, stars: stars, text: text);
    await refreshReviews();
  }
}
