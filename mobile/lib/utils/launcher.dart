import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'format.dart';

// [P6 Plugin url_launcher] Meminta sistem membuka tautan di aplikasi lain (Google Maps, WhatsApp, browser).
// Kalau gagal, tampilkan pesan di SnackBar.
Future<void> bukaTautan(BuildContext context, String url) async {
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tautan tidak bisa dibuka di perangkat ini.')));
  }
}

// Membuka chat WhatsApp ke nomor pemesan dengan pesan yang sudah terisi (format wa.me).
// Di versi nyata pesan ini dikirim otomatis oleh server lewat WhatsApp Business API.
Future<void> kirimWhatsApp(BuildContext context, String whatsapp, String pesan) =>
    bukaTautan(context, 'https://wa.me/${nomorWaInternasional(whatsapp)}?text=${Uri.encodeComponent(pesan)}');
