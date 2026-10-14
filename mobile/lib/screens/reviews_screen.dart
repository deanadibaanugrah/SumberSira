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
      body: AppBackground(
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final s = AppState.instance;
            return ResponsiveBody(children: [
              const PageHeader(title: 'Ulasan & Rating'),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(children: [
                  Text(s.rating.toStringAsFixed(1), style: AppTheme.display(40)),
                  const SizedBox(width: 18),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _starsRow(s.rating.round(), 20),
                    const SizedBox(height: 4),
                    Text('dari ${s.reviewCount} ulasan', style: TextStyle(fontSize: 11, color: AppColors.white(.75))),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              Form(
                key: _formKey,
                child: GlassCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Tulis Ulasan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    // Ketuk bintang untuk memberi nilai 1 sampai 5.
                    Row(children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          tooltip: '$i bintang',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          onPressed: () => setState(() => _stars = i),
                          icon: Icon(i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 30, color: Colors.white),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _text,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Ceritakan pengalamanmu...'),
                      validator: (v) => (v ?? '').trim().length < 10 ? 'Tulis minimal 10 huruf.' : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(width: 160, child: PrimaryButton(label: 'Kirim Ulasan', height: 42, onPressed: _submit)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              Text('Ulasan Terbaru', style: AppTheme.display(17)),
              const SizedBox(height: 10),
              for (final r in s.reviews)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 18, backgroundColor: AppColors.leaf.withValues(alpha: .7), child: Text(r.initial, style: const TextStyle(color: Colors.white))),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          _starsRow(r.stars, 13),
                        ]),
                      ]),
                      const SizedBox(height: 10),
                      Text(r.text, style: TextStyle(fontSize: 12, color: AppColors.white(.8))),
                    ]),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }

  // Deretan 5 bintang: penuh sebanyak nilai, sisanya garis.
  Widget _starsRow(int stars, double size) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++) Icon(i <= stars ? Icons.star_rounded : Icons.star_outline_rounded, size: size, color: Colors.white),
      ]);
}
