import 'dart:io';
import 'package:absenpro/helpers/permisssion_helper.dart';
import 'package:absenpro/pages/dashboard_page.dart';
import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:absenpro/services/face_profile/face_profile_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';

enum _RegisterStep {
  checkingPermission,
  permissionDenied,
  live,
  review,
  submitting,
}

/// Halaman wajib diisi saat pegawai belum punya data face_profile
/// (reference_photo_path & face_embedding) di backend.
/// Ditampilkan sebagai halaman PERTAMA setelah login/auto-login kalau
/// employee.faceProfile masih null — user tidak bisa skip ke Dashboard
/// sebelum berhasil daftar wajah.
class FaceProfileRegisterPage extends StatefulWidget {
  const FaceProfileRegisterPage({super.key});

  @override
  State<FaceProfileRegisterPage> createState() =>
      _FaceProfileRegisterPageState();
}

class _FaceProfileRegisterPageState extends State<FaceProfileRegisterPage> {
  static const Color primaryTeal = Color(0xFF2FC7CF);

  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
  final FaceProfileService _faceProfileService = FaceProfileService();

  _RegisterStep _step = _RegisterStep.checkingPermission;
  String? _errorMessage;
  XFile? _capturedPhoto;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _initFlow();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _initFlow() async {
    setState(() {
      _step = _RegisterStep.checkingPermission;
      _errorMessage = null;
    });

    final cameraStatus = await PermissionHelper.requestCamera();
    if (cameraStatus != PermissionResultStatus.granted) {
      setState(() {
        _step = _RegisterStep.permissionDenied;
        _permanentlyDenied =
            cameraStatus == PermissionResultStatus.permanentlyDenied;
        _errorMessage = 'Izin kamera dibutuhkan untuk daftar wajah.';
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
        _step = _RegisterStep.live;
      });
    } catch (e) {
      setState(() {
        _step = _RegisterStep.permissionDenied;
        _errorMessage = 'Gagal membuka kamera: $e';
      });
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final photo = await controller.takePicture();

      // Validasi cepat client-side: pastikan ada 1 wajah jelas di foto,
      // sebelum dikirim ke backend untuk disimpan sebagai foto referensi.
      final inputImage = InputImage.fromFilePath(photo.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wajah tidak terdeteksi, coba lagi')),
        );
        return;
      }
      if (faces.length > 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terdeteksi lebih dari 1 wajah, pastikan hanya '
                'wajah Anda di frame'),
          ),
        );
        return;
      }

      setState(() {
        _capturedPhoto = photo;
        _step = _RegisterStep.review;
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
      _step = _RegisterStep.live;
    });
  }

  Future<void> _submit() async {
    final photo = _capturedPhoto;
    if (photo == null) return;

    setState(() => _step = _RegisterStep.submitting);

    try {
      final compressedPath =
          '${photo.path.substring(0, photo.path.lastIndexOf('.'))}_compressed.jpg';

      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        photo.path,
        compressedPath,
        quality: 80,
        minWidth: 720,
        minHeight: 720,
      );

      final fileToUpload = File(compressedXFile?.path ?? photo.path);

      // Backend mengembalikan data user lengkap terbaru (termasuk
      // employee.faceProfile yang baru terdaftar) — langsung dipakai untuk
      // replace state & local storage, tanpa perlu login ulang.
      final updatedUser = await _faceProfileService.registerFaceProfile(
        photo: fileToUpload,
      );

      if (!mounted) return;

      await context.read<AuthProvider>().updateUserFromServer(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajah berhasil didaftarkan')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _step = _RegisterStep.review);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Cegah user "kabur" balik ke halaman sebelumnya (mis. Login) sebelum
      // daftar wajah selesai — pendaftaran wajah wajib di awal pemakaian.
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftarkan Wajah'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          centerTitle: true,
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _RegisterStep.checkingPermission:
        return const Center(child: CircularProgressIndicator());

      case _RegisterStep.permissionDenied:
        return _buildPermissionDenied();

      case _RegisterStep.live:
        return _buildLiveCamera();

      case _RegisterStep.review:
        return _buildReview();

      case _RegisterStep.submitting:
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
              backgroundColor: primaryTeal,
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
          const Text(
            'Sebelum mulai menggunakan aplikasi, kami perlu foto wajah Anda '
            'sebagai data referensi untuk verifikasi saat absen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CameraPreview(controller),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Posisikan wajah di dalam frame, pastikan pencahayaan cukup',
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
                backgroundColor: primaryTeal,
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
          const SizedBox(height: 16),
          const Text(
            'Pastikan wajah terlihat jelas dan tidak buram sebelum '
            'mengirim.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed:
                        _step == _RegisterStep.submitting ? null : _retake,
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
                    onPressed:
                        _step == _RegisterStep.submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Daftarkan'),
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
