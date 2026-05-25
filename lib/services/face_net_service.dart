import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceNetService {
  static const _modelPath = 'assets/models/facenet.tflite';
  static const _inputSize = 160; // FaceNet input: 160×160
  static const _embeddingSize = 128; // output vector
  static const _threshold = 0.8; // jarak max = cocok

  Interpreter? _interpreter;
  bool _isLoaded = false;

  // ─── Load model ──────────────────────────────────────────────
  Future<void> loadModel() async {
    if (_isLoaded) return;
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: options,
      );
      _isLoaded = true;
      debugPrint('✅ FaceNet model loaded');
    } catch (e) {
      debugPrint('❌ Gagal load model: $e');
    }
  }

  // ─── Generate embedding dari gambar yang sudah di-crop ───────
  List<double>? generateEmbedding(img.Image croppedFace) {
    if (_interpreter == null) return null;

    try {
      // 1. Resize ke 160×160
      final resized = img.copyResize(
        croppedFace,
        width: _inputSize,
        height: _inputSize,
      );

      // 2. Konversi ke input tensor [1, 160, 160, 3]
      final input = _imageToInput(resized);

      // 3. Siapkan output tensor [1, 512]
      final output = List.generate(
        1,
        (_) => List.filled(_embeddingSize, 0.0),
      );

      // 4. Jalankan inference
      _interpreter!.run(input, output);

      // 5. Normalize (L2)
      final embedding = output[0];
      return _l2Normalize(embedding);
    } catch (e) {
      debugPrint('❌ Error generate embedding: $e');
      return null;
    }
  }

  // ─── Crop wajah dari gambar penuh pakai data ML Kit ──────────
  img.Image? cropFace(img.Image fullImage, Face face) {
    try {
      final box = face.boundingBox;

      // Tambah padding 20% supaya wajah tidak terpotong
      final padding = (box.width * 0.2).toInt();
      final x = max(0, box.left.toInt() - padding);
      final y = max(0, box.top.toInt() - padding);
      final w = min(fullImage.width - x, box.width.toInt() + padding * 2);
      final h = min(fullImage.height - y, box.height.toInt() + padding * 2);

      return img.copyCrop(fullImage, x: x, y: y, width: w, height: h);
    } catch (e) {
      debugPrint('❌ Error crop wajah: $e');
      return null;
    }
  }

  // ─── Bandingkan dua embedding (cosine similarity) ────────────
  double compareFaces(List<double> e1, List<double> e2) {
    double dot = 0, n1 = 0, n2 = 0;
    for (int i = 0; i < e1.length; i++) {
      dot += e1[i] * e2[i];
      n1 += e1[i] * e1[i];
      n2 += e2[i] * e2[i];
    }
    // cosine distance (0 = identik, 2 = sangat berbeda)
    return 1 - (dot / (sqrt(n1) * sqrt(n2)));
  }

  // ─── Cek apakah dua wajah cocok ──────────────────────────────
  bool isSamePerson(List<double> e1, List<double> e2) =>
      compareFaces(e1, e2) < _threshold;

  // ─── Helper: image → input tensor ────────────────────────────
  List<List<List<List<double>>>> _imageToInput(img.Image image) {
    return List.generate(
        1,
        (_) => List.generate(
            _inputSize,
            (y) => List.generate(_inputSize, (x) {
                  final pixel = image.getPixel(x, y);
                  // ✅ FIX: cast eksplisit ke double agar tidak type mismatch
                  return [
                    (pixel.r.toDouble() / 127.5) - 1.0,
                    (pixel.g.toDouble() / 127.5) - 1.0,
                    (pixel.b.toDouble() / 127.5) - 1.0,
                  ];
                })));
  }

  // ─── Helper: L2 normalization ─────────────────────────────────
  List<double> _l2Normalize(List<double> v) {
    final norm = sqrt(v.fold(0.0, (s, e) => s + e * e));
    return norm == 0 ? v : v.map((e) => e / norm).toList();
  }

  void dispose() => _interpreter?.close();
}
