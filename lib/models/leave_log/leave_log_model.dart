class LeaveLogModel {
  final String id;
  final String leaveRequestId;
  final String actorId;
  final String? actorName;
  final String action; // created, submitted, approved, rejected, dst
  final String? note;
  final String? createdAt;

  LeaveLogModel({
    required this.id,
    required this.leaveRequestId,
    required this.actorId,
    this.actorName,
    required this.action,
    this.note,
    this.createdAt,
  });

  factory LeaveLogModel.fromJson(Map<String, dynamic> json) {
    // Sama pola approval: actor_id polos atau nested "actor": {id, name}.
    final actor = json['actor'];
    final actorId = actor is Map
        ? actor['id']?.toString() ?? ''
        : json['actor_id']?.toString() ?? '';
    final actorName = actor is Map ? actor['name']?.toString() : null;

    return LeaveLogModel(
      id: json['id']?.toString() ?? '',
      leaveRequestId: json['leave_request_id']?.toString() ?? '',
      actorId: actorId,
      actorName: actorName,
      action: json['action']?.toString() ?? '',
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_request_id': leaveRequestId,
      'actor_id': actorId,
      'action': action,
      'note': note,
      'created_at': createdAt,
    };
  }
}
