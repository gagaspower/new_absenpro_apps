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

  Future<bool> login({required String username, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.login(username: username, password: password);
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

  Future<void> loadUserFromStorage() async {
    final userData = await StorageService.getUser();
    if (userData != null) {
      user = UserModel.fromJson(userData);
      notifyListeners();
    }
  }

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

  /// Update status absen secara lokal. Backend baru tidak lagi menjadikan
  /// employee.shift sebagai sumber jadwal, sehingga fallback attendance
  /// tidak perlu mengisi shiftId dari employee.shift.
  Future<void> markAttendanceDone({required bool isCheckIn}) async {
    final currentUser = user;
    final employee = currentUser?.employee;
    if (currentUser == null || employee == null) return;

    final baseAttendance = employee.attendanceToday ??
        AttendanceModel.empty(
          employeeId: employee.id,
          shiftId: employee.workSchedule?.shiftId ?? '',
        );

    final updatedAttendance = baseAttendance.copyWith(
      checkInTime: isCheckIn ? DateTime.now() : null,
      checkOutTime: !isCheckIn ? DateTime.now() : null,
    );

    final updatedUser = currentUser.copyWith(
      employee: employee.copyWith(attendanceToday: updatedAttendance),
    );
    user = updatedUser;
    await StorageService.saveUser(updatedUser.toJson());
    notifyListeners();
  }

  Future<void> updateAttendanceFromServer(AttendanceModel attendance) async {
    final currentUser = user;
    final employee = currentUser?.employee;
    if (currentUser == null || employee == null) return;

    final updatedUser = currentUser.copyWith(
      employee: employee.copyWith(attendanceToday: attendance),
    );
    user = updatedUser;
    await StorageService.saveUser(updatedUser.toJson());
    notifyListeners();
  }

  Future<void> refreshTodayAttendance() async {
    final currentUser = user;
    final employee = currentUser?.employee;
    if (currentUser == null || employee == null) return;

    try {
      final todayAttendance = await _absenService.getTodayAttendance();
      final updatedUser = currentUser.copyWith(
        employee: employee.withAttendanceToday(todayAttendance),
      );
      user = updatedUser;
      await StorageService.saveUser(updatedUser.toJson());
      notifyListeners();
    } catch (_) {
      // Jangan mengubah state jika sinkronisasi gagal.
    }
  }

  Future<void> updateUserFromServer(UserModel updatedUser) async {
    user = updatedUser;
    await StorageService.saveUser(updatedUser.toJson());
    notifyListeners();
  }
}
