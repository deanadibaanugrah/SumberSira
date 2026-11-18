import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumber_sira/data/api_client.dart';
import 'package:sumber_sira/data/app_state.dart';
import 'package:sumber_sira/features/chat/viewmodel/chat_controller.dart';
import 'package:sumber_sira/features/crowd/viewmodel/crowd_state.dart';
import 'package:sumber_sira/models/ticket.dart';

// Uji ke backend sungguhan (bukan tiruan): beli tiket, scan petugas, Live Crowd, dan chat Tanya Sira.
// Hanya jalan bila backend menyala dan tes dijalankan dengan:
//   flutter test --dart-define=API_URL=http://localhost:4100 --dart-define=E2E=1 test/backend_e2e_test.dart
// Tanpa E2E=1 tes ini dilewati, jadi `flutter test` biasa tetap tidak butuh server.
const _e2e = String.fromEnvironment('E2E') == '1';

// Akun awal dari seed backend (hanya untuk lingkungan lokal).
Future<Map<String, String>> _login(String email, String password) async {
  final res = await http.post(
    Uri.parse('${ApiClient.baseUrl}/auth/login'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );
  expect(res.statusCode, 200);
  final cookie = res.headers['set-cookie']!.split(';').first;
  return {'content-type': 'application/json', 'cookie': cookie};
}

// Petugas loket: cukup untuk tiket, booking, dan pembayaran.
Future<Map<String, String>> _adminHeaders() =>
    _login('petugas@sumbersira.id', 'petugas123');

// Pengelola (admin): untuk FAQ, ulasan, galeri, dan insight.
Future<Map<String, String>> _pengelolaHeaders() =>
    _login('admin@sumbersira.id', 'sumbersira');

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
        final c = CrowdState.instance;
        final headers = await _adminHeaders();

        // Prakiraan per jam dari server: jam 08 sampai 16.
        await c.refresh();
        expect(c.isLive, isTrue);
        expect(c.forecast.map((f) => f.hour), [
          '08',
          '09',
          '10',
          '11',
          '12',
          '13',
          '14',
          '15',
          '16',
        ]);
        final insideBefore = c.inside;

        // Tarif dibaca dari server, bukan angka di aplikasi.
        final pricing = await ApiClient.fetchPricing();

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
        expect(
          t.total,
          2 * pricing.ticketPricePerPerson +
              (pricing.tarif(Parking.motor) ?? 0),
        );
        expect(t.people, 3);
        expect(t.status, TicketStatus.waiting);
        expect(t.whatsapp, wa);
        expect(s.find(t.code), isNotNull);
        expect(s.ticketsFor(wa).first.code, t.code);

        // Tiket yang belum discan tidak menaikkan Live Crowd.
        await c.refresh();
        expect(c.inside, insideBefore);

        // Petugas mengonfirmasi pembayaran tunai di loket, baru tiket boleh discan masuk.
        final bayar = await http.post(
          Uri.parse(
            '${ApiClient.baseUrl}/admin/tickets/${t.code}/confirm-cash',
          ),
          headers: headers,
        );
        expect(bayar.statusCode, 200);

        // Petugas memindai di web admin (di sini lewat API yang sama).
        final list = jsonDecode(
          (await http.get(
            Uri.parse('${ApiClient.baseUrl}/admin/tickets'),
            headers: headers,
          )).body,
        ) as Map<String, dynamic>;
        final ketemu = (list['items'] as List).any((e) => e['code'] == t.code);
        expect(
          ketemu,
          isTrue,
          reason: 'tiket baru harus muncul di daftar admin',
        );
        final ci = await http.post(
          Uri.parse('${ApiClient.baseUrl}/admin/tickets/${t.code}/check-in'),
          headers: headers,
        );
        expect(ci.statusCode, 200);

        // E-tiket di aplikasi langsung tahu sudah masuk, dan Live Crowd naik 3 orang.
        await s.refreshTicket(t.code);
        expect(s.find(t.code)!.status, TicketStatus.inside);
        expect(s.find(t.code)!.checkInAt, matches(RegExp(r'^\d\d\.\d\d$')));
        await c.refresh();
        expect(c.inside, insideBefore! + 3);

        // Keluar: Live Crowd turun lagi.
        final co = await http.post(
          Uri.parse('${ApiClient.baseUrl}/admin/tickets/${t.code}/check-out'),
          headers: headers,
        );
        expect(co.statusCode, 200);
        await s.refreshTicket(t.code);
        expect(s.find(t.code)!.status, TicketStatus.out);
        await c.refresh();
        expect(c.inside, insideBefore);
      });

      test('riwayat tiket dicari lewat nomor WhatsApp dari server', () async {
        final remote = await ApiClient.fetchTickets(wa);
        expect(remote, isNotEmpty);
        expect(remote.every((t) => t.whatsapp == wa), isTrue);
        expect(remote.first.date, isNotEmpty);
        // Nomor tidak valid tidak membuat galat: backend membalas daftar kosong.
        expect(await ApiClient.fetchTickets('123'), isEmpty);
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
            isA<ApiException>().having((e) => e.code, 'code', 'VALIDATION'),
          ),
        );
      });

      test(
        'booking sewa dibuat di server lalu QRIS dibayar (mode simulasi)',
        () async {
          final rides = await ApiClient.fetchWahana();
          final slots = await ApiClient.fetchBookingSlots();
          expect(rides, isNotEmpty);
          expect(slots, isNotEmpty);

          final ride = rides.first;
          final booking = await ApiClient.createBooking(
            name: 'Uji Booking',
            whatsapp: wa,
            slot: slots.first.id,
            items: [(rideId: ride.id, qty: 2)],
          );
          expect(booking.code, matches(RegExp(r'^SS-\d{8}-\d{3}$')));
          expect(booking.amount, ride.price * 2);
          expect(booking.lines.single.qty, 2);
          expect(booking.paymentStatus, PaymentStatus.pending);
          expect(booking.paymentId, isNotNull);

          // QRIS baru dibuat: masih menunggu dan punya teks QR untuk dipindai.
          final awal = await ApiClient.fetchPayment(booking.paymentId!);
          expect(awal.status, 'pending');
          expect(
            awal.qrString,
            isNotNull,
            reason: 'mode simulasi selalu memberi teks QR',
          );
          expect(awal.simulasi, isTrue);

          // Mode simulasi: server menandai lunas, lalu booking ikut berubah.
          final lunas = await ApiClient.simulatePayment(awal.id);
          expect(lunas.status, 'paid');

          final terbaru = await ApiClient.fetchBooking(booking.code, wa);
          expect(terbaru.paymentStatus, PaymentStatus.paid);
          final daftar = await ApiClient.fetchBookings(wa);
          expect(daftar.map((b) => b.code), contains(booking.code));
        },
      );

      test(
        'tiket QRIS: QR dari server, lunas setelah simulasi bayar',
        () async {
          final t = await ApiClient.buyTicket(
            name: 'Uji QRIS',
            whatsapp: wa,
            adults: 1,
            kids: 0,
            parking: Parking.none,
            payment: PaymentMethod.qris,
            arrival: '10.00 - 12.00',
          );
          expect(t.paymentStatus, PaymentStatus.pending);
          expect(t.paymentId, isNotNull);

          final p = await ApiClient.fetchPayment(t.paymentId!);
          expect(p.qrString, isNotNull);
          expect(p.simulasi, isTrue);

          await ApiClient.simulatePayment(p.id);
          final terbaru = await ApiClient.fetchTicket(t.code, wa);
          expect(terbaru.paymentStatus, PaymentStatus.paid);
        },
      );

      test('chat: pertanyaan cocok dijawab FAQ, yang tidak cocok dicatat untuk admin', () async {
        final chat = ChatController.instance;
        await chat.init();
        expect(chat.quickQuestions, isNotEmpty);

        final faq = await ApiClient.askChat('jam buka nya jam berapa?');
        expect(faq.matched, isTrue);
        expect(faq.answer, contains('08.00'));

        final unknown = await ApiClient.askChat('boleh bawa drone ke kolam?');
        expect(unknown.matched, isFalse);
        expect(unknown.answer, isNotEmpty);
      });

      test('pertanyaan tak cocok tampil di admin; dibuat FAQ lalu pertanyaan dihapus', () async {
        final headers = await _pengelolaHeaders();
        final question =
            'Apakah ada tempat penitipan barang ${DateTime.now().millisecondsSinceEpoch}?';

        final unknown = await ApiClient.askChat(question);
        expect(unknown.matched, isFalse);

        // Pertanyaan tercatat di daftar belum terjawab.
        final daftar = await http.get(
          Uri.parse('${ApiClient.baseUrl}/admin/faq/unanswered'),
          headers: headers,
        );
        expect(daftar.statusCode, 200);
        final items = jsonDecode(daftar.body) as List;
        final item = items.firstWhere(
          (q) => q['question'] == question,
        ) as Map<String, dynamic>;
        final id = item['id'] as String;

        // "Jawab" = buat FAQ baru, lalu hapus pertanyaan itu dari daftar.
        final buat = await http.post(
          Uri.parse('${ApiClient.baseUrl}/admin/faq'),
          headers: headers,
          body: jsonEncode({
            // Backend membatasi kata kunci maksimal 30 karakter, jadi pakai frasa pendek.
            'keys': ['penitipan barang', 'loker'],
            'answer': 'Ada loker di dekat pintu masuk, Rp5.000 per pemakaian.',
            'sortOrder': 99,
            'active': true,
          }),
        );
        expect(buat.statusCode, 201);
        final faq = jsonDecode(buat.body) as Map<String, dynamic>;

        final hapus = await http.delete(
          Uri.parse('${ApiClient.baseUrl}/admin/faq/unanswered/$id'),
          headers: headers,
        );
        expect(hapus.statusCode, 200);

        // Pertanyaan serupa kini dijawab dari FAQ baru.
        final again = await ApiClient.askChat('apakah ada penitipan barang?');
        expect(again.matched, isTrue);
        expect(again.answer, contains('loker'));

        // Bersihkan FAQ uji agar data backend tidak menumpuk.
        await http.delete(
          Uri.parse('${ApiClient.baseUrl}/admin/faq/${faq['id']}'),
          headers: headers,
        );
      });

      test(
        'server tidak terjangkau: permintaan langsung melempar galat',
        () async {
          // Port yang tidak dipakai: simulasi server mati dengan memanggil alamat lain lewat http langsung.
          await expectLater(
            http
                .get(Uri.parse('http://localhost:1/crowd'))
                .timeout(const Duration(seconds: 3)),
            throwsA(anything),
          );
        },
      );
    },
    skip: _e2e ? null : 'Butuh backend menyala. Jalankan dengan --dart-define=E2E=1 (lihat catatan di atas file).',
  );
}
