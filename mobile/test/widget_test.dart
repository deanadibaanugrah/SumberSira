import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumber_sira/data/app_state.dart';
import 'package:sumber_sira/features/crowd/viewmodel/crowd_state.dart';
import 'package:sumber_sira/models/booking.dart';
import 'package:sumber_sira/models/ticket.dart';
import 'package:sumber_sira/utils/format.dart';
import 'package:sumber_sira/utils/validators.dart';

// Uji fungsi-fungsi penting: format Rupiah, validasi form, Live Crowd, dan riwayat per WhatsApp.
void main() {
  // Penyimpanan perangkat palsu supaya shared_preferences bisa dipakai saat tes.
  setUp(() => SharedPreferences.setMockInitialValues({}));
  // Data tanggal Bahasa Indonesia, sama seperti di main().
  setUpAll(() => initializeDateFormatting('id_ID'));

  test('format Rupiah', () {
    expect(rupiah(5000), 'Rp5.000');
    expect(rupiah(1250000), 'Rp1.250.000');
  });

  test('validasi WhatsApp dan email', () {
    expect(Validators.whatsapp('081234567890'), isNull);
    expect(Validators.whatsapp('12345'), isNotNull);
    expect(Validators.email('a@b.co'), isNull);
    expect(Validators.email('salah'), isNotNull);
  });

  test('email wajib @ dan titik, karakter seperti ( : & " \' ditolak', () {
    expect(Validators.email('admin@sumbersira.id'), isNull);
    expect(Validators.email('kel.hidayat_01@mail.co.id'), isNull);
    expect(Validators.email('adminsumbersira.id'), 'Email harus memakai tanda @.');
    expect(Validators.email('admin@sumbersira'), 'Bagian setelah @ harus memakai titik, contoh: nama@sumbersira.id.');
    for (final salah in ['ad(min)@sumbersira.id', 'admin:1@sumbersira.id', 'a&b@sumbersira.id', '"admin"@sumbersira.id', "admin'@sumbersira.id", 'ad min@sumbersira.id']) {
      expect(Validators.email(salah), contains('hanya boleh berisi huruf, angka'), reason: salah);
    }
    expect(Validators.email('admin@@sumbersira.id'), 'Email hanya boleh punya satu tanda @.');
    expect(Validators.email('admin..sira@sumbersira.id'), isNotNull);
    expect(Validators.email('.admin@sumbersira.id'), isNotNull);
  });

  test('nomor WhatsApp beda format dianggap sama', () {
    expect(nomorWa('+62 812-3456-7890'), '081234567890');
    expect(nomorWa('6281234567890'), '081234567890');
    expect(nomorWaInternasional('0812 3456 7890'), '6281234567890');
  });

  test('total tiket memakai angka dari server, bukan harga bawaan', () {
    final t = Ticket(code: 'TK-2001', name: 'Rani', whatsapp: '081211112222', adults: 2, parking: Parking.motor, boughtAt: '10.00', amount: 13000);
    expect(t.total, 13000);
    expect(t.people, 2);
    // Respons tanpa total tidak ditebak memakai harga lokal.
    final tanpaTotal = Ticket(code: 'TK-2002', name: 'Rani', adults: 1, boughtAt: '10.00');
    expect(tanpaTotal.total, isNull);
  });

  test('riwayat tiket dan booking dicari lewat nomor WhatsApp', () {
    final s = AppState.instance;
    final before = s.ticketsFor('081299998888').length;
    final t = Ticket(code: 'TK-3001', name: 'Dewi', whatsapp: nomorWa('+62 812-9999-8888'), adults: 1, parking: Parking.none, boughtAt: '10.00', mine: true);
    s.tickets.add(t);
    expect(s.ticketsFor('081299998888').first.code, t.code);
    expect(s.ticketsFor('081299998888').length, before + 1);
    expect(s.ticketsFor('080000000000'), isEmpty);
    expect(s.myTickets.first.code, t.code);

    final b = Booking(
      code: 'SS-20261115-001',
      name: 'Dewi',
      whatsapp: nomorWa('6281299998888'),
      slot: '08-09',
      lines: const [BookingLine(name: 'Ban Besar', qty: 2, price: 10000), BookingLine(name: 'ATV', qty: 1, price: 25000)],
      orderedAt: '10.00',
    );
    s.bookings.add(b);
    expect(b.total, 45000);
    expect(b.itemsText, '2x Ban Besar, 1x ATV');
    expect(s.bookingsFor('081299998888').single.code, b.code);
  });

  test('label jam booking dan label keramaian', () {
    expect(labelJam('08-09'), '08.00 - 09.00');
    expect(CrowdState.labelFor(10), 'Sepi');
    expect(CrowdState.labelFor(62), 'Sedang');
    expect(CrowdState.labelFor(95), 'Ramai');
  });
}
