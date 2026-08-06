class AttendanceHistoryModel {
  final String id;
  final String
      attendanceDate; // sudah terformat dari backend, mis. "06 Agustus 2026"
  final String? scheduledCheckIn;
  final String? scheduledCheckOut;
  final String? checkInTime; // "HH:mm" atau "-" kalau belum absen
  final String? checkOutTime;
  final String? status; // enum: present, late, permission, leave, sick, absent
  final int lateMinutes;
  final String? notes;
  final double? checkInDistanceMeter;
  final double? checkOutDistanceMeter;

  const AttendanceHistoryModel({
    required this.id,
    required this.attendanceDate,
    this.scheduledCheckIn,
    this.scheduledCheckOut,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.lateMinutes = 0,
    this.notes,
    this.checkInDistanceMeter,
    this.checkOutDistanceMeter,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      id: json['id']?.toString() ?? '',
      attendanceDate: json['attendance_date']?.toString() ?? '-',
      scheduledCheckIn: json['scheduled_check_in'],
      scheduledCheckOut: json['scheduled_check_out'],
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      status: json['status'],
      lateMinutes: json['late_minutes'] ?? 0,
      notes: json['notes'],
      checkInDistanceMeter: _toDouble(json['check_in_distance_meter']),
      checkOutDistanceMeter: _toDouble(json['check_out_distance_meter']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Backend mengirim "-" (bukan null) kalau belum absen masuk/pulang.
  bool get hasCheckedIn => checkInTime != null && checkInTime != '-';
  bool get hasCheckedOut => checkOutTime != null && checkOutTime != '-';
}
