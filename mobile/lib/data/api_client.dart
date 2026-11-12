import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/wahana.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

// Pintu tunggal ke backend SumberSira.
class ApiClient {
  // Emulator Android memakai 10.0.2.2 (= localhost laptop).
  // HP fisik: flutter run --dart-define=API_URL=http://IP-LAPTOP:4000
  static const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:4000');
  static const _timeout = Duration(seconds: 8);

  static Future<List<dynamic>> _getList(String path) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl$path')).timeout(_timeout);
      if (res.statusCode != 200) throw ApiException('Server membalas ${res.statusCode}.');
      return jsonDecode(res.body) as List<dynamic>;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server.');
    }
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
}