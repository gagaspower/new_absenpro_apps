import 'dart:io';
import 'package:absenpro/models/attendance/attendance_model.dart';
import 'package:absenpro/services/api_service.dart';
import 'package:dio/dio.dart';

class AbsenService {
  final ApiService _apiService = ApiService();

  /// Kirim absen (dipakai untuk masuk MAUPUN pulang — 1 endpoint sama,
  /// backend yang menentukan ini absen masuk atau pulang berdasarkan
  /// status absensi hari itu).
  /// Endpoint: POST reference/absen/masuk
  Future<AttendanceModel> submitAbsen({
    required File photo,
    required double latitude,
    required double longitude,
    required String device,
    String? notes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split(Platform.pathSeparator).last,
        ),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'device': device,
        'Notes': notes ?? '',
      });

      final response = await _apiService.post(
        'reference/absen/masuk',
        formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = response.data;
      if (body is! Map || body['status'] != true) {
        throw Exception(body is Map
            ? body['message'] ?? 'Absen gagal'
            : 'Absen gagal');
      }

      if (body['attendance'] is Map<String, dynamic>) {
        return AttendanceModel.fromJson(
            body['attendance'] as Map<String, dynamic>);
      }

      throw Exception('Response attendance tidak valid');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }
}
