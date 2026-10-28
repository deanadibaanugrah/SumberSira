import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';
import '../widgets/logo_mark.dart';

// Layar Tentang Sumber Sira: tampil setelah Splash saat aplikasi pertama kali dibuka,
// dan bisa dibuka lagi dari menu cepat Beranda. Lanjut = ke Onboarding, Lewati = langsung ke Beranda.
// Tata letak seperti halaman detail destinasi: foto besar (hero) dengan panel kaca, lalu lembar isi
// berisi deskripsi, carousel daya tarik, dan list info kunjungan.
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
      (CupertinoIcons.drop, 'Air jernih', 'assets/images/onboarding-air-jernih.jpg'),
      (Icons.set_meal_outlined, 'Ikan wader', 'assets/images/onboarding-bawah-air.jpg'),
      (Icons.pool_outlined, 'Kolam anak', 'assets/images/komunitas-2.jpg'),
      (Icons.cottage_outlined, 'Gazebo', 'assets/images/hero-sawah.jpg'),
    ];
    const info = [
      (CupertinoIcons.clock, 'Jam buka', 'Weekday 08.00-16.00 · Weekend s/d 17.00'),
      (CupertinoIcons.ticket, 'Tiket masuk', 'Rp5.000 per orang (usia 3 tahun ke atas)'),
      (CupertinoIcons.car_detailed, 'Parkir', 'Motor 3rb · Mobil 10rb · Bus 20rb'),
      (CupertinoIcons.creditcard, 'Pembayaran', 'Tunai & QRIS'),
    ];
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.abuMuda,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24), children: [
              // [P3 Stack + Positioned] Bar atas dan panel judul kaca ditumpuk di atas foto.
              SizedBox(
                height: 420 + top,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/sawah-sumber-sira.jpg', fit: BoxFit.cover),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: top + 10,
                    child: Row(children: [
                      // Logo apa adanya di atas kapsul kaca, dengan ruang kosong 25% tinggi logo di sekelilingnya.
                      Glass(
                        radius: 27,
                        shadow: false,
                        padding: const EdgeInsets.fromLTRB(9, 9, 16, 9),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const LogoMark(size: 36, ring: true),
                          const SizedBox(width: 10),
                          Text('Sumber Sira', style: AppText.headline.copyWith(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      const Spacer(),
                      Pressable(
                        onTap: () => _skip(context),
                        semanticLabel: 'Lewati',
                        child: Glass(
                          radius: 22,
                          shadow: false,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          child: Text('Lewati', style: AppText.subheadline.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ]),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 44,
                    child: Glass(
                      radius: 24,
                      shadow: false,
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Row(children: [
                          const Icon(CupertinoIcons.location_solid, size: 14, color: AppColors.leaf),
                          const SizedBox(width: 5),
                          Text('Desa Putukrejo, Malang', style: AppText.footnote.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 6),
                        Text('Tentang Sumber Sira', style: AppText.title2.copyWith(fontSize: 30, height: 36 / 30)),
                        const SizedBox(height: 4),
                        const Text('Dikelola masyarakat Desa Putukrejo', style: AppText.footnote),
                      ]),
                    ),
                  ),
                ]),
              ),
              // Lembar isi yang sedikit menumpuk di atas foto.
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  padding: const EdgeInsets.only(top: 26),
                  decoration: const BoxDecoration(color: AppColors.abuMuda, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpace.margin),
                      child: Text('Kolam mata air alami yang jernih dan sejuk, seru buat berenang, main air, dan foto bareng keluarga.', style: AppText.body),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpace.margin), child: SectionTitle('Daya Tarik')),
                    // Carousel daya tarik: kartu foto yang bisa digeser ke samping.
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpace.margin),
                        itemCount: features.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _featureCard(features[i]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.margin),
                      child: GroupedList(header: 'Info kunjungan', top: AppSpace.section, children: [
                        for (final (icon, title, text) in info) ListRow(icon: icon, title: title, subtitle: text),
                      ]),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        // [P5 Navigator.pushReplacementNamed] Ganti layar ini dengan Onboarding (tidak bisa kembali ke sini).
        bottomNavigationBar: FloatingBar(
          padding: const EdgeInsets.all(8),
          child: PrimaryButton(label: 'Lanjut', glass: true, onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.onboarding)),
        ),
      ),
    );
  }

  // Kartu foto daya tarik: foto dan nama di panel kaca.
  Widget _featureCard((IconData, String, String) f) {
    final (icon, label, image) = f;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 150,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(image, fit: BoxFit.cover),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Glass(
              radius: 14,
              shadow: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(children: [
                Icon(icon, size: 16, color: AppColors.leaf),
                const SizedBox(width: 6),
                Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.footnote.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600))),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
