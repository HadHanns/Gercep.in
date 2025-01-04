import 'dart:io';
import 'package:blog_app/core/utils/calculate_reading_time.dart';
import 'package:blog_app/features/blog/domain/entities/blog.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path; // Import library path
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BlogViewerPage extends StatelessWidget {
  static route(Blog blog) => MaterialPageRoute(
        builder: (context) => BlogViewerPage(
          blog: blog,
        ),
      );

  final Blog blog;
  const BlogViewerPage({
    super.key,
    required this.blog,
  });

  // Fungsi untuk mengunduh file
  Future<void> downloadFile(String url) async {
    try {
      // Lakukan HTTP request untuk mendapatkan file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Tentukan nama file asli dari URL
        String fileName = Uri.parse(url).pathSegments.last;

        // Cek apakah nama file memiliki ekstensi
        if (!fileName.contains('.')) {
          // Deteksi MIME type dari response header
          final mimeType = response.headers['content-type'];
          if (mimeType != null) {
            if (mimeType.contains('image/')) {
              fileName += '.jpg'; // Atur default untuk image
            } else if (mimeType.contains('application/pdf')) {
              fileName += '.pdf'; // Default untuk PDF
            } else {
              fileName += '.word'; // Default jika tipe tidak diketahui
            }
          }
        }

        // Tambahkan UUID untuk menghindari nama file yang sama
        final uuid = Uuid().v4();
        final uniqueFileName = '${path.basenameWithoutExtension(fileName)}_$uuid${path.extension(fileName)}';

        // Tentukan lokasi penyimpanan
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(directory.path, uniqueFileName);

        // Simpan file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Beri notifikasi ke pengguna
        print('File saved to $filePath');
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'By ${blog.posterName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${blog.updatedAt} . ${calculateReadingTime(blog.content)} min',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(blog.fileOrImageUrl),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  // Panggil fungsi downloadFile saat tombol ditekan
                  downloadFile(blog.fileOrImageUrl);
                },
                child: const Text('Download File-(kalo Exception Download aja)'),
              ),
              const SizedBox(height: 20),
              Text(blog.content, style: const TextStyle(
                fontSize: 16,
                height: 1.8, 
              ),),
            ],
          ),
        ),
      ),
    );
  }
}