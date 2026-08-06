import 'package:absenpro/helpers/time_helper.dart';

class AttendanceModel {
  final String id;
  final String employeeId;
  final String shiftId;
  final DateTime? attendanceDate;
  final String?
      scheduledCheckIn; // format "HH:mm" (sudah dipotong dari HH:mm:ss)
  final String? scheduledCheckOut;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? status;
  final int lateMinutes;
  final String? notes;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.shiftId,
    this.attendanceDate,
    this.scheduledCheckIn,
    this.scheduledCheckOut,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.lateMinutes = 0,
    this.notes,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      shiftId: json['shift_id']?.toString() ?? '',
      attendanceDate: _parseDate(json['attendance_date']),
      scheduledCheckIn: TimeHelper.formatTime(json['scheduled_check_in']),
      scheduledCheckOut: TimeHelper.formatTime(json['scheduled_check_out']),
      checkInTime: _parseDate(json['check_in_time']),
      checkOutTime: _parseDate(json['check_out_time']),
      status: json['status'],
      lateMinutes: json['late_minutes'] ?? 0,
      notes: json['notes'],
      // NOTE: field foto/skor/lokasi/device/method absen (check_in_photo_path,
      // check_in_score, check_in_face_verified, dst) sengaja belum di-parse —
      // belum ada kebutuhan tampilan untuk itu. Tinggal ditambah kalau nanti
      // perlu, misal buat halaman detail histori absen hari ini.
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'shift_id': shiftId,
      'attendance_date': attendanceDate?.toIso8601String(),
      'scheduled_check_in': scheduledCheckIn,
      'scheduled_check_out': scheduledCheckOut,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'status': status,
      'late_minutes': lateMinutes,
      'notes': notes,
    };
  }

  AttendanceModel copyWith({
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
  }) {
    return AttendanceModel(
      id: id,
      employeeId: employeeId,
      shiftId: shiftId,
      attendanceDate: attendanceDate,
      scheduledCheckIn: scheduledCheckIn,
      scheduledCheckOut: scheduledCheckOut,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      lateMinutes: lateMinutes,
      notes: notes,
    );
  }

  /// Dipakai saat belum ada data absen sama sekali hari ini (baru login,
  /// belum absen masuk) — lalu di-update lokal lewat copyWith begitu user
  /// berhasil absen, supaya tombol langsung ke-lock tanpa nunggu login ulang.
  factory AttendanceModel.empty({
    required String employeeId,
    required String shiftId,
  }) {
    return AttendanceModel(id: '', employeeId: employeeId, shiftId: shiftId);
  }

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
