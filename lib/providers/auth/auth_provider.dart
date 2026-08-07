import 'package:absenpro/models/attendance/attendance_model.dart';
import 'package:absenpro/models/users/user_model.dart';
import 'package:absenpro/services/auth/auth_service.dart';
import 'package:absenpro/services/storage_service.dart';
import 'package:absenpro/services/attendance/attendance_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AbsenService _absenService = AbsenService();

  bool isLoading = false;
  String? errorMessage;
  UserModel? user;

  /// Login menggunakan username & password.
  /// Return true jika berhasil, false jika gagal (errorMessage terisi).
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        username: username,
        password: password,
      );

      user = result;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Ambil ulang data user dari local storage (misal saat app dibuka lagi)
  Future<void> loadUserFromStorage() async {
    final userData = await StorageService.getUser();
    if (userData != null) {
      user = UserModel.fromJson(userData);
      notifyListeners();
    }
  }

  /// Dipanggil sekali saat app pertama dibuka (splash/startup).
  /// Cek apakah ada token & data user tersimpan di local storage.
  /// Return true kalau ada (langsung ke Dashboard), false kalau tidak (ke Login).
  ///
  /// NOTE: ini baru cek keberadaan token secara lokal, belum validasi
  /// ke server apakah token itu masih aktif/belum expired. Validasi
  /// sebenarnya terjadi otomatis saat request API pertama dari Dashboard —
  /// kalau ternyata token sudah expired, backend akan balas 401 dan
  /// interceptor di ApiService akan otomatis redirect balik ke Login.
  Future<bool> tryAutoLogin() async {
    final token = await StorageService.getToken();
    final userData = await StorageService.getUser();

    if (token != null && userData != null) {
      user = UserModel.fromJson(userData);
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    await _authService.logout();

    user = null;
    isLoading = false;
    notifyListeners();
  }

  /// Reset/ubah password pengguna.
  /// Return true jika berhasil, false jika gagal (errorMessage terisi).
  Future<bool> changePassword({required String newPassword}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(password: newPassword);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update status absen hari ini secara LOKAL (di state + local storage),
  /// dipanggil setelah AbsenSelfiePage berhasil submit absen ke server.
  /// Tujuannya supaya tombol Absen masuk/pulang di Home langsung ke-lock
  /// saat itu juga, tanpa perlu logout-login ulang dulu buat ambil data
  /// absen_today yang baru dari backend.
  Future<void> markAttendanceDone({required bool isCheckIn}) async {
    final currentUser = user;
    final employee = currentUser?.employee;
    if (currentUser == null || employee == null) return;

    final baseAttendance = employee.attendanceToday ??
        AttendanceModel.empty(
          employeeId: employee.id,
          shiftId: employee.shift?.id ?? '',
        );

    final updatedAttendance = baseAttendance.copyWith(
      checkInTime: isCheckIn ? DateTime.now() : null,
      checkOutTime: !isCheckIn ? DateTime.now() : null,
    );

    final updatedEmployee =
        employee.copyWith(attendanceToday: updatedAttendance);
    final updatedUser = currentUser.copyWith(employee: updatedEmployee);

    user = updatedUser;
    await StorageService.saveUser(updatedUser.toJson());
    notifyListeners();
  }

  /// Update data attendance hari ini dari response backend.
  Future<void> updateAttendanceFromServer(AttendanceModel attendance) async {
    final currentUser = user;
    final employee = currentUser?.employee;
    if (currentUser == null || employee == null) return;

    final updatedEmployee = employee.copyWith(attendanceToday: attendance);
    final updatedUser = currentUser.copyWith(employee: updatedEmployee);

    user = updatedUser;
    await StorageService.saveUser(updatedUser.toJson());
    notifyListeners();
  }

  /// Sinkronkan attendance_today LANGSUNG dari server
  /// (GET reference/absen/cek-hari-ini). Ini perbaikan untuk bug:
  /// attendance_today sebelumnya hanya terisi saat login, jadi basi kalau
  /// user tidak pernah logout dan hari sudah berganti.
  Future<void> refreshTodayAttendance() async {
    final currentUser = user;
    final employee = currentUser?.employee;
    if (currentUser == null || employee == null) return;

    try {
      final todayAttendance = await _absenService.getTodayAttendance();

      final updatedEmployee = employee.withAttendanceToday(todayAttendance);
      final updatedUser = currentUser.copyWith(employee: updatedEmployee);

      user = updatedUser;
      await StorageService.saveUser(updatedUser.toJson());
      notifyListeners();
    } catch (_) {
      // Gagal sinkron (mis. tidak ada koneksi) — biarkan data lokal apa
      // adanya, jangan bikin UI error cuma karena request ini gagal.
      // Nanti disinkron lagi di kesempatan berikutnya.
    }
  }

  /// Replace seluruh data user dengan data terbaru dari backend setelah
  /// berhasil registrasi wajah (endpoint face-registration mengembalikan
  /// user lengkap, termasuk employee.faceProfile yang baru terdaftar).
  Future<void> updateUserFromServer(UserModel updatedUser) async {
    user = updatedUser;
    await StorageService.saveUser(updatedUser.toJson());
    notifyListeners();
  }
}
