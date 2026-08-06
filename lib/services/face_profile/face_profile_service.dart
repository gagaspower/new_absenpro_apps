import 'dart:io';
import 'package:absenpro/models/users/user_model.dart';
import 'package:absenpro/services/api_service.dart';
import 'package:dio/dio.dart';

class FaceProfileService {
  final ApiService _apiService = ApiService();

  /// Daftarkan foto referensi wajah pegawai.
  /// Endpoint: POST reference/pegawai/face-registration
  /// Form-data: photo (file)
  ///
  /// Backend mengembalikan data user lengkap (sama struktur seperti
  /// response login) di dalam body['data']['user'], supaya local storage
  /// bisa langsung di-refresh dengan data terbaru (termasuk face_profile
  /// yang baru saja terdaftar).
  Future<UserModel> registerFaceProfile({required File photo}) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await _apiService.post(
        'reference/pegawai/face-registration',
        formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = response.data;

      if (body is! Map || body['status'] != true) {
        throw Exception(body is Map
            ? body['message'] ?? 'Registrasi wajah gagal'
            : 'Registrasi wajah gagal');
      }

      final data = body['data'];
      if (data is Map && data['user'] is Map<String, dynamic>) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }

      throw Exception('Response data user tidak valid');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }
}
