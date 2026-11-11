import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/live.dart';
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

  // Pesan untuk pengunjung dari kode kesalahan backend.
  static String _message(int status, String code) {
    if (status == 429) return 'Terlalu banyak permintaan. Coba lagi sebentar lagi.';
    return switch (code) {
      'INVALID_WHATSAPP' => 'Nomor WhatsApp tidak valid.',
      'INVALID_DATE' => 'Tanggal kunjungan tidak valid.',
      'VALIDATION' => 'Isian belum lengkap atau tidak valid.',
      'TOO_MANY_PENDING' => 'Pertanyaanmu ke pengelola masih banyak yang menunggu. Tunggu dibalas dulu ya.',
      _ => 'Server membalas $status.',
    };
  }

  // Satu pintu semua permintaan: waktu tunggu, JSON, dan pesan kesalahan yang ramah.
  static Future<dynamic> _request(String method, String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final http.Response res;
    try {
      final headers = {'content-type': 'application/json'};
      res = await switch (method) {
        'POST' => http.post(uri, headers: headers, body: jsonEncode(body)),
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
    return data;
  }

  static Future<List<dynamic>> _getList(String path) async => (await _request('GET', path)) as List<dynamic>;

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

  static Future<CrowdInfo> fetchCrowd() async => CrowdInfo.fromJson(await _request('GET', '/crowd') as Map<String, dynamic>);

  static Future<HourlyCrowd> fetchHourly() async => HourlyCrowd.fromJson(await _request('GET', '/crowd/hourly') as Map<String, dynamic>);

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
      'payment': payment.name,
      'arrival': arrival,
    });
    return Ticket.fromApi(data as Map<String, dynamic>);
  }

  // Riwayat tiket satu nomor WhatsApp (tanpa login).
  static Future<List<Ticket>> fetchTickets(String whatsapp) async {
    final data = await _getList('/tickets?whatsapp=${Uri.encodeQueryComponent(whatsapp)}');
    return [for (final e in data) Ticket.fromApi(e as Map<String, dynamic>)];
  }

  // Status satu tiket (sudah discan petugas atau belum). Sengaja tanpa data pribadi.
  static Future<({TicketStatus status, String? checkInAt})> fetchTicketStatus(String code) async {
    final j = await _request('GET', '/tickets/$code/status') as Map<String, dynamic>;
    final at = j['checkInAt'] as String?;
    return (status: TicketStatus.values.byName(j['status'] as String), checkInAt: at == null ? null : Ticket.jamWib(at));
  }

  // ---------- Chatbot Tanya Sira ----------

  // Jawab cepat: FAQ pengelola, lalu AI dari data Sumber Sira.
  static Future<ChatAnswer> askChat(String question, String deviceId) async =>
      ChatAnswer.fromJson(await _request('POST', '/chat/ask', body: {'question': question, 'deviceId': deviceId}) as Map<String, dynamic>);

  // Kirim pertanyaan ke pengelola (jawaban lambat, menunggu dibalas manusia).
  static Future<ManagerQuestion> askManager(String question, String deviceId) async =>
      ManagerQuestion.fromJson(await _request('POST', '/chat/questions', body: {'question': question, 'deviceId': deviceId}) as Map<String, dynamic>);

  // Pertanyaan milik perangkat ini beserta balasan pengelola.
  static Future<List<ManagerQuestion>> fetchManagerQuestions(String deviceId) async {
    final data = await _getList('/chat/questions?deviceId=${Uri.encodeQueryComponent(deviceId)}');
    return [for (final e in data) ManagerQuestion.fromJson(e as Map<String, dynamic>)];
  }
}
