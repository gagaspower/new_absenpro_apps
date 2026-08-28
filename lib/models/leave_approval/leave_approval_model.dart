class LeaveApprovalModel {
  final String id;
  final int? urutan;
  final String status;
  final String? note;
  final String? actedAt;
  final LeaveApprovalRoleModel? role;
  final LeaveApprovalApproverModel? approver;

  LeaveApprovalModel({
    required this.id,
    this.urutan,
    required this.status,
    this.note,
    this.actedAt,
    this.role,
    this.approver,
  });

  factory LeaveApprovalModel.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalModel(
      id: json['id']?.toString() ?? '',
      urutan: json['urutan'] == null
          ? null
          : int.tryParse(json['urutan'].toString()),
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      actedAt: json['acted_at']?.toString(),
      role: json['role'] is Map
          ? LeaveApprovalRoleModel.fromJson(
              Map<String, dynamic>.from(json['role']),
            )
          : null,
      approver: json['approver'] is Map
          ? LeaveApprovalApproverModel.fromJson(
              Map<String, dynamic>.from(json['approver']),
            )
          : null,
    );
  }
}

class LeaveApprovalRoleModel {
  final String id;
  final String namaRole;

  LeaveApprovalRoleModel({
    required this.id,
    required this.namaRole,
  });

  factory LeaveApprovalRoleModel.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalRoleModel(
      id: json['id']?.toString() ?? '',
      namaRole: json['nama_role']?.toString() ?? '',
    );
  }
}

class LeaveApprovalApproverModel {
  final String id;
  final String name;
  final String username;

  LeaveApprovalApproverModel({
    required this.id,
    required this.name,
    required this.username,
  });

  factory LeaveApprovalApproverModel.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalApproverModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}
