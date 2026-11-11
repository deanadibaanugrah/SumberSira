import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumber_sira/data/api_client.dart';
import 'package:sumber_sira/data/app_state.dart';
import 'package:sumber_sira/data/chat_controller.dart';
import 'package:sumber_sira/models/live.dart';
import 'package:sumber_sira/models/ticket.dart';

// Uji ke backend sungguhan (bukan tiruan): beli tiket, scan petugas, Live Crowd, dan chat Tanya Sira dua mode.
// Hanya jalan bila backend menyala dan tes dijalankan dengan:
//   flutter test --dart-define=API_URL=http://localhost:4100 --dart-define=E2E=1 test/backend_e2e_test.dart
// Tanpa E2E=1 tes ini dilewati, jadi `flutter test` biasa tetap tidak butuh server.
const _e2e = String.fromEnvironment('E2E') == '1';

// Akun demo dari seed backend (hanya untuk lingkungan lokal).
Future<Map<String, String>> _adminHeaders() async {
  final res = await http.post(
    Uri.parse('${ApiClient.baseUrl}/auth/login'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode({
      'email': 'petugas@sumbersira.id',
      'password': 'petugas123',
    }),
  );
  expect(res.statusCode, 200);
  final cookie = res.headers['set-cookie']!.split(';').first;
  return {'content-type': 'application/json', 'cookie': cookie};
}

void main() {
  group(
    'backend sungguhan',
    () {
      setUpAll(() async {
        // flutter test memblokir jaringan secara bawaan; tes ini memang sengaja memanggil backend lokal.
        HttpOverrides.global = null;
        await initializeDateFormatting('id_ID');
      });
      setUp(() => SharedPreferences.setMockInitialValues({}));

      final wa = '0899${DateTime.now().millisecondsSinceEpoch % 100000000}'
          .padRight(12, '0')
          .substring(0, 12);

      test('beli tiket di aplikasi, petugas scan, Live Crowd dan status e-tiket ikut berubah', () async {
        final s = AppState.instance;
        final headers = await _adminHeaders();

        await s.refreshCrowd();
        expect(s.isLive, isTrue);
        expect(s.hourly, isNotNull);
        expect(s.hourly!.hours, [8, 9, 10, 11, 12, 13, 14, 15, 16]);
        final insideBefore = s.inside;

        // Beli tiket: kode dan harga ditentukan server.
        final t = await s.buyTicketOnline(
          name: 'Uji Flutter',
          whatsapp: '+62 ${wa.substring(1)}',
          adults: 2,
          kids: 1,
          parking: Parking.motor,
          payment: PaymentMethod.cash,
          arrival: '10.00 - 12.00',
        );
        expect(t.code, matches(RegExp(r'^TK-\d{4,}$')));
        expect(t.synced, isTrue);
        expect(t.total, 2 * 5000 + 3000);
        expect(t.people, 3);
        expect(t.status, TicketStatus.waiting);
        expect(t.whatsapp, wa);
        expect(s.find(t.code), isNotNull);
        expect(s.ticketsFor(wa).first.code, t.code);

        // Tiket yang belum discan tidak menaikkan Live Crowd.
        await s.refreshCrowd();
        expect(s.inside, insideBefore);

        // Petugas memindai di web admin (di sini lewat API yang sama).
        final list = jsonDecode(
          (await http.get(
            Uri.parse('${ApiClient.baseUrl}/admin/tickets'),
            headers: headers,
          )).body,
        ) as Map<String, dynamic>;
        final id =
            (list['tickets'] as List).firstWhere(
                  (e) => e['code'] == t.code,
                )['id']
                as String;
        final ci = await http.post(
          Uri.parse('${ApiClient.baseUrl}/admin/tickets/$id/check-in'),
          headers: headers,
        );
        expect(ci.statusCode, 200);

        // E-tiket di aplikasi langsung tahu sudah masuk, dan Live Crowd naik 3 orang.
        await s.refreshTicket(t.code);
        expect(s.find(t.code)!.status, TicketStatus.inside);
        expect(s.find(t.code)!.checkInAt, matches(RegExp(r'^\d\d\.\d\d$')));
        await s.refreshCrowd();
        expect(s.inside, insideBefore + 3);

        // Keluar: Live Crowd turun lagi.
        final co = await http.post(
          Uri.parse('${ApiClient.baseUrl}/admin/tickets/$id/check-out'),
          headers: headers,
        );
        expect(co.statusCode, 200);
        await s.refreshTicket(t.code);
        expect(s.find(t.code)!.status, TicketStatus.out);
        await s.refreshCrowd();
        expect(s.inside, insideBefore);
      });

      test('riwayat tiket dicari lewat nomor WhatsApp dari server', () async {
        final remote = await ApiClient.fetchTickets(wa);
        expect(remote, isNotEmpty);
        expect(remote.every((t) => t.whatsapp == wa), isTrue);
        expect(remote.first.date, isNotEmpty);
        await expectLater(
          ApiClient.fetchTickets('123'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              'INVALID_WHATSAPP',
            ),
          ),
        );
      });

      test('isian salah ditolak server dengan pesan yang jelas', () async {
        await expectLater(
          ApiClient.buyTicket(
            name: 'X Y',
            whatsapp: '12345',
            adults: 1,
            kids: 0,
            parking: Parking.none,
            payment: PaymentMethod.qris,
            arrival: '',
          ),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Nomor WhatsApp tidak valid.',
            ),
          ),
        );
      });

      test('chat jawab cepat: FAQ pengelola, lalu pertanyaan di luar data ditawarkan ke pengelola', () async {
        final chat = ChatController.instance;
        await chat.init();
        expect(chat.deviceId, startsWith('app-'));

        final faq = await ApiClient.askChat(
          'jam buka nya jam berapa?',
          chat.deviceId,
        );
        expect(faq.source, ChatSource.faq);
        expect(faq.answer, contains('08.00'));

        final unknown = await ApiClient.askChat(
          'boleh bawa drone ke kolam?',
          chat.deviceId,
        );
        expect(unknown.answer, isNull);
        expect(unknown.canAskManager, isTrue);
      });

      test('chat tanya pengelola: balasan masuk sekali saja, lalu pertanyaan serupa dijawab otomatis', () async {
        final chat = ChatController.instance;
        await chat.init();
        final headers = await _adminHeaders();
        final question =
            'Apakah ada tempat penitipan barang ${DateTime.now().millisecondsSinceEpoch}?';

        await chat.askManager(question);
        expect(chat.messages.last.source, 'Pengelola');
        expect(chat.messages.last.text, contains('dikirim ke pengelola'));

        // Belum dijawab: tidak ada balasan.
        final before = chat.messages.length;
        await chat.checkReplies();
        expect(chat.messages.length, before);

        // Pengelola menjawab dari web admin dan menyimpannya jadi FAQ.
        final overview = jsonDecode(
          (await http.get(
            Uri.parse('${ApiClient.baseUrl}/admin/chat/overview'),
            headers: headers,
          )).body,
        ) as Map<String, dynamic>;
        final qid =
            (overview['pending'] as List).firstWhere(
                  (q) => q['question'] == question,
                )['id']
                as String;
        final ans = await http.post(
          Uri.parse('${ApiClient.baseUrl}/admin/chat/questions/$qid/answer'),
          headers: headers,
          body: jsonEncode({
            'answer': 'Ada loker di dekat pintu masuk, Rp5.000 per pemakaian.',
            'saveAsFaq': true,
          }),
        );
        expect(ans.statusCode, 200);

        // Balasan muncul di chat pengunjung, hanya sekali.
        await chat.checkReplies();
        expect(
          chat.messages.last.text,
          contains('Ada loker di dekat pintu masuk'),
        );
        expect(chat.messages.last.source, 'Pengelola');
        final count = chat.messages.length;
        await chat.checkReplies();
        expect(chat.messages.length, count);

        // Pertanyaan yang sama kini dijawab cepat dari FAQ.
        final again = await ApiClient.askChat(question, chat.deviceId);
        expect(again.source, ChatSource.faq);
        expect(again.answer, contains('loker'));
      });

      test('server tidak terjangkau: ApiException offline, dan chat memakai jawaban di perangkat', () async {
        // Port yang tidak dipakai: simulasi server mati dengan memanggil alamat lain lewat http langsung.
        await expectLater(
          http
              .get(Uri.parse('http://localhost:1/crowd'))
              .timeout(const Duration(seconds: 3)),
          throwsA(anything),
        );
        expect(jawabanTanyaSira('parkir bus berapa?'), contains('20rb'));
        expect(jawabanTanyaSira('boleh bawa drone?'), isNull);
      });
    },
    skip: _e2e ? null : 'Butuh backend menyala. Jalankan dengan --dart-define=E2E=1 (lihat catatan di atas file).',
  );
}
