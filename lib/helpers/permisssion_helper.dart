import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionResultStatus { granted, denied, permanentlyDenied }

class PermissionHelper {
  /// Minta izin kamera.
  static Future<PermissionResultStatus> requestCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) return PermissionResultStatus.granted;
    if (status.isPermanentlyDenied) {
      return PermissionResultStatus.permanentlyDenied;
    }
    return PermissionResultStatus.denied;
  }

  /// Minta izin lokasi + pastikan GPS/location service aktif.
  /// Pakai Geolocator langsung (bukan permission_handler) karena lebih
  /// lengkap: sekalian cek apakah location service perangkat menyala.
  static Future<PermissionResultStatus> requestLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return PermissionResultStatus.denied;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return PermissionResultStatus.permanentlyDenied;
    }
    if (permission == LocationPermission.denied) {
      return PermissionResultStatus.denied;
    }

    return PermissionResultStatus.granted;
  }

  /// Buka halaman pengaturan aplikasi (dipakai kalau izin permanently denied,
  /// jadi user bisa aktifkan manual dari Settings).
  static Future<void> openSettings() => openAppSettings();
}
