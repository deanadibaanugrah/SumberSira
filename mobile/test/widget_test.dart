import 'package:flutter_test/flutter_test.dart';
import 'package:sumber_sira/data/app_state.dart';
import 'package:sumber_sira/models/ticket.dart';
import 'package:sumber_sira/utils/format.dart';
import 'package:sumber_sira/utils/validators.dart';

// Uji fungsi-fungsi penting: format Rupiah, validasi form, login simulasi, dan Live Crowd.
void main() {
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

  test('login demo, beli tiket, lalu scan menaikkan Live Crowd', () {
    final s = AppState.instance;
    expect(s.login('pengunjung@sumbersira.id', 'salah'), isFalse);
    expect(s.login('pengunjung@sumbersira.id', 'sira123'), isTrue);
    expect(s.inside, 186);
    final t = s.buyTicket(name: 'Rani', whatsapp: '081234567890', adults: 2, kids: 0, parking: Parking.motor);
    expect(t.total, 13000);
    s.checkIn(t.code);
    expect(s.inside, 188);
  });
}
