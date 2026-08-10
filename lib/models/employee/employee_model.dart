bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return true;
}

class EmployeeModel {
  final String id;
  final String userId;
  final String employeeCode;
  final String fullName;
  final String? phone;
  final String? gender;
  final String? birthPlace;
  final String? birthDate;
  final String? address;
  final String? departmentId;
  final String? positionId;
  final String? branchId;
  final String? shiftId;
  final String? joinDate;
  final String employeeStatus;
  final String? photoPath;
  final bool isActive;

  EmployeeModel({
    required this.id,
    required this.userId,
    required this.employeeCode,
    required this.fullName,
    this.phone,
    this.gender,
    this.birthPlace,
    this.birthDate,
    this.address,
    this.departmentId,
    this.positionId,
    this.branchId,
    this.shiftId,
    this.joinDate,
    required this.employeeStatus,
    this.photoPath,
    this.isActive = true,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      birthPlace: json['birth_place']?.toString(),
      birthDate: json['birth_date']?.toString(),
      address: json['address']?.toString(),
      departmentId: json['department_id']?.toString(),
      positionId: json['position_id']?.toString(),
      branchId: json['branch_id']?.toString(),
      shiftId: json['shift_id']?.toString(),
      joinDate: json['join_date']?.toString(),
      employeeStatus: json['employee_status']?.toString() ?? '',
      photoPath: json['photo_path']?.toString(),
      isActive: json['is_active'] == null ? true : _toBool(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_code': employeeCode,
      'full_name': fullName,
      'phone': phone,
      'gender': gender,
      'birth_place': birthPlace,
      'birth_date': birthDate,
      'address': address,
      'department_id': departmentId,
      'position_id': positionId,
      'branch_id': branchId,
      'shift_id': shiftId,
      'join_date': joinDate,
      'employee_status': employeeStatus,
      'photo_path': photoPath,
      'is_active': isActive,
    };
  }
}
