import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'service/location_service.dart';
import 'face_oval_painter.dart';
import 'service/face_net_service.dart';
import 'service/firestore_service.dart';

const _kBlue = Color(0xFF5B8DEE);
const _kBlueDark = Color(0xFF2C5FC4);
const _kBg = Color(0xFFDDE8F8);
const _kCard = Color(0xFFF0F5FF);
const _kOrange = Color(0xFFF5A623);
const _kRed = Color(0xFFE74C3C);
const _kGreen = Color(0xFF27AE60);
const _kTextDark = Color(0xFF1A2A4A);
const _kTextMid = Color(0xFF5B7AAA);

abstract class AbsensiValidator {
  bool validate();
  String get message;
}

class FaceValidator implements AbsensiValidator {
  final bool isDetected;
  FaceValidator(this.isDetected);
  @override
  bool validate() => isDetected;
  @override
  String get message => 'Scan wajah dulu!';
}

class LocationValidator implements AbsensiValidator {
  final bool isValid;
  final bool bebasLokasi;
  LocationValidator(this.isValid, this.bebasLokasi);
  @override
  bool validate() => bebasLokasi || isValid;
  @override
  String get message => 'Lokasi tidak terverifikasi!';
}

enum AbsensiType { masuk, pulang }

class AbsensiScreen extends StatefulWidget {
  final AbsensiType type;
  const AbsensiScreen({super.key, required this.type});
  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen>
    with TickerProviderStateMixin {
  late Timer _clock;
  DateTime _now = DateTime.now();

  CameraController? _camCtrl;
  List<CameraDescription> _cameras = [];
  bool _camActive = false;
  bool _camBusy = false;

  FaceDetector? _faceDetector;
  bool _isProcessingFrame = false;

  final _faceNet = FaceNetService();
  final _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _karyawanList = [];
  String? _matchedKaryawanId;

  bool _faceDetected = false;
  bool _locDetected = false;
  bool _locValid = false;
  bool _absenDimanaSaja = false;
  Position? _pos;
  double _dist = 0;

  late AnimationController _scanAnim;
  late AnimationController _pulseAnim;

  final _namaCtrl = TextEditingController();
  GoogleMapController? _mapCtrl;

  // ═══════════════════════ INIT ════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();

    _faceNet.loadModel();
    _loadKaryawanData();

    _scanAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.3,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    _initCameraSafe();
  }

  Future<void> _loadKaryawanData() async {
    _karyawanList = await _firestoreService.getAllKaryawan();
  }

  // ═══════════════════════ CAMERA ══════════════════════════════════════════════
  Future<void> _initCameraSafe() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _snack('Izin kamera diperlukan untuk absensi!', isErr: true);
      return;
    }
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) await _startCamera();
    } catch (e) {
      _snack('Kamera tidak tersedia: $e', isErr: true);
    }
  }

  Future<void> _startCamera() async {
    if (_camBusy) return;
    _camBusy = true;
    try {
      final front = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
      final ctrl =
          CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await ctrl.initialize();
      _camCtrl = ctrl;
      if (!mounted) return;
      setState(() => _camActive = true);
      _startFaceDetection();
      _deteksiLokasi();
    } catch (e) {
      if (mounted) _snack('Gagal kamera: $e', isErr: true);
    } finally {
      _camBusy = false;
    }
  }

  Future<void> _toggleCamera() async {
    if (_camBusy) return;
    if (_camActive) {
      await _camCtrl?.stopImageStream().catchError((_) {});
      await _camCtrl?.dispose();
      _camCtrl = null;
      setState(() {
        _camActive = false;
        _faceDetected = false;
        _locDetected = false;
        _locValid = false;
        _pos = null;
        _isProcessingFrame = false;
        _namaCtrl.clear();
      });
    } else {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
        if (_cameras.isEmpty) {
          _snack('Kamera tidak tersedia!', isErr: true);
          return;
        }
      }
      await _startCamera();
    }
  }

  void _startFaceDetection() {
    if (_camCtrl == null || !_camActive) return;
    if (_camCtrl!.value.isStreamingImages) return; // ✅ cegah double stream

    _camCtrl!.startImageStream((CameraImage frame) async {
      if (_isProcessingFrame || _faceDetected) return;
      _isProcessingFrame = true;

      try {
        final inputImage = _convertFrameToInputImage(frame);
        if (inputImage == null) {
          _isProcessingFrame = false;
          return;
        }
        final faces = await _faceDetector!.processImage(inputImage);
        if (faces.isEmpty) {
          _isProcessingFrame = false;
          return;
        }

        // Stop stream sebelum takePicture
        try {
          await _camCtrl?.stopImageStream();
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 300));

        final xFile = await _camCtrl?.takePicture();
        if (xFile == null) {
          _isProcessingFrame = false;
          return;
        }

        final bytes = await xFile.readAsBytes();
        final fullImg = img.decodeImage(bytes);
        if (fullImg == null) {
          _isProcessingFrame = false;
          return;
        }

        final inputImg2 = InputImage.fromFilePath(xFile.path);
        final faces2 = await _faceDetector!.processImage(inputImg2);
        if (faces2.isEmpty) {
          _isProcessingFrame = false;
          if (_camActive && mounted) _startFaceDetection();
          return;
        }

        final cropped = _faceNet.cropFace(fullImg, faces2.first);
        if (cropped == null) {
          _isProcessingFrame = false;
          if (_camActive && mounted) _startFaceDetection();
          return;
        }

        final embeddingCam = _faceNet.generateEmbedding(cropped);
        if (embeddingCam == null) {
          _isProcessingFrame = false;
          if (_camActive && mounted) _startFaceDetection();
          return;
        }

        Map<String, dynamic>? matched;
        double bestScore = double.maxFinite;

        for (final karyawan in _karyawanList) {
          final raw = karyawan['faceEmbedding'];
          if (raw == null) continue;
          final embDb = List<double>.from(raw);
          final score = _faceNet.compareFaces(embeddingCam, embDb);
          if (score < bestScore) {
            bestScore = score;
            matched = karyawan;
          }
        }

        if (bestScore < 0.3 && matched != null && mounted) {
          setState(() {
            _faceDetected = true;
            _matchedKaryawanId = matched!['uid'];
            _namaCtrl.text = matched['namaKaryawan'] ?? matched['nama'] ?? '';
          });
        } else if (mounted) {
          // ✅ Tampilkan peringatan wajah tidak sesuai
          _snack(
              '⚠️ Wajah tidak dikenali! Pastikan wajah kamu sudah terdaftar.',
              isErr: true);
          await Future.delayed(const Duration(seconds: 2));
          if (_camActive && mounted) _startFaceDetection();
        }
      } catch (e) {
        debugPrint('Error face recognition: $e');
        await Future.delayed(const Duration(seconds: 1));
        if (_camActive && mounted) _startFaceDetection();
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  // ─── Konversi frame kamera → InputImage ───────────────────────────────────
  InputImage? _convertFrameToInputImage(CameraImage image) {
    if (_camCtrl == null) return null;
    try {
      final camera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first);
      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation270deg;

      // ✅ Gabungkan semua planes (fix Samsung NV21 format)
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  // ─── Lokasi ───────────────────────────────────────────────────────────────
  Future<void> _deteksiLokasi() async {
    if (_absenDimanaSaja) {
      if (!mounted) return;
      setState(() {
        _locDetected = true;
        _locValid = true;
        _dist = 0;
        _pos = null;
      });
      return;
    }

    final status = await Permission.location.request();
    if (!status.isGranted) {
      _snack('Izin lokasi ditolak!', isErr: true);
      return;
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _snack('GPS tidak aktif!', isErr: true);
      return;
    }

    try {
      final pos = await LocationService.getPosition();
      if (!mounted) return;
      if (pos == null) {
        _snack('Gagal mendapatkan lokasi!', isErr: true);
        return;
      }
      final dist = LocationService.distanceTo(pos.latitude, pos.longitude);
      final valid = LocationService.isInside(pos.latitude, pos.longitude);
      setState(() {
        _pos = pos;
        _dist = dist;
        _locDetected = true;
        _locValid = valid;
      });
    } catch (e) {
      _snack('Error lokasi: $e', isErr: true);
    }
  }

  // ═══════════════════════ SUBMIT ══════════════════════════════════════════════
  Future<void> _submit() async {
    final validators = [
      FaceValidator(_faceDetected),
      LocationValidator(_locValid, _absenDimanaSaja),
    ];
    for (final v in validators) {
      if (!v.validate()) {
        _snack(v.message, isErr: true);
        return;
      }
    }

    if (_matchedKaryawanId == null) {
      _snack('Wajah tidak dikenali, tidak bisa absen!', isErr: true);
      return;
    }

    final success = await _firestoreService.saveAbsensi(
      uid: _matchedKaryawanId!,
      type: widget.type == AbsensiType.masuk ? 'masuk' : 'pulang',
      jam: DateFormat('HH:mm').format(DateTime.now()),
      lat: _pos?.latitude,
      lng: _pos?.longitude,
    );

    if (!success) {
      _snack('Gagal simpan absensi, coba lagi!', isErr: true);
      return;
    }

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final typeLabel = widget.type == AbsensiType.masuk ? 'MASUK' : 'PULANG';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('KECOCOKAN DATA',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: _kTextDark)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: _kBlue, borderRadius: BorderRadius.circular(20)),
                    child: const Text('100%',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _verRow(Icons.check_box_rounded, 'Nama: ${_namaCtrl.text}'),
              const SizedBox(height: 6),
              _verRow(Icons.check_box_rounded, 'Wajah: terdeteksi cocok'),
              const SizedBox(height: 6),
              _verRow(Icons.check_box_rounded,
                  'Absen $typeLabel — ${DateFormat('HH:mm').format(DateTime.now())}'),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 140,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _pos != null
                          ? LatLng(_pos!.latitude, _pos!.longitude)
                          : LatLng(LocationService.storeLat,
                              LocationService.storeLng),
                      zoom: 15,
                    ),
                    markers: {
                      if (_pos != null)
                        Marker(
                          markerId: const MarkerId('user'),
                          position: LatLng(_pos!.latitude, _pos!.longitude),
                          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
                        ),
                      Marker(
                        markerId: const MarkerId('toko'),
                        position: LatLng(
                            LocationService.storeLat, LocationService.storeLng),
                        infoWindow:
                            InfoWindow(title: LocationService.storeName),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: (c) => _mapCtrl = c,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fiber_manual_record,
                          color: Colors.white, size: 10),
                      SizedBox(width: 8),
                      Text('ABSENSI TEREKAM',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Icon(icon, color: _kGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _kTextDark))),
        ]),
      );

  void _snack(String msg, {bool isErr = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: isErr ? _kRed : _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ═══════════════════════ DISPOSE ═════════════════════════════════════════════
  @override
  void dispose() {
    _faceDetector?.close();
    _faceNet.dispose();
    _clock.cancel();
    _scanAnim.dispose();
    _pulseAnim.dispose();
    _camCtrl?.dispose();
    _namaCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════ BUILD ════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH.mm').format(_now);
    final typeLabel = widget.type == AbsensiType.masuk ? 'MASUK' : 'PULANG';
    final typeColor = widget.type == AbsensiType.masuk ? _kBlue : _kOrange;
    final typeIcon = widget.type == AbsensiType.masuk
        ? Icons.login_rounded
        : Icons.logout_rounded;

    return Scaffold(
      backgroundColor: _kBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC8DCF8), _kBg, Color(0xFFCDD8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            _buildHeader(timeStr, typeLabel, typeColor, typeIcon),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(children: [
                _buildStatRow(),
                const SizedBox(height: 16),
                _buildToggleMode(),
                const SizedBox(height: 16),
                _buildScanWajah(typeColor),
                const SizedBox(height: 16),
                _buildNamaCard(),
                const SizedBox(height: 16),
                _buildLokasiCard(),
                const SizedBox(height: 24),
                _buildSubmitBtn(typeLabel, typeColor, typeIcon),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(
      String timeStr, String typeLabel, Color typeColor, IconData typeIcon) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_kBlue, _kBlueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EXOTIC GAMING & CAFFE',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13)),
              Text('ABSENSI KARYAWAN',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
                color: _kOrange, borderRadius: BorderRadius.circular(16)),
            child: Text(timeStr,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20)),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(typeIcon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('ABSEN $typeLabel',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStatRow() => Row(children: [
        _statCard('22', 'HADIR', _kOrange),
        const SizedBox(width: 10),
        _statCard('15', 'TERLAMBAT', _kOrange),
        const SizedBox(width: 10),
        _statCard('1', 'ABSEN', _kRed),
      ]);

  Widget _statCard(String val, String lbl, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: _kBlue.withOpacity(0.09),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(children: [
            Text(val,
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900, color: color)),
            Text(lbl,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _kTextMid,
                    letterSpacing: 1)),
          ]),
        ),
      );

  Widget _buildToggleMode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _kBlue.withOpacity(0.09),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Icon(_absenDimanaSaja ? Icons.public_rounded : Icons.store_rounded,
            color: _absenDimanaSaja ? _kOrange : _kBlue, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_absenDimanaSaja ? 'MODE: DIMANA SAJA' : 'MODE: DI LOKASI',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: _absenDimanaSaja ? _kOrange : _kBlue)),
          Text(
              _absenDimanaSaja
                  ? 'Absensi tanpa cek lokasi (TESTER)'
                  : 'Absensi wajib dalam radius toko',
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: _kTextMid)),
        ])),
        Switch(
          value: _absenDimanaSaja,
          activeColor: _kOrange,
          onChanged: (val) {
            setState(() {
              _absenDimanaSaja = val;
              _locDetected = false;
              _locValid = false;
              _pos = null;
            });
            if (_camActive) _deteksiLokasi();
          },
        ),
      ]),
    );
  }

  Widget _buildScanWajah(Color typeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: _kBlue.withOpacity(0.09),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.photo_camera_rounded, color: _kTextMid, size: 17),
            SizedBox(width: 6),
            Text('SCAN WAJAH',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: _kTextDark)),
          ]),
          _badge(_camActive ? 'AKTIF' : 'BELUM AKTIF',
              _camActive ? _kGreen : _kRed),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _toggleCamera,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                _buildCamBg(),
                if (_camActive)
                  AnimatedBuilder(
                    animation: _scanAnim,
                    builder: (_, __) => CustomPaint(
                      painter: FaceOvalPainter(
                        progress: _faceDetected ? 1.0 : _scanAnim.value,
                        detected: _faceDetected,
                      ),
                    ),
                  ),
                if (_camActive)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _statusRow(
                              icon: _faceDetected
                                  ? Icons.check_circle_rounded
                                  : Icons.face_rounded,
                              label: _faceDetected
                                  ? 'Wajah terdeteksi ✓'
                                  : 'Mendeteksi wajah...',
                              color: _faceDetected ? _kGreen : Colors.white70,
                            ),
                            const SizedBox(height: 2),
                            _statusRow(
                              icon: _locDetected
                                  ? Icons.check_circle_rounded
                                  : Icons.location_searching_rounded,
                              label: _locDetected
                                  ? 'Lokasi terdeteksi ✓'
                                  : 'Mendeteksi lokasi...',
                              color: _locDetected ? _kGreen : Colors.white70,
                            ),
                          ]),
                    ),
                  ),
                if (!_camActive)
                  Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.photo_camera_rounded,
                            size: 52, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('TAP UNTUK MENGAKTIFKAN KAMERA',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _toggleCamera,
              icon: Icon(
                  _camActive
                      ? Icons.videocam_off_rounded
                      : Icons.camera_alt_rounded,
                  size: 17),
              label: Text(_camActive ? 'MATIKAN KAMERA' : 'AKTIFKAN KAMERA',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _camActive ? _kRed : _kBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_camActive) {
                setState(() {
                  _faceDetected = false;
                  _locDetected = false;
                  _locValid = false;
                  _isProcessingFrame = false;
                  _namaCtrl.clear();
                });
                _camCtrl
                    ?.stopImageStream()
                    .catchError((_) {})
                    .then((_) => _startFaceDetection());
                _deteksiLokasi();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBlue.withOpacity(0.3)),
              ),
              child: const Icon(Icons.refresh_rounded, color: _kBlue),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildCamBg() {
    if (_camCtrl != null && _camCtrl!.value.isInitialized)
      return CameraPreview(_camCtrl!);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0d2137), Color(0xFF1a3a6e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
          child: Icon(Icons.face_rounded, size: 80, color: Colors.white24)),
    );
  }

  Widget _statusRow(
          {required IconData icon,
          required String label,
          required Color color}) =>
      Row(children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ]);

  Widget _buildNamaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: _kBlue.withOpacity(0.09),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.smart_toy_rounded, color: _kBlue, size: 17),
          SizedBox(width: 6),
          Text('NAMA KARYAWAN',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: _kTextDark)),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _namaCtrl,
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: _kTextDark, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Nama karyawan',
            hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
                fontSize: 12),
            filled: true,
            fillColor: const Color(0xFFDDE8F8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: _faceDetected
                ? const Icon(Icons.check_circle_rounded, color: _kGreen)
                : null,
          ),
        ),
      ]),
    );
  }

  Widget _buildLokasiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: _kBlue.withOpacity(0.09),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.location_on_rounded, color: _kBlue, size: 17),
            SizedBox(width: 6),
            Text('VERIFIKASI LOKASI',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: _kTextDark)),
          ]),
          if (_absenDimanaSaja)
            _badge('DIMANA SAJA', _kOrange)
          else if (_locDetected)
            _badge(_locValid ? 'TERDETEKSI' : 'DI LUAR LOKASI',
                _locValid ? _kGreen : _kRed)
          else if (_camActive)
            _badge('Mendeteksi...', _kOrange)
          else
            _badge('Belum terdeteksi', Colors.grey),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFDDE8F8),
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (_absenDimanaSaja
                        ? _kOrange
                        : _locValid
                            ? _kGreen
                            : _kBlue)
                    .withOpacity(0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _absenDimanaSaja ? Icons.public_rounded : Icons.store_rounded,
                size: 19,
                color: _absenDimanaSaja
                    ? _kOrange
                    : _locValid
                        ? _kGreen
                        : _kBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    _absenDimanaSaja
                        ? 'MODE TESTER AKTIF'
                        : _locDetected && _pos != null
                            ? 'LOKASI ANDA'
                            : 'LOKASI TOKO',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: _kTextDark),
                  ),
                  Text(
                    _absenDimanaSaja
                        ? 'Absensi diizinkan dari mana saja'
                        : _locDetected && _pos != null
                            ? '${_pos!.latitude.toStringAsFixed(4)}, ${_pos!.longitude.toStringAsFixed(4)}'
                            : LocationService.storeAddress,
                    style: const TextStyle(
                        fontSize: 10,
                        color: _kTextMid,
                        fontWeight: FontWeight.w600),
                  ),
                  if (!_absenDimanaSaja && _locDetected)
                    Text('${_dist.toStringAsFixed(0)} m dari toko',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _locValid ? _kGreen : _kRed)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _absenDimanaSaja
                    ? _kOrange
                    : _locDetected
                        ? (_locValid ? _kGreen : _kRed)
                        : (_camActive ? _kOrange : Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _absenDimanaSaja
                    ? 'TESTER'
                    : _locDetected
                        ? (_locValid ? 'TERVERIFIKASI' : 'TIDAK DI LOKASI')
                        : (_camActive ? 'MENDETEKSI' : 'MENUNGGU'),
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
          ]),
        ),
        if (!_absenDimanaSaja && _locDetected && _pos != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 140,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(_pos!.latitude, _pos!.longitude), zoom: 15),
                markers: {
                  Marker(
                      markerId: const MarkerId('user'),
                      position: LatLng(_pos!.latitude, _pos!.longitude),
                      infoWindow: const InfoWindow(title: 'Lokasi Anda')),
                  Marker(
                      markerId: const MarkerId('toko'),
                      position: LatLng(
                          LocationService.storeLat, LocationService.storeLng),
                      infoWindow: InfoWindow(title: LocationService.storeName),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue)),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (c) => _mapCtrl = c,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(_locValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: _locValid ? _kGreen : _kRed, size: 16),
            const SizedBox(width: 6),
            Text(
                _locValid
                    ? 'LOKASI TERVERIFIKASI'
                    : 'ANDA TIDAK ADA DI LOKASI TOKO',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: _locValid ? _kGreen : _kRed)),
          ]),
        ],
        if (!_absenDimanaSaja && !_camActive) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _deteksiLokasi,
              icon: const Icon(Icons.my_location_rounded, size: 17),
              label: const Text('DETEKSI LOKASI SEKARANG',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlueDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildSubmitBtn(String typeLabel, Color typeColor, IconData typeIcon) {
    final ok = _faceDetected && (_absenDimanaSaja || _locValid);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: ok ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ok ? typeColor : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: ok ? 4 : 0,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(ok ? typeIcon : Icons.lock_rounded,
              size: 20, color: Colors.white),
          const SizedBox(width: 10),
          Text('ABSEN $typeLabel SEKARANG',
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.5)),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800, color: color)),
      );
}
