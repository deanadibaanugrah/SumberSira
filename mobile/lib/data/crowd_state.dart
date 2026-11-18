import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/live.dart';
import '../models/ticket.dart';
import 'api_client.dart';
import 'app_state.dart';

// Pemilik data Live Crowd (GET /crowd). Layar yang butuh keramaian memanggil startLive() saat tampil
// dan stopLive() saat ditutup; selama ada pemakai, data diambil ulang tiap 30 detik (mulai seketika).
// Bila server tidak terjangkau: angka memakai tiket yang tersimpan di AppState, dan penanda "tidak terbaru"
// menyala bila data server terakhir sudah tidak segar. Widget mendengarkan CrowdState, bukan AppState,
// supaya pembaruan tiap 30 detik tidak membangun ulang layar yang tidak memakai keramaian.
class CrowdState extends ChangeNotifier {
  CrowdState._() {
    // Tanpa data server, angka dihitung dari tiket di AppState.
    AppState.instance.addListener(_onAppStateChanged);
  }
  static final CrowdState instance = CrowdState._();

  CrowdInfo? _info;
  bool _stale = false;
  Timer? _timer;
  int _users = 0;

  // True bila pernah berhasil mengambil data dari server.
  bool get ready => _info != null;

  // True bila angka berasal dari server (bukan data contoh).
  bool get isLive => _info != null;

  // True bila data server terakhir tidak segar lagi: pembaruan gagal (server tidak terjangkau).
  bool get isStale => _stale;

  int get capacity => _info?.capacity ?? AppState.capacity;

  // Jumlah orang di dalam: dari server bila terhubung, kalau tidak dari tiket di AppState
  // yang berstatus Di dalam.
  int get inside =>
      _info?.inside ?? AppState.instance.tickets.where((t) => t.status == TicketStatus.inside).fold(0, (sum, t) => sum + t.people);

  int get percent => _info?.percent ?? min(100, (inside / capacity * 100).round());
  String get crowdLabel => _info?.label ?? labelFor(percent);

  // Prakiraan pengunjung per jam dari server; kosong bila belum pernah terhubung.
  List<({String hour, int count})> get forecast => _info?.forecast ?? const [];

  // Label keramaian dari persen kapasitas, aturan yang sama dengan backend: di bawah 40% Sepi,
  // sampai 75% Sedang, di atasnya Ramai. Dipakai untuk data contoh dan warna batang grafik.
  static String labelFor(int percent) => percent < 40 ? 'Sepi' : (percent <= 75 ? 'Sedang' : 'Ramai');

  // Mengambil data terbaru dari server. Gagal: data terakhir tetap dipakai dan penanda
  // "tidak terbaru" menyala (diberi tahu sekali, bukan tiap percobaan).
  Future<void> refresh() async {
    try {
      final info = await ApiClient.fetchCrowd();
      final berubah = _info == null ||
          _info!.inside != info.inside ||
          _info!.percent != info.percent ||
          _info!.label != info.label ||
          _info!.capacity != info.capacity ||
          !_forecastSama(info.forecast, _info!.forecast);
      _info = info;
      _stale = false;
      if (berubah) notifyListeners();
    } on ApiException {
      // server tidak terjangkau: penanda tidak terbaru
      if (!_stale) {
        _stale = true;
        notifyListeners();
      }
    }
  }

  // Selama ada pemakai, data diambil ulang tiap 30 detik dan langsung saat mulai.
  void startLive() {
    if (++_users != 1) return;
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  void stopLive() {
    if (_users > 0 && --_users == 0) {
      _timer?.cancel();
      _timer = null;
    }
  }

  // Daftar tiket berubah: angka cadangan dihitung ulang saat tampil.
  void _onAppStateChanged() {
    if (!isLive) notifyListeners();
  }

  // Membandingkan isi prakiraan supaya hanya memberi tahu pendengar bila datanya benar-benar berubah.
  static bool _forecastSama(List<({String hour, int count})> a, List<({String hour, int count})> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].hour != b[i].hour || a[i].count != b[i].count) return false;
    }
    return true;
  }
}
