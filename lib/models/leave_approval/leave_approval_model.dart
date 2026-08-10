class LeaveApprovalModel {
  final String id;
  final String leaveRequestId;
  final String approverId;
  final String? approverName;
  final int level;
  final String status; // pending, approved, rejected, skipped
  final String? note;
  final String? respondedAt;
  final String? createdAt;
  final String? updatedAt;

  LeaveApprovalModel({
    required this.id,
    required this.leaveRequestId,
    required this.approverId,
    this.approverName,
    required this.level,
    required this.status,
    this.note,
    this.respondedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveApprovalModel.fromJson(Map<String, dynamic> json) {
    // Backend bisa kirim approver_id sebagai id polos, atau nested object
    // "approver": {"id":.., "name":..} — tangani dua-duanya.
    final approver = json['approver'];
    final approverId = approver is Map
        ? approver['id']?.toString() ?? ''
        : json['approver_id']?.toString() ?? '';
    final approverName = approver is Map ? approver['name']?.toString() : null;

    return LeaveApprovalModel(
      id: json['id']?.toString() ?? '',
      leaveRequestId: json['leave_request_id']?.toString() ?? '',
      approverId: approverId,
      approverName: approverName,
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      respondedAt: json['responded_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_request_id': leaveRequestId,
      'approver_id': approverId,
      'level': level,
      'status': status,
      'note': note,
      'responded_at': respondedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
