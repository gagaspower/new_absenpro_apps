import 'package:absenpro/config/app_config.dart';
import 'package:absenpro/models/attendance/attendance_model.dart';
import 'package:absenpro/models/branch/branch_model.dart';
import 'package:absenpro/models/department/department_model.dart';
import 'package:absenpro/models/face_profile/face_profile_model.dart';
import 'package:absenpro/models/position/position_model.dart';
import 'package:absenpro/models/shift/shift_model.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final bool isActive;
  final List<RoleModel> roles;
  final EmployeeModel? employee;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.isActive,
    required this.roles,
    this.employee,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      employee: json['employee'] != null
          ? EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'is_active': isActive,
      'roles': roles.map((e) => e.toJson()).toList(),
      'employee': employee?.toJson(),
    };
  }

  UserModel copyWith({EmployeeModel? employee}) {
    return UserModel(
      id: id,
      name: name,
      username: username,
      email: email,
      isActive: isActive,
      roles: roles,
      employee: employee ?? this.employee,
    );
  }

  /// Nama role pertama, dipakai untuk tampilan (misal di halaman profil)
  String get roleName => roles.isNotEmpty ? roles.first.namaRole : '-';
}

class RoleModel {
  final String id;
  final String namaRole;

  RoleModel({required this.id, required this.namaRole});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? '',
      namaRole: json['nama_role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama_role': namaRole};
  }
}

/// Data kepegawaian: departemen, jabatan, cabang/wilayah kerja, shift,
/// alamat, dan foto referensi wajah.
class EmployeeModel {
  final String id;
  final String employeeCode;
  final String fullName;
  final String? address;
  final String? photoPath;
  final DepartmentModel? department;
  final PositionModel? position;
  final BranchModel? branch;
  final ShiftModel? shift;
  final FaceProfileModel? faceProfile;
  final AttendanceModel? attendanceToday;

  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    this.address,
    this.photoPath,
    this.department,
    this.position,
    this.branch,
    this.shift,
    this.faceProfile,
    this.attendanceToday,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employee_code'] ?? '',
      fullName: json['full_name'] ?? '',
      address: json['address'],
      photoPath: json['photo_path'],
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      position: json['position'] != null
          ? PositionModel.fromJson(json['position'] as Map<String, dynamic>)
          : null,
      branch: json['branch'] != null
          ? BranchModel.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      shift: json['shift'] != null
          ? ShiftModel.fromJson(json['shift'] as Map<String, dynamic>)
          : null,
      faceProfile: json['face_profile'] != null
          ? FaceProfileModel.fromJson(
              json['face_profile'] as Map<String, dynamic>)
          : null,
      // Backend kadang mengirim data absen hari ini sebagai "attendance_today"
      // atau sebagai "today_attendance". Terima kedua format tersebut.
      attendanceToday:
          (json['attendance_today'] ?? json['today_attendance']) != null
              ? AttendanceModel.fromJson((json['attendance_today'] ??
                  json['today_attendance']) as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'full_name': fullName,
      'address': address,
      'photo_path': photoPath,
      'department': department?.toJson(),
      'position': position?.toJson(),
      'branch': branch?.toJson(),
      'shift': shift?.toJson(),
      'face_profile': faceProfile?.toJson(),
      'attendance_today': attendanceToday?.toJson(),
    };
  }

  EmployeeModel copyWith({
    AttendanceModel? attendanceToday,
    FaceProfileModel? faceProfile,
  }) {
    return EmployeeModel(
      id: id,
      employeeCode: employeeCode,
      fullName: fullName,
      address: address,
      photoPath: photoPath,
      department: department,
      position: position,
      branch: branch,
      shift: shift,
      faceProfile: faceProfile ?? this.faceProfile,
      attendanceToday: attendanceToday ?? this.attendanceToday,
    );
  }

  /// Khusus untuk attendanceToday — SELALU menimpa nilainya, termasuk
  /// jadi null (beda dengan copyWith biasa yang menganggap null = "tidak
  /// diubah"). Dipakai saat sinkron ke server mengembalikan
  /// todayAttendance: null, artinya user memang belum absen hari ini.
  EmployeeModel withAttendanceToday(AttendanceModel? attendanceToday) {
    return EmployeeModel(
      id: id,
      employeeCode: employeeCode,
      fullName: fullName,
      address: address,
      photoPath: photoPath,
      department: department,
      position: position,
      branch: branch,
      shift: shift,
      faceProfile: faceProfile,
      attendanceToday: attendanceToday,
    );
  }

  /// URL foto profil, diprioritaskan dari foto referensi wajah
  /// (face_profile.reference_photo_path), fallback ke photo_path biasa.
  /// Return null kalau dua-duanya belum ada (biar UI bisa fallback ke
  /// placeholder).
  String? get photoUrl {
    final path = faceProfile?.referencePhotoPath ?? photoPath;
    if (path == null || path.isEmpty) return null;
    return '${AppConfig.storageBaseUrl}$path';
  }
}
