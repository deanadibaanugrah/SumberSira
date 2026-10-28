import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Ulasan & Rating: ringkasan nilai (angka hero), form tulis ulasan, dan daftar ulasan terbaru.
// [Rencana AI] Ulasan ini nanti dirangkum AI menjadi sentimen dan topik keluhan di web admin.
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
  // State: jumlah bintang yang dipilih di form (1 sampai 5).
  int _stars = 5;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  // Kirim ulasan: isi minimal 10 huruf, lalu tambahkan ke daftar paling atas.
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final s = AppState.instance;
    final name = s.myTickets.isNotEmpty ? s.myTickets.first.name : 'Pengunjung';
    s.addReview(Review(name: name, stars: _stars, text: _text.text.trim()));
    _text.clear();
    FocusScope.of(context).unfocus();
    setState(() => _stars = 5);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih, ulasanmu sudah terkirim!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(title: 'Ulasan & Rating'),
      body: AppBackground(
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final s = AppState.instance;
            return ResponsiveBody(children: [
              // Ringkasan rating: angka hero dan bintang.
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Row(children: [
                  Text(s.rating.toStringAsFixed(1), style: AppText.hero(56)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _starsRow(s.rating.round(), 22),
                      const SizedBox(height: 6),
                      Text('dari ${s.reviewCount} ulasan', style: AppText.footnote),
                    ]),
                  ),
                ]),
              ),
              const SectionLabel('Tulis ulasan'),
              Form(
                key: _formKey,
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Beri nilai kunjunganmu', style: AppText.footnote),
                    const SizedBox(height: 4),
                    // Ketuk bintang untuk memberi nilai 1 sampai 5.
                    Row(children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          tooltip: '$i bintang',
                          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                          padding: EdgeInsets.zero,
                          onPressed: () => setState(() => _stars = i),
                          icon: Icon(i <= _stars ? CupertinoIcons.star_fill : CupertinoIcons.star, size: 32, color: i <= _stars ? AppColors.leaf : AppColors.leaf30),
                        ),
                    ]),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _text,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(hintText: 'Ceritakan pengalamanmu...', fillColor: AppColors.abuMuda),
                      validator: (v) => (v ?? '').trim().length < 10 ? 'Tulis minimal 10 huruf.' : null,
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(label: 'Kirim Ulasan', icon: CupertinoIcons.paperplane_fill, onPressed: _submit),
                  ]),
                ),
              ),
              const SectionTitle('Ulasan Terbaru'),
              GroupedList(indent: 68, children: [
                for (final r in s.reviews)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(radius: 20, backgroundColor: AppColors.leaf12, child: Text(r.initial, style: AppText.headline.copyWith(color: AppColors.forest))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(r.name, style: AppText.headline)),
                            _starsRow(r.stars, 13),
                          ]),
                          const SizedBox(height: 4),
                          Text(r.text, style: AppText.subheadline.copyWith(color: AppColors.ink, height: 1.4)),
                        ]),
                      ),
                    ]),
                  ),
              ]),
            ]);
          },
        ),
      ),
    );
  }

  // Deretan 5 bintang Hijau Daun: penuh sebanyak nilai, sisanya garis Hijau Daun 30%.
  Widget _starsRow(int stars, double size) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++) Icon(i <= stars ? CupertinoIcons.star_fill : CupertinoIcons.star, size: size, color: i <= stars ? AppColors.leaf : AppColors.leaf30),
      ]);
}
