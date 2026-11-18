import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/api_client.dart';
import '../../../data/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/common.dart';

// Ulasan & Rating: ringkasan nilai (angka hero), form tulis ulasan, dan daftar ulasan terbaru.
// Data daftar dan rata-rata berasal dari backend (GET /reviews); ulasan baru dikirim lewat POST /reviews.
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
  // State: jumlah bintang yang dipilih di form (1 sampai 5), dan penanda sedang mengirim.
  int _stars = 5;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Muat ulasan dari server saat layar dibuka.
    AppState.instance.refreshReviews();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  // Kirim ulasan ke server: isi minimal 10 huruf, lalu daftar dan rata-rata dimuat ulang dari server.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _sending) return;
    setState(() => _sending = true);
    try {
      await AppState.instance.submitReview(stars: _stars, text: _text.text.trim());
      if (!mounted) return;
      _text.clear();
      FocusScope.of(context).unfocus();
      setState(() => _stars = 5);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih, ulasanmu sudah terkirim!')));
    } on ApiException catch (e) {
      // Pesan Indonesia dari ApiClient (mis. terlalu banyak percobaan atau server tidak terjangkau).
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
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
              // Ringkasan rating: angka hero dan bintang, dari server.
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Row(children: [
                  Text(s.reviewsReady ? s.reviewRating.toStringAsFixed(1) : '–', style: AppText.hero(56)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _starsRow(s.reviewRating.round(), 22),
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
                          onPressed: _sending ? null : () => setState(() => _stars = i),
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
                    PrimaryButton(label: 'Kirim Ulasan', icon: CupertinoIcons.paperplane_fill, loading: _sending, onPressed: _submit),
                  ]),
                ),
              ),
              const SectionTitle('Ulasan Terbaru'),
              GroupedList(
                indent: 68,
                footer: s.reviews.isNotEmpty && s.reviewsError != null ? 'Menampilkan data terakhir. ${s.reviewsError}' : null,
                children: [
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
                  // Status memuat, galat, dan kosong memakai gaya baris daftar yang sudah ada.
                  if (s.reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Column(children: [
                        Text(
                          s.reviewsLoading
                              ? 'Memuat ulasan...'
                              : s.reviewsError != null
                                  ? 'Tidak dapat terhubung ke server.'
                                  : 'Belum ada ulasan.',
                          textAlign: TextAlign.center,
                          style: AppText.footnote,
                        ),
                        if (!s.reviewsLoading && s.reviewsError != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => AppState.instance.refreshReviews(),
                            icon: const Icon(CupertinoIcons.refresh, size: 18),
                            label: const Text('Coba lagi'),
                          ),
                        ],
                      ]),
                    ),
                ],
              ),
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
