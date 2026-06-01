import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'services/face_net_service.dart';
import 'services/firestore_service.dart';
import 'face_oval_painter.dart';

class RegistrasiWajahScreen extends StatefulWidget {
  final String? uid;
  final String? namaKaryawan;

  const RegistrasiWajahScreen({super.key, this.uid, this.namaKaryawan});

  @override
  State<RegistrasiWajahScreen> createState() => _RegistrasiWajahScreenState();
}

class _RegistrasiWajahScreenState extends State<RegistrasiWajahScreen>
    with SingleTickerProviderStateMixin {
  // ─── Controllers & Services ──────────────────────────────────
  CameraController? _camCtrl;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.3,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  final FaceNetService _faceNet = FaceNetService();
  final FirestoreService _firestore = FirestoreService();

  // ─── Tambah controller nama ───────────────────────────────────
  final TextEditingController _namaCtrl = TextEditingController();

  // ─── State ───────────────────────────────────────────────────
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isSaving = false;
  bool _faceDetected = false;
  String _statusMessage = 'Posisikan wajah di dalam oval';
  List<Face> _faces = [];

  // ─── Animation ───────────────────────────────────────────────
  late AnimationController _animCtrl;
  late Animation<double> _pulseAnim;

  // ─── Colors ──────────────────────────────────────────────────
  static const _kBlue = Color(0xFF5B8DEE);
  static const _kBlueDark = Color(0xFF2C5FC4);
  static const _kGreen = Color(0xFF34D399);
  static const _kBg = Color(0xFFDDE8F8);

  @override
  void initState() {
    super.initState();

    // Isi nama awal jika sudah ada dari parameter
    if (widget.namaKaryawan != null && widget.namaKaryawan!.isNotEmpty) {
      _namaCtrl.text = widget.namaKaryawan!;
    }

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _initCamera();
    _faceNet.loadModel();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _camCtrl = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await _camCtrl!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _camCtrl!.startImageStream(_onFrame);
    } catch (e) {
      setState(() => _statusMessage = 'Gagal membuka kamera: $e');
    }
  }

  Future<void> _onFrame(CameraImage camImage) async {
    if (_isProcessing || _isSaving) return;
    _isProcessing = true;
    try {
      final inputImage = _buildInputImage(camImage);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }
      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted) return;
      setState(() {
        _faces = faces;
        _faceDetected = faces.isNotEmpty;
        _statusMessage = faces.isEmpty
            ? 'Posisikan wajah di dalam oval'
            : faces.length > 1
                ? 'Hanya satu wajah yang diizinkan'
                : 'Wajah terdeteksi! Tekan tombol untuk mendaftar';
      });
    } catch (_) {}
    _isProcessing = false;
  }

  InputImage? _buildInputImage(CameraImage image) {
    try {
      final camera = _camCtrl!.description;
      final rotation = InputImageRotationValue.fromRawValue(
            camera.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      final plane = image.planes[0];
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _registerFace() async {
    // Validasi nama wajib diisi
    final nama = _namaCtrl.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ Nama pemilik wajah wajib diisi!',
              style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!_faceDetected || _faces.length != 1) return;

    setState(() {
      _isSaving = true;
      _statusMessage = 'Memproses wajah...';
    });

    try {
      // Ambil snapshot dari kamera
      await _camCtrl!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 300));
      final xFile = await _camCtrl!.takePicture();
      final bytes = await xFile.readAsBytes();

      // Decode gambar
      final fullImage = img.decodeImage(Uint8List.fromList(bytes));
      if (fullImage == null) throw Exception('Gagal decode gambar');

      // Deteksi ulang wajah dari foto
      final inputImg2 = InputImage.fromFilePath(xFile.path);
      final freshFaces = await _faceDetector.processImage(inputImg2);
      if (freshFaces.isEmpty) throw Exception('Wajah tidak terdeteksi di foto');

      // Crop wajah dari foto
      final croppedFace = _faceNet.cropFace(fullImage, freshFaces.first);
      if (croppedFace == null) throw Exception('Gagal crop wajah');

      // Generate embedding
      final embedding = _faceNet.generateEmbedding(croppedFace);
      if (embedding == null) throw Exception('Gagal generate embedding');

      debugPrint('✅ Embedding size: ${embedding.length}');
      debugPrint('📊 Sample values: ${embedding.take(5).toList()}');

      // Simpan ke Firestore
      final uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User tidak ditemukan');

      // Simpan embedding + nama sekaligus
      final success = await _firestore.saveEmbedding(
        uid: uid,
        embedding: embedding,
        nama: nama, // ← kirim nama ke Firestore
      );

      if (!mounted) return;

      if (success) {
        _showSuccessDialog(nama);
      } else {
        throw Exception('Gagal menyimpan ke database');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error: $e';
        _isSaving = false;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && _camCtrl != null) {
        _camCtrl!.startImageStream(_onFrame);
      }
    }
  }

  void _showSuccessDialog(String nama) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: _kGreen, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Wajah Berhasil Didaftarkan!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Wajah $nama sudah tersimpan dan siap digunakan untuk absensi.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(context); // kembali ke Profil
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Kembali ke Profil',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose(); // ← dispose nama controller
    _animCtrl.dispose();
    _camCtrl?.dispose();
    _faceDetector.close();
    _faceNet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kBlueDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftarkan Wajah',
          style: TextStyle(
            color: _kBlueDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Instruksi ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Pastikan wajah kamu terlihat jelas,\ncahaya cukup, dan tidak ada orang lain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kBlueDark.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ),

            // ─── Kamera ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _isInitialized
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            CameraPreview(_camCtrl!),
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => CustomPaint(
                                painter: FaceOvalPainter(
                                  progress: _pulseAnim.value,
                                  detected: _faceDetected,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _faceDetected
                                      ? _kGreen.withOpacity(0.85)
                                      : Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: _kBlue),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Input Nama Pemilik Wajah ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _namaCtrl,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A2A4A),
                ),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nama Pemilik Wajah',
                  hintText: 'Masukkan nama lengkap',
                  labelStyle: const TextStyle(
                    color: _kBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: const Icon(Icons.person_rounded, color: _kBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _kBlue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: _kBlue.withOpacity(0.2), width: 1),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Tombol Daftar ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_faceDetected && !_isSaving) ? _registerFace : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Daftarkan Wajah Saya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
