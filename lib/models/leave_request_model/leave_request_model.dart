import 'package:absenpro/models/employee/employee_model.dart';
import 'package:absenpro/models/leave_timeline/leave_timeline_model.dart';
import 'package:absenpro/models/leave_type/leave_type_model.dart';
import 'package:absenpro/models/leave_attachment/leave_attachment_model.dart';
import 'package:absenpro/models/leave_approval/leave_approval_model.dart';
import 'package:absenpro/models/leave_log/leave_log_model.dart';

class LeaveRequestModel {
  final String id;
  final String requestNumber;

  final String employeeId;
  final String leaveTypeId;

  final String startDate;
  final String endDate;
  final num totalDays;

  final String reason;
  final String addressDuringLeave;
  final String phoneDuringLeave;

  final String status;

  final String createdBy;

  final String? appliedAt;
  final String? decidedAt;
  final String? rejectedReason;

  final EmployeeModel? employee;
  final LeaveTypeModel? leaveType;

  final CurrentApproverModel? currentApprover;

  final List<LeaveAttachmentModel> attachments;
  final List<LeaveApprovalModel> approvals;
  final List<LeaveLogModel> logs;
  final List<LeaveTimelineModel> timeline;

  LeaveRequestModel({
    required this.id,
    required this.requestNumber,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.addressDuringLeave,
    required this.phoneDuringLeave,
    required this.status,
    required this.createdBy,
    this.appliedAt,
    this.decidedAt,
    this.rejectedReason,
    this.employee,
    this.leaveType,
    this.currentApprover,
    this.attachments = const [],
    this.approvals = const [],
    this.logs = const [],
    this.timeline = const [],
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id']?.toString() ?? '',
      requestNumber: json['request_number']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      leaveTypeId: json['leave_type_id']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalDays: num.tryParse(json['total_days']?.toString() ?? '') ?? 0,
      reason: json['reason']?.toString() ?? '',
      addressDuringLeave: json['address_during_leave']?.toString() ?? '',
      phoneDuringLeave: json['phone_during_leave']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      appliedAt: json['applied_at']?.toString(),
      decidedAt: json['decided_at']?.toString(),
      rejectedReason: json['rejected_reason']?.toString(),
      employee: json['employee'] is Map
          ? EmployeeModel.fromJson(
              Map<String, dynamic>.from(json['employee']),
            )
          : null,
      leaveType: json['leave_type'] is Map
          ? LeaveTypeModel.fromJson(
              Map<String, dynamic>.from(json['leave_type']),
            )
          : null,
      currentApprover: json['current_approver'] is Map
          ? CurrentApproverModel.fromJson(
              Map<String, dynamic>.from(json['current_approver']),
            )
          : null,
      attachments: json['attachments'] is List
          ? (json['attachments'] as List)
              .whereType<Map>()
              .map(
                (e) => LeaveAttachmentModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const [],
      approvals: json['approvals'] is List
          ? (json['approvals'] as List)
              .whereType<Map>()
              .map(
                (e) => LeaveApprovalModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const [],
      logs: json['logs'] is List
          ? (json['logs'] as List)
              .whereType<Map>()
              .map(
                (e) => LeaveLogModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const [],
      timeline: json['timeline'] is List
          ? (json['timeline'] as List)
              .whereType<Map>()
              .map(
                (e) => LeaveTimelineModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const [],
    );
  }
}

class CurrentApproverModel {
  final String id;
  final String name;

  const CurrentApproverModel({
    required this.id,
    required this.name,
  });

  factory CurrentApproverModel.fromJson(Map<String, dynamic> json) {
    return CurrentApproverModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

/// Payload dikirim ke POST reference/permohonan/cuti.
class LeaveRequestPayload {
  final String leaveTypeId;
  final String startDate;
  final String endDate;
  final num totalDays;
  final String reason;
  final String addressDuringLeave;
  final String phoneDuringLeave;
  final String status;

  LeaveRequestPayload({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.addressDuringLeave,
    required this.phoneDuringLeave,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'total_days': totalDays,
      'reason': reason,
      'address_during_leave': addressDuringLeave,
      'phone_during_leave': phoneDuringLeave,
      'status': status,
    };
  }
}
