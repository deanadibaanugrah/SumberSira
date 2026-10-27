import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';

// Ulasan & Rating: ringkasan bintang, form tulis ulasan, dan daftar ulasan terbaru.
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
      appBar: const PageAppBar(title: 'Ulasan & Rating'),
      body: AppBackground(
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final s = AppState.instance;
            return ResponsiveBody(children: [
              // Ringkasan rating di kartu hijau tua.
              AppCard(
                color: AppColors.forest,
                borderColor: AppColors.forest,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Row(children: [
                  Text(s.rating.toStringAsFixed(1), style: AppTheme.display(46, color: Colors.white)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _starsRow(s.rating.round(), 24),
                      const SizedBox(height: 6),
                      Text('dari ${s.reviewCount} ulasan', style: TextStyle(fontSize: 13, color: AppColors.white(.8))),
                    ]),
                  ),
                ]),
              ),
              const SectionLabel('Tulis Ulasan'),
              Form(
                key: _formKey,
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Beri nilai kunjunganmu', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    // Ketuk bintang untuk memberi nilai 1 sampai 5.
                    Row(children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          tooltip: '$i bintang',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          onPressed: () => setState(() => _stars = i),
                          icon: Icon(i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 36, color: i <= _stars ? AppColors.sun : AppColors.pale),
                        ),
                    ]),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _text,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(hintText: 'Ceritakan pengalamanmu...'),
                      validator: (v) => (v ?? '').trim().length < 10 ? 'Tulis minimal 10 huruf.' : null,
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(label: 'Kirim Ulasan', icon: Icons.send_rounded, height: 48, onPressed: _submit),
                  ]),
                ),
              ),
              const SectionTitle('Ulasan Terbaru'),
              for (final r in s.reviews)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.pale,
                          child: Text(r.initial, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.forest)),
                        ),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          _starsRow(r.stars, 16),
                        ]),
                      ]),
                      const SizedBox(height: 10),
                      Text(r.text, style: const TextStyle(fontSize: 13.5, height: 1.45)),
                    ]),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }

  // Deretan 5 bintang kuning: penuh sebanyak nilai, sisanya garis.
  Widget _starsRow(int stars, double size) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++) Icon(i <= stars ? Icons.star_rounded : Icons.star_outline_rounded, size: size, color: AppColors.sun),
      ]);
}
