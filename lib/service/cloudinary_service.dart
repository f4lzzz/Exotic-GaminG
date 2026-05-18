import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dldt55eln';
  static const String _apiKey = '834919699397264';
  static const String _apiSecret = 'e5f1R100Jf-Ge_cXvUg7ESz1cnA';
  static const String _uploadPreset = 'exotic_gaming';

  /// Upload gambar ke Cloudinary.
  /// [imageFile] : file gambar yang akan diupload
  /// [folder]    : folder di Cloudinary (opsional, default 'uploads')
  /// Return: URL gambar yang sudah diupload, atau null jika gagal.
  Future<String?> uploadImage({
    required File imageFile,
    String folder = 'uploads',
  }) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        return json['secure_url'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Upload dengan signed request (lebih aman untuk production)
  Future<String?> uploadImageSigned({
    required File imageFile,
    String folder = 'uploads',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final paramsToSign = 'folder=$folder&timestamp=$timestamp';
      final signature = _generateSignature(paramsToSign);

      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri);
      request.fields['api_key'] = _apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['folder'] = folder;

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        return json['secure_url'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Hapus gambar dari Cloudinary berdasarkan publicId
  Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final paramsToSign = 'public_id=$publicId&timestamp=$timestamp';
      final signature = _generateSignature(paramsToSign);

      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy');

      final response = await http.post(uri, body: {
        'public_id': publicId,
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'signature': signature,
      });

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String _generateSignature(String paramsToSign) {
    final toSign = '$paramsToSign$_apiSecret';
    final bytes = utf8.encode(toSign);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
}
