import 'package:absenpro/models/work_schedule/work_schedule_model.dart';
import 'package:absenpro/models/users/user_model.dart';
import 'package:absenpro/services/api_service.dart';
import 'package:absenpro/services/storage_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  /// Login ke backend Laravel.
  /// Endpoint: POST reference/auth/create-session
  /// Melempar Exception dengan pesan dari backend jika gagal.
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        'reference/auth/create-session',
        {
          'username': username,
          'password': password,
        },
      );

      final body = response.data;

      if (body['status'] == true) {
        final data = body['data'];

        var user = UserModel.fromJson(data['user']);
        final accessToken = data['access_token'] as String;
        final permissions = List<String>.from(data['permissions'] ?? []);

        // work_schedule dikirim backend terpisah di level atas (data.work_schedule),
        // bukan nested di data.user.employee.shift lagi. Merge ke employee di sini
        // supaya sisa app (Home, dsb) tetap baca dari satu tempat: user.employee.
        final workScheduleJson = data['work_schedule'];
        if (workScheduleJson != null && user.employee != null) {
          final workSchedule = WorkScheduleModel.fromJson(
            workScheduleJson as Map<String, dynamic>,
          );
          user = user.copyWith(
            employee: user.employee!.copyWith(workSchedule: workSchedule),
          );
        }

        // Simpan token, data user, dan permissions ke local storage
        await StorageService.saveToken(accessToken);
        await StorageService.saveUser(user.toJson());
        await StorageService.savePermissions(permissions);

        return user;
      } else {
        throw Exception(body['message'] ?? 'Login gagal');
      }
    } on DioException catch (e) {
      // Pesan error dari backend (misal: username/password salah)
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }

  /// Logout — revoke session token di backend, lalu bersihkan local storage.
  /// Endpoint: POST reference/auth/revoke-session
  Future<void> logout() async {
    try {
      await _apiService.post('reference/auth/revoke-session', '');
    } on DioException catch (_) {
      // Diabaikan: walau gagal revoke ke server (misal token sudah expired
      // atau tidak ada koneksi), local storage tetap dibersihkan di bawah,
      // supaya user tetap bisa keluar dari sisi aplikasi.
    } finally {
      await StorageService.clear();
    }
  }

  /// Reset/ubah password pengguna.
  /// Endpoint: PUT reference/auth/reset-password
  /// Melempar Exception dengan pesan dari backend jika gagal.
  Future<void> resetPassword({required String password}) async {
    try {
      final response = await _apiService.put(
        'reference/auth/reset-password',
        {
          'password': password,
          'password_confirmation': password,
        },
      );

      final body = response.data;

      if (body['status'] != true) {
        throw Exception(body['message'] ?? 'Gagal ubah password');
      }
    } on DioException catch (e) {
      // Pesan error dari backend
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }
}
