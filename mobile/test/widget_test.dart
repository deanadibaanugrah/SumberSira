import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumber_sira/data/app_state.dart';
import 'package:sumber_sira/data/dummy_data.dart';
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

  test('nomor WhatsApp beda format dianggap sama', () {
    expect(nomorWa('+62 812-3456-7890'), '081234567890');
    expect(nomorWa('6281234567890'), '081234567890');
    expect(nomorWaInternasional('0812 3456 7890'), '6281234567890');
  });

  test('beli tiket lalu scan menaikkan Live Crowd', () {
    final s = AppState.instance;
    expect(s.inside, 186);
    final t = s.buyTicket(name: 'Rani', whatsapp: '081211112222', adults: 2, kids: 0, parking: Parking.motor);
    expect(t.total, 13000);
    s.checkIn(t.code);
    expect(s.inside, 188);
  });

  test('riwayat tiket dan booking dicari lewat nomor WhatsApp', () {
    final s = AppState.instance;
    final before = s.ticketsFor('081299998888').length;
    final t = s.buyTicket(name: 'Dewi', whatsapp: '+62 812-9999-8888', adults: 1, kids: 0, parking: Parking.none);
    expect(s.ticketsFor('081299998888').first.code, t.code);
    expect(s.ticketsFor('081299998888').length, before + 1);
    expect(s.ticketsFor('080000000000'), isEmpty);

    final draft = BookingDraft(slot: '08-09', lines: const [BookingLine(name: 'Ban Besar', qty: 2, price: 10000), BookingLine(name: 'ATV', qty: 1, price: 25000)]);
    final b = s.addBooking(BookingRequest(draft: draft, name: 'Dewi', whatsapp: '6281299998888'));
    expect(b.total, 45000);
    expect(b.itemsText, '2x Ban Besar, 1x ATV');
    expect(s.bookingsFor('081299998888').single.code, b.code);
  });

  test('jam booking selang 1 jam dan label keramaian', () {
    expect(DummyData.bookingSlots.length, 8);
    expect(labelJam(DummyData.bookingSlots.first), '08.00 - 09.00');
    expect(AppState.labelFor(10), 'Sepi');
    expect(AppState.labelFor(62), 'Sedang');
    expect(AppState.labelFor(95), 'Ramai');
  });

  test('tiket bisa disimpan lalu dibaca lagi (JSON)', () {
    final t = Ticket(code: 'TK-2000', name: 'Rani', whatsapp: '081234567890', adults: 3, parking: Parking.mobil, boughtAt: '10.00');
    final copy = Ticket.fromJson(t.toJson());
    expect(copy.code, 'TK-2000');
    expect(copy.total, t.total);
    expect(copy.parking, Parking.mobil);
  });
}
