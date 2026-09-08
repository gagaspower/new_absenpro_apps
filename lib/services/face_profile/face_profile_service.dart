import 'dart:io';
import 'package:absenpro/models/users/user_model.dart';
import 'package:absenpro/models/work_schedule/work_schedule_model.dart';
import 'package:absenpro/services/api_service.dart';
import 'package:dio/dio.dart';

class FaceProfileService {
  final ApiService _apiService = ApiService();

  /// Daftarkan foto referensi wajah pegawai.
  /// Backend mengembalikan data user lengkap dan work_schedule di level data.
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
      if (data is! Map || data['user'] is! Map<String, dynamic>) {
        throw Exception('Response data user tidak valid');
      }

      var user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      // work_schedule dikirim di level data, bukan nested di user.employee.
      // Pertahankan jadwal setelah replace user agar Dashboard/Home tetap
      // dapat menentukan window absensi tanpa login ulang.
      final workScheduleJson = data['work_schedule'];
      if (workScheduleJson is Map && user.employee != null) {
        final workSchedule = WorkScheduleModel.fromJson(
          Map<String, dynamic>.from(workScheduleJson),
        );
        user = user.copyWith(
          employee: user.employee!.copyWith(workSchedule: workSchedule),
        );
      }

      return user;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }
}
