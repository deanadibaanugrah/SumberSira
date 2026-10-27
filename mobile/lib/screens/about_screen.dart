import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/common.dart';
import '../widgets/logo_mark.dart';

// Layar Tentang Sumber Sira: tampil setelah Splash saat aplikasi pertama kali dibuka,
// dan bisa dibuka lagi dari menu cepat Beranda. Lanjut = ke Onboarding, Lewati = langsung ke Beranda.
// Tata letak seperti halaman detail destinasi: foto besar berjudul di atas, lalu lembar isi
// berisi deskripsi, kartu foto daya tarik, dan kotak info kunjungan.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Lewati perkenalan: tandai onboarding selesai lalu buka Beranda dan hapus riwayat layar sebelumnya.
  void _skip(BuildContext context) {
    AppState.instance.finishOnboarding();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Daya tarik beserta foto yang paling mewakili (foto yang sama dengan Galeri).
    const features = [
      (Icons.water_drop_outlined, 'Air jernih', 'assets/images/onboarding-air-jernih.jpg'),
      (Icons.set_meal_outlined, 'Ikan wader', 'assets/images/onboarding-bawah-air.jpg'),
      (Icons.pool_rounded, 'Kolam anak', 'assets/images/komunitas-2.jpg'),
      (Icons.cottage_outlined, 'Gazebo', 'assets/images/hero-sawah.jpg'),
    ];
    const info = [
      (Icons.schedule_rounded, 'Jam buka', 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
      (Icons.confirmation_number_outlined, 'Tiket masuk', 'Rp5.000 per orang (usia 3 tahun ke atas)'),
      (Icons.directions_car_outlined, 'Parkir', 'Motor 3rb · Mobil 10rb · Bus 20rb'),
      (Icons.account_balance_wallet_outlined, 'Pembayaran', 'Tunai & QRIS'),
    ];
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(padding: EdgeInsets.zero, children: [
              // [P3 Stack + Positioned] Bar atas, judul, dan label ditumpuk di atas foto.
              SizedBox(
                height: 400 + top,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/sawah-sumber-sira.jpg', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.ink.withValues(alpha: .55), Colors.transparent, AppColors.ink.withValues(alpha: .2), AppColors.forest.withValues(alpha: .92)],
                        stops: const [0, .28, .5, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 16,
                    top: top + 12,
                    child: Row(children: [
                      const LogoMark(size: 36, ring: true),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Sumber Sira', style: AppTheme.display(19, color: Colors.white))),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.white(.18),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: StadiumBorder(side: BorderSide(color: AppColors.white(.3))),
                        ),
                        onPressed: () => _skip(context),
                        child: const Text('Lewati', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 50,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _glassChip(Icons.place_rounded, 'Desa Putukrejo, Malang'),
                      const SizedBox(height: 12),
                      Text('Tentang Sumber Sira', style: AppTheme.display(32, color: Colors.white)),
                      const SizedBox(height: 12),
                      _glassChip(Icons.groups_outlined, 'Dikelola masyarakat Desa Putukrejo'),
                    ]),
                  ),
                ]),
              ),
              // Lembar isi yang sedikit menumpuk di atas foto.
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    // Deskripsi dengan garis aksen hijau di kiri.
                    Container(
                      padding: const EdgeInsets.only(left: 14),
                      decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.leaf, width: 3))),
                      child: const Text('Kolam mata air alami yang jernih dan sejuk, seru buat berenang, main air, dan foto bareng keluarga.',
                          style: TextStyle(fontSize: 15.5, color: AppColors.ink, height: 1.55)),
                    ),
                    const SectionTitle('Daya Tarik'),
                    for (var row = 0; row < features.length; row += 2) ...[
                      if (row > 0) const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _featureCard(features[row])),
                        const SizedBox(width: 12),
                        Expanded(child: _featureCard(features[row + 1])),
                      ]),
                    ],
                    const SectionTitle('Info Kunjungan'),
                    for (var row = 0; row < info.length; row += 2) ...[
                      if (row > 0) const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Expanded(child: _infoTile(info[row])),
                          const SizedBox(width: 12),
                          Expanded(child: _infoTile(info[row + 1])),
                        ]),
                      ),
                    ],
                  ]),
                ),
              ),
            ]),
          ),
        ),
        // [P5 Navigator.pushReplacementNamed] Ganti layar ini dengan Onboarding (tidak bisa kembali ke sini).
        bottomNavigationBar: BottomBar(
          child: PrimaryButton(label: 'Lanjut', onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.onboarding)),
        ),
      ),
    );
  }

  // Label kaca di atas foto (lokasi dan pengelola).
  Widget _glassChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white(.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white(.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white))),
        ]),
      );

  // Kartu foto daya tarik: foto, gradasi gelap di bawah, ikon dalam lingkaran putih, dan nama.
  Widget _featureCard((IconData, String, String) f) {
    final (icon, label, image) = f;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 124,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(image, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.ink.withValues(alpha: .75)],
                stops: const [.35, 1],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Row(children: [
              IconBadge(icon, size: 32, circle: true, background: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
            ]),
          ),
        ]),
      ),
    );
  }

  // Kotak info kunjungan: ikon, judul, dan keterangan.
  Widget _infoTile((IconData, String, String) i) {
    final (icon, title, text) = i;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconBadge(icon, size: 38),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.35)),
      ]),
    );
  }
}
