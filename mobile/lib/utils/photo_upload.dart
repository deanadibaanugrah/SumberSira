import 'package:image_picker/image_picker.dart';

// Batas unggah foto sama dengan backend: maksimal 4 MB dan hanya JPEG/PNG/WebP.
const int maxPhotoBytes = 4 * 1024 * 1024;
const List<String> _ekstensiFoto = ['.jpg', '.jpeg', '.png', '.webp'];
const List<String> _mimeFoto = ['image/jpeg', 'image/png', 'image/webp'];

// Memeriksa berkas sebelum diunggah. Mengembalikan pesan galat, atau null bila lolos.
// Backend tetap memeriksa isi berkas lewat magic bytes, jadi pemeriksaan ini hanya untuk umpan balik cepat.
Future<String?> validatePhotoFile(XFile file) async {
  final nama = file.name.toLowerCase();
  final mime = (file.mimeType ?? '').toLowerCase();
  final tipeCocok = _ekstensiFoto.any(nama.endsWith) || _mimeFoto.contains(mime);
  if (!tipeCocok) return 'Format foto harus JPEG, PNG, atau WebP.';
  if (await file.length() > maxPhotoBytes) return 'Foto terlalu besar. Maksimal 4 MB.';
  return null;
}
