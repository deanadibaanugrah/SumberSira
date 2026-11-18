import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/booking.dart';
import '../models/gallery.dart';
import '../models/live.dart';
import '../models/payment.dart';
import '../models/pricing.dart';
import '../models/review.dart';
import '../models/ticket.dart';
import '../models/wahana.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.code = ''});
  final String message;
  // Kode kesalahan dari backend, mis. INVALID_WHATSAPP. Kosong bila server tidak terjangkau.
  final String code;

  // True bila penyebabnya jaringan atau server mati (bukan isian yang salah).
  bool get offline => code == 'OFFLINE';

  @override
  String toString() => message;
}

// Pintu tunggal ke backend SumberSira.
class ApiClient {
  // Emulator Android memakai 10.0.2.2 (= localhost laptop).
  // HP fisik: flutter run --dart-define=API_URL=http://IP-LAPTOP:4000
  static const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:4000');
  static const _timeout = Duration(seconds: 8);
  // Unggah foto dan proses AI Photo butuh waktu lebih lama daripada permintaan JSON biasa.
  static const _uploadTimeout = Duration(seconds: 45);

  // Pesan untuk pengunjung dari kode kesalahan backend. Pesan Indonesia, bukan teks mentah server.
  static String _message(int status, String code) {
    return switch (code) {
      'VALIDATION' => 'Periksa kembali isian kamu.',
      'RATE_LIMITED' => 'Terlalu banyak percobaan. Coba lagi sebentar.',
      'PAYMENT_PROVIDER_ERROR' => 'Pembayaran sedang bermasalah. Coba lagi nanti.',
      'RIDE_UNAVAILABLE' => 'Ada wahana yang sudah tidak tersedia.',
      'NOT_FOUND' => 'Data tidak ditemukan.',
      'PROCESSING_FAILED' => 'Foto belum bisa diproses. Coba lagi.',
      'FILE_TOO_LARGE' => 'Foto terlalu besar. Maksimal 4 MB.',
      'UNSUPPORTED_MEDIA' => 'Format foto harus JPEG, PNG, atau WebP.',
      'DUPLICATE' => 'Foto ini sudah pernah dibagikan ke galeri.',
      'INVALID_STATE' => 'Foto belum selesai diproses.',
      'INVALID_WHATSAPP' => 'Nomor WhatsApp tidak valid.',
      'INVALID_DATE' => 'Tanggal kunjungan tidak valid.',
      'TOO_MANY_PENDING' => 'Pertanyaanmu ke pengelola masih banyak yang menunggu. Tunggu dibalas dulu ya.',
      'BAD_RESPONSE' => 'Server membalas dengan data yang tidak lengkap. Coba lagi.',
      'OFFLINE' => 'Tidak dapat terhubung ke server.',
      _ => status == 429 ? 'Terlalu banyak percobaan. Coba lagi sebentar.' : 'Server membalas $status.',
    };
  }

  // Satu pintu semua permintaan: waktu tunggu, JSON, dan pesan kesalahan yang ramah.
  static Future<dynamic> _request(String method, String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final http.Response res;
    try {
      // Body null (mis. POST /payments/:id/simulate-pay) tidak boleh dikirim sebagai teks "null":
      // body-parser backend menolaknya, sehingga aksi tanpa isi selalu gagal.
      final encoded = body == null ? null : jsonEncode(body);
      final headers = encoded == null ? null : {'content-type': 'application/json'};
      res = await switch (method) {
        'POST' => http.post(uri, headers: headers, body: encoded),
        'PATCH' => http.patch(uri, headers: headers, body: encoded),
        'PUT' => http.put(uri, headers: headers, body: encoded),
        _ => http.get(uri),
      }
          .timeout(_timeout);
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server.', code: 'OFFLINE');
    }
    dynamic data;
    try {
      data = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      data = null;
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final code = data is Map ? (data['error'] as String? ?? '') : '';
      throw ApiException(_message(res.statusCode, code), code: code);
    }
    // Balasan tanpa isi (mis. 204 atau body kosong) bukan data yang bisa dipakai.
    // Tanpa pemeriksaan ini, cast di pemanggil melempar TypeError, bukan ApiException.
    if (data == null) {
      throw ApiException('Server membalas tanpa data. Coba lagi.', code: 'BAD_RESPONSE');
    }
    return data;
  }

  // Kirim satu berkas (multipart/form-data) beserta isian teks, mis. unggah foto galeri (F6).
  // Tipe berkas dan ukuran maksimum tetap diverifikasi ulang oleh backend.
  static Future<dynamic> postMultipart(String path, Map<String, String> fields, {required String fileField, required String fileName, required List<int> fileBytes}) => _multipart(path, fields, fileField: fileField, fileName: fileName, fileBytes: fileBytes);

  static Future<dynamic> _multipart(String path, Map<String, String> fields, {required String fileField, required String fileName, required List<int> fileBytes}) async {
    final uri = Uri.parse('$baseUrl$path');
    final http.Response res;
    try {
      final req = http.MultipartRequest('POST', uri)
        ..fields.addAll(fields)
        ..files.add(http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName));
      res = await http.Response.fromStream(await req.send()).timeout(_uploadTimeout);
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server.', code: 'OFFLINE');
    }
    dynamic data;
    try {
      data = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      data = null;
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final code = data is Map ? (data['error'] as String? ?? '') : '';
      throw ApiException(_message(res.statusCode, code), code: code);
    }
    if (data == null) {
      throw ApiException('Server membalas tanpa data. Coba lagi.', code: 'BAD_RESPONSE');
    }
    return data;
  }

  // Daftar dari server. Bentuk balasan dicek dulu supaya kesalahan server yang tidak terduga
  // tetap muncul sebagai ApiException (pesan ramah), bukan TypeError yang membuat layar kosong.
  static Future<List<dynamic>> _getList(String path) async {
    final data = await _request('GET', path);
    if (data is! List) {
      throw ApiException('Server membalas dengan data yang tidak lengkap. Coba lagi.', code: 'BAD_RESPONSE');
    }
    return data;
  }

  // Objek dari server. Alasannya sama dengan _getList: salah bentuk = ApiException, bukan TypeError.
  static Future<Map<String, dynamic>> _getMap(String path) async => _map(await _request('GET', path));

  static Map<String, dynamic> _map(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw ApiException('Server membalas dengan data yang tidak lengkap. Coba lagi.', code: 'BAD_RESPONSE');
    }
    return data;
  }

  // Wahana dan sewa alat yang berstatus Aktif.
  static Future<List<Wahana>> fetchWahana() async {
    final data = await _getList('/rides');
    return data.map((e) => Wahana.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Pilihan jam kunjungan, mis. "08.00 - 10.00".
  static Future<List<String>> fetchTimeSlots() async {
    final data = await _getList('/time-slots');
    return data.map((e) => (e as Map<String, dynamic>)['range'] as String).toList();
  }

  // ---------- Live Crowd ----------

  // Keramaian saat ini beserta prakiraan pengunjung per jam hari ini.
  static Future<CrowdInfo> fetchCrowd() async => CrowdInfo.fromJson(await _getMap('/crowd'));

  // ---------- Tiket masuk ----------

  // Beli tiket. Harga dihitung server, jadi hasilnya (kode, total) yang dipakai aplikasi.
  static Future<Ticket> buyTicket({
    required String name,
    required String whatsapp,
    required int adults,
    required int kids,
    required Parking parking,
    required PaymentMethod payment,
    required String arrival,
  }) async {
    final data = await _request('POST', '/tickets', body: {
      'name': name.trim(),
      'whatsapp': whatsapp,
      'adults': adults,
      'kids': kids,
      'parking': parking.name,
      'paymentMethod': payment.name,
      'arrival': arrival,
    });
    return Ticket.fromApi(_map(data));
  }

  // Riwayat tiket satu nomor WhatsApp (tanpa login).
  static Future<List<Ticket>> fetchTickets(String whatsapp) async {
    final data = await _getList('/tickets?whatsapp=${Uri.encodeQueryComponent(whatsapp)}');
    return [for (final e in data) Ticket.fromApi(e as Map<String, dynamic>)];
  }

  // Satu tiket berdasar kode + nomor WhatsApp (GET /tickets/:code). 404 bila nomor tidak cocok.
  static Future<Ticket> fetchTicket(String code, String whatsapp) async =>
      Ticket.fromApi(await _getMap('/tickets/$code?whatsapp=${Uri.encodeQueryComponent(whatsapp)}'));

  // ---------- Harga & pembayaran ----------

  // Tarif tiket dan parkir dari server (GET /pricing).
  static Future<PricingData> fetchPricing() async => PricingData.fromJson(await _getMap('/pricing'));

  // Status pembayaran terkini (GET /payments/:id). Dipanggil berkala selama QRIS menunggu dibayar.
  static Future<PaymentInfo> fetchPayment(String id) async => PaymentInfo.fromJson(await _getMap('/payments/$id'));

  // Simulasi pembayaran QRIS menjadi lunas (hanya saat backend mode simulasi). Idempoten.
  static Future<PaymentInfo> simulatePayment(String id) async =>
      PaymentInfo.fromJson(_map(await _request('POST', '/payments/$id/simulate-pay')));

  // ---------- Booking sewa & wahana ----------

  // Pilihan jam booking dari server (GET /booking-slots): id "08-09" dikirim ke server, label untuk tampilan.
  static Future<List<({String id, String label})>> fetchBookingSlots() async {
    final data = await _getList('/booking-slots');
    return [for (final e in data) (id: (e as Map<String, dynamic>)['id'] as String, label: e['label'] as String)];
  }

  // Buat booking sewa (POST /bookings). Kode, total, dan harga per item dihitung server; hanya QRIS.
  // Melempar ApiException dengan kode RIDE_UNAVAILABLE bila ada wahana sudah tidak tersedia.
  static Future<Booking> createBooking({required String name, required String whatsapp, required String slot, required List<({String rideId, int qty})> items}) async {
    final data = await _request('POST', '/bookings', body: {
      'name': name.trim(),
      'whatsapp': whatsapp,
      'slot': slot,
      'items': [for (final i in items) {'rideId': i.rideId, 'qty': i.qty}],
    });
    return Booking.fromApi(_map(data));
  }

  // Riwayat booking satu nomor WhatsApp (tanpa login).
  static Future<List<Booking>> fetchBookings(String whatsapp) async {
    final data = await _getList('/bookings?whatsapp=${Uri.encodeQueryComponent(whatsapp)}');
    return [for (final e in data) Booking.fromApi(e as Map<String, dynamic>)];
  }

  // Satu booking (faktur) berdasar kode + nomor WhatsApp. 404 bila nomor tidak cocok.
  static Future<Booking> fetchBooking(String code, String whatsapp) async =>
      Booking.fromApi(await _getMap('/bookings/$code?whatsapp=${Uri.encodeQueryComponent(whatsapp)}'));

  // ---------- Ulasan & rating ----------

  // Daftar ulasan terbaru beserta rata-rata bintang dan jumlah ulasan dari server.
  static Future<ReviewSummary> fetchReviews({int limit = 20}) async => ReviewSummary.fromApi(await _getMap('/reviews?limit=$limit'));

  // Kirim ulasan baru (POST /reviews). Nama, bintang 1..5, dan isi divalidasi backend.
  static Future<Review> postReview({required String name, required int stars, required String text}) async =>
      Review.fromApi(_map(await _request('POST', '/reviews', body: {'name': name.trim(), 'stars': stars, 'text': text.trim()})));

  // ---------- Galeri foto & AI Photo ----------

  // Foto yang sudah disetujui admin (GET /gallery), terbaru di atas.
  static Future<List<GalleryPhoto>> fetchGallery({int limit = 60}) async {
    final data = await _getList('/gallery?limit=$limit');
    return [for (final e in data) GalleryPhoto.fromApi(e as Map<String, dynamic>)];
  }

  // Kirim foto ke galeri (POST /gallery, multipart). Status awal "pending" sampai admin menyetujui.
  static Future<GalleryPhoto> uploadGalleryPhoto({
    required String fileName,
    required List<int> fileBytes,
    required String title,
    required String owner,
  }) async =>
      GalleryPhoto.fromApi(_map(await postMultipart(
        '/gallery',
        {'title': title.trim(), 'owner': owner.trim()},
        fileField: 'photo',
        fileName: fileName,
        fileBytes: fileBytes,
      )));

  // Perbaiki foto di server (POST /ai-photo, multipart). Hasilnya berisi URL foto asli dan hasil.
  static Future<AiPhotoResult> enhancePhoto({required String fileName, required List<int> fileBytes}) async =>
      AiPhotoResult.fromApi(_map(await postMultipart(
        '/ai-photo',
        const {},
        fileField: 'photo',
        fileName: fileName,
        fileBytes: fileBytes,
      )));

  // Bagikan hasil AI Photo ke galeri (POST /ai-photo/:id/share-to-gallery). Masuk sebagai pending.
  static Future<GalleryPhoto> shareAiPhotoToGallery({required String id, required String title, required String owner}) async =>
      GalleryPhoto.fromApi(_map(await _request('POST', '/ai-photo/$id/share-to-gallery', body: {'title': title.trim(), 'owner': owner.trim()})));

  // ---------- Chatbot Tanya Sira ----------

  // Pertanyaan cepat untuk tombol di kotak chat (GET /chat/quick-questions).
  static Future<List<String>> fetchQuickQuestions() async {
    final data = await _getList('/chat/quick-questions');
    return [
      for (final e in data)
        if (e is String && e.trim().isNotEmpty) e.trim() else if (e is Map && (e['question'] as String?)?.trim().isNotEmpty == true) (e['question'] as String).trim(),
    ];
  }

  // Kirim pertanyaan ke Tanya Sira (POST /chat). Pertanyaan yang tidak cocok dicatat server untuk admin.
  static Future<ChatAnswer> askChat(String message) async =>
      ChatAnswer.fromJson(_map(await _request('POST', '/chat', body: {'message': message.trim()})));
}
