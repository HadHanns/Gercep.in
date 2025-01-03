import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<File?> pickFileOrImage() async {
  try {
    // Memilih file atau gambar tanpa batasan tipe
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Memungkinkan semua jenis file
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!); // Mengembalikan file yang dipilih
    }
    return null; // Jika pengguna membatalkan pemilihan
  } catch (e) {
    print('Error picking file: $e'); // Menangani kesalahan
    return null;
  }
}