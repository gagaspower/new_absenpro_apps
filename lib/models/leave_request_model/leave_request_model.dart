import 'package:absenpro/models/employee/employee_model.dart';
import 'package:absenpro/models/leave_type/leave_type_model.dart';
import 'package:absenpro/models/leave_attachment/leave_attachment_model.dart';
import 'package:absenpro/models/leave_approval/leave_approval_model.dart';
import 'package:absenpro/models/leave_log/leave_log_model.dart';

/// Model respon Leave Request (`data` di respon backend).
/// Dipakai setelah submit sukses — buat konfirmasi / riwayat.
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
  final EmployeeModel? employee;
  final LeaveTypeModel? leaveType;
  final List<LeaveAttachmentModel> attachments;
  final List<LeaveApprovalModel> approvals;
  final List<LeaveLogModel> logs;

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
    this.employee,
    this.leaveType,
    this.attachments = const [],
    this.approvals = const [],
    this.logs = const [],
  });

  factory LeaveRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LeaveRequestModel(
      id: json['id']?.toString() ?? '',
      requestNumber: json['request_number']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      leaveTypeId: json['leave_type_id']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalDays: num.tryParse(
            json['total_days']?.toString() ?? '',
          ) ??
          0,
      reason: json['reason'] ?? '',
      addressDuringLeave: json['address_during_leave'] ?? '',
      phoneDuringLeave: json['phone_during_leave'] ?? '',
      status: json['status'] ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      employee: json['employee'] is Map<String, dynamic>
          ? EmployeeModel.fromJson(
              json['employee'] as Map<String, dynamic>,
            )
          : null,
      leaveType: json['leave_type'] is Map<String, dynamic>
          ? LeaveTypeModel.fromJson(
              json['leave_type'] as Map<String, dynamic>,
            )
          : null,
      attachments: json['attachments'] is List
          ? (json['attachments'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (e) => LeaveAttachmentModel.fromJson(e),
              )
              .toList()
          : const [],
      approvals: json['approvals'] is List
          ? (json['approvals'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (e) => LeaveApprovalModel.fromJson(e),
              )
              .toList()
          : const [],
      logs: json['logs'] is List
          ? (json['logs'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (e) => LeaveLogModel.fromJson(e),
              )
              .toList()
          : const [],
    );
  }
}

/// Payload dikirim ke `POST reference/permohonan/cuti`.
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
