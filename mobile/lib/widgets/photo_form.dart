import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common.dart';

// Isian judul dan nama pengirim untuk foto yang akan diunggah ke galeri.
typedef PhotoDetails = ({String title, String owner});

// Form kecil di lembar kaca, dipakai galeri dan AI Photo saat mengirim foto.
// Ditutup dengan Navigator.pop(context, (title: ..., owner: ...)).
class PhotoForm extends StatefulWidget {
  const PhotoForm({super.key, required this.heading, required this.hint, required this.ownerAwal, this.buttonLabel = 'Unggah Foto'});

  final String heading;
  final String hint;
  final String ownerAwal;
  final String buttonLabel;

  @override
  State<PhotoForm> createState() => _PhotoFormState();
}

class _PhotoFormState extends State<PhotoForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController();
  late final _owner = TextEditingController(text: widget.ownerAwal);

  @override
  void dispose() {
    _title.dispose();
    _owner.dispose();
    super.dispose();
  }

  void _kirim() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, (title: _title.text.trim(), owner: _owner.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(widget.heading, style: AppText.title2),
          const SizedBox(height: 4),
          Text(widget.hint, style: AppText.footnote),
          const SizedBox(height: 16),
          TextFormField(
            controller: _title,
            autofocus: true,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Judul foto, mis. Kolam anak', fillColor: AppColors.abuMuda, counterText: ''),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Isi judul foto.' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _owner,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Nama pengirim', fillColor: AppColors.abuMuda, counterText: ''),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Isi nama pengirim.' : null,
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: widget.buttonLabel, icon: CupertinoIcons.cloud_upload_fill, onPressed: _kirim),
        ]),
      ),
    );
  }
}
