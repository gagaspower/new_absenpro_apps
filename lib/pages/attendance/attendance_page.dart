import 'dart:io';
import 'package:absenpro/helpers/device_helper.dart';
import 'package:absenpro/helpers/permisssion_helper.dart';
import 'package:absenpro/services/attendance/attendance_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum _AbsenStep {
  checkingPermission,
  permissionDenied,
  live,
  review,
  submitting
}

/// Halaman untuk ambil foto selfie sebelum absen masuk/pulang.
/// Alur: cek izin kamera & lokasi -> live preview kamera depan ->
/// ambil foto -> validasi ada wajah terdeteksi (client-side, cepat) ->
/// preview hasil foto -> kompres & kirim ke server (server yang melakukan
/// pencocokan wajah sesungguhnya lewat face_embedding).
class AbsenSelfiePage extends StatefulWidget {
  final bool isCheckIn;

  const AbsenSelfiePage({super.key, required this.isCheckIn});

  @override
  State<AbsenSelfiePage> createState() => _AbsenSelfiePageState();
}

class _AbsenSelfiePageState extends State<AbsenSelfiePage> {
  static const Color primaryTeal = Color(0xFF2FC7CF);
  static const Color absenPulangColor = Color(0xFFFF9B9B);

  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
  final AbsenService _absenService = AbsenService();
  final TextEditingController _notesController = TextEditingController();

  _AbsenStep _step = _AbsenStep.checkingPermission;
  String? _errorMessage;
  XFile? _capturedPhoto;
  bool _permanentlyDenied = false;

  Color get _accentColor => widget.isCheckIn ? primaryTeal : absenPulangColor;
  String get _title => widget.isCheckIn ? 'Absen Masuk' : 'Absen Pulang';

  @override
  void initState() {
    super.initState();
    _initFlow();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initFlow() async {
    setState(() {
      _step = _AbsenStep.checkingPermission;
      _errorMessage = null;
    });

    final cameraStatus = await PermissionHelper.requestCamera();
    if (cameraStatus != PermissionResultStatus.granted) {
      setState(() {
        _step = _AbsenStep.permissionDenied;
        _permanentlyDenied =
            cameraStatus == PermissionResultStatus.permanentlyDenied;
        _errorMessage = 'Izin kamera dibutuhkan untuk absen.';
      });
      return;
    }

    final locationStatus = await PermissionHelper.requestLocation();
    if (locationStatus != PermissionResultStatus.granted) {
      setState(() {
        _step = _AbsenStep.permissionDenied;
        _permanentlyDenied =
            locationStatus == PermissionResultStatus.permanentlyDenied;
        _errorMessage =
            'Izin lokasi dibutuhkan untuk absen (pastikan GPS aktif).';
      });
      return;
    }

    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _step = _AbsenStep.live;
      });
    } catch (e) {
      setState(() {
        _step = _AbsenStep.permissionDenied;
        _errorMessage = 'Gagal membuka kamera: $e';
      });
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final photo = await controller.takePicture();

      // Validasi cepat di sisi klien: pastikan ada wajah di foto.
      // Ini BUKAN pencocokan identitas — cuma cek "ada wajah atau tidak",
      // supaya user langsung tahu kalau perlu foto ulang tanpa harus
      // nunggu response dari server. Pencocokan identitas sesungguhnya
      // tetap dilakukan backend lewat face_embedding.
      final inputImage = InputImage.fromFilePath(photo.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wajah tidak terdeteksi, coba lagi'),
          ),
        );
        return;
      }

      setState(() {
        _capturedPhoto = photo;
        _step = _AbsenStep.review;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  void _retake() {
    setState(() {
      _capturedPhoto = null;
      _step = _AbsenStep.live;
    });
  }

  Future<void> _submit() async {
    final photo = _capturedPhoto;
    if (photo == null) return;

    setState(() => _step = _AbsenStep.submitting);

    try {
      // 1. Kompres foto sebelum upload (kurangi ukuran, hemat data & waktu)
      final compressedPath =
          '${photo.path.substring(0, photo.path.lastIndexOf('.'))}_compressed.jpg';

      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        photo.path,
        compressedPath,
        quality: 70,
        minWidth: 720,
        minHeight: 720,
      );

      final fileToUpload = File(compressedXFile?.path ?? photo.path);

      // 2. Ambil lokasi saat ini
      final position = await Geolocator.getCurrentPosition();

      // 3. Ambil info device
      final device = await DeviceHelper.getDeviceDescription();

      // 4. Kirim ke backend (endpoint sama untuk absen masuk & pulang —
      // backend yang menentukan mana yang berlaku berdasarkan status
      // absensi hari itu)
      final attendance = await _absenService.submitAbsen(
        photo: fileToUpload,
        latitude: position.latitude,
        longitude: position.longitude,
        device: device,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isCheckIn
                ? 'Absen masuk berhasil dicatat'
                : 'Absen pulang berhasil dicatat',
          ),
        ),
      );
      Navigator.pop(context, attendance);
    } catch (e) {
      if (!mounted) return;
      setState(() => _step = _AbsenStep.review);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _AbsenStep.checkingPermission:
        return const Center(child: CircularProgressIndicator());

      case _AbsenStep.permissionDenied:
        return _buildPermissionDenied();

      case _AbsenStep.live:
        return _buildLiveCamera();

      case _AbsenStep.review:
        return _buildReview();

      case _AbsenStep.submitting:
        return Stack(
          children: [
            _buildReview(),
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildPermissionDenied() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography_outlined,
              size: 56, color: Colors.black26),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Izin dibutuhkan',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                _permanentlyDenied ? PermissionHelper.openSettings : _initFlow,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(_permanentlyDenied ? 'Buka Pengaturan' : 'Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCamera() {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CameraPreview(controller),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Posisikan wajah di dalam frame, lalu ambil foto',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('Ambil Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview() {
    final photo = _capturedPhoto;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: photo != null
                  ? Image.file(File(photo.path),
                      fit: BoxFit.cover, width: double.infinity)
                  : Container(color: const Color(0xFFEDEDED)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Catatan (opsional)',
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _step == _AbsenStep.submitting ? null : _retake,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Ambil Ulang'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _step == _AbsenStep.submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Kirim'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
