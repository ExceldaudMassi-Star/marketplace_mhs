import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  // GANTI DENGAN API KEY ANDA DARI IMGBB
  final String _apiKey = '66f58583420703114f702b8547d186bd';

  // Nama fungsi diubah kembali agar sesuai dengan panggilan di add_product_screen.dart
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      // 1. Siapkan alamat tujuan di ImgBB
      var uri = Uri.parse('https://api.imgbb.com/1/upload?key=$_apiKey');

      // 2. Buat permintaan pengiriman data
      var request = http.MultipartRequest('POST', uri);

      // 3. Lampirkan file gambar ke dalam permintaan
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Nama field ini wajib 'image' sesuai dokumentasi ImgBB
          imageFile.path,
        ),
      );

      // 4. Kirim permintaan dan tunggu respons
      var response = await request.send();

      // 5. Periksa apakah pengiriman berhasil
      if (response.statusCode == 200) {
        // Baca respons yang diberikan oleh ImgBB
        final responseBody = await response.stream.bytesToString();
        // Ubah teks respons menjadi format JSON yang bisa dibaca
        final jsonResponse = json.decode(responseBody);

        // Ambil URL gambar dari respons
        final imageUrl = jsonResponse['data']['url'];
        return imageUrl;
      } else {
        // Jika gagal, kembalikan null
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Fungsi untuk foto profil bisa kita nonaktifkan sementara
  Future<String?> uploadProfilePicture(String uid, File imageFile) async {
    // Untuk saat ini, kita gunakan logika yang sama dengan upload produk
    return await uploadProductImage(imageFile);
  }
}
