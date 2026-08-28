import 'package:absenpro/models/leave_approval/leave_approval_model.dart';

class LeaveTimelineModel {
  final String type;
  final String status;
  final int? level;
  final LeaveApprovalRoleModel? role;
  final LeaveApprovalApproverModel? approver;
  final String title;
  final String description;
  final String? note;
  final String? actedAt;

  LeaveTimelineModel({
    required this.type,
    required this.status,
    this.level,
    this.role,
    this.approver,
    required this.title,
    required this.description,
    this.note,
    this.actedAt,
  });

  factory LeaveTimelineModel.fromJson(Map<String, dynamic> json) {
    return LeaveTimelineModel(
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      level:
          json['level'] == null ? null : int.tryParse(json['level'].toString()),
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
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      note: json['note']?.toString(),
      actedAt: json['acted_at']?.toString(),
    );
  }
}
