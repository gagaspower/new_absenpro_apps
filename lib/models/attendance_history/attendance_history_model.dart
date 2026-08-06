class AttendanceHistoryModel {
  final String id;
  final String
      attendanceDate; // format: "5 Agustus 2026" (display), atau bisa DateTime
  final String? checkInTime; // format "HH:mm"
  final String? checkOutTime; // format "HH:mm"
  final String? status; // "present", "late", "absent", dsb
  final int lateMinutes;

  const AttendanceHistoryModel({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.lateMinutes = 0,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    // Asumsi: backend mengirim data absensi per-hari dalam format sesuai
    // response yang ditampilkan. Bisa disesuaikan kalau structure-nya beda.
    return AttendanceHistoryModel(
      id: json['id']?.toString() ?? '',
      attendanceDate: _formatDate(json['attendance_date']),
      checkInTime: _formatTime(json['check_in_time']),
      checkOutTime: _formatTime(json['check_out_time']),
      status: json['status'],
      lateMinutes: json['late_minutes'] ?? 0,
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return '-';
    // TODO: kalau backend kirim ISO format, parse & ubah ke "5 Agustus 2026"
    // Untuk sekarang asumsikan sudah formatted dari backend.
    return date.toString();
  }

  static String? _formatTime(dynamic time) {
    if (time == null) return null;
    final value = time.toString();
    if (value.length >= 5) return value.substring(0, 5);
    return value;
  }

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;
}
