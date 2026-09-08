/// Info tipe cuti/izin dari `leave.leave_type`. `category` cuma ada 2
/// kemungkinan dari backend: "cuti" atau "izin".
class AttendanceHistoryLeaveTypeModel {
  final String? id;
  final String? name;
  final String? category; // "cuti" atau "izin"

  const AttendanceHistoryLeaveTypeModel({this.id, this.name, this.category});

  factory AttendanceHistoryLeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryLeaveTypeModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      category: json['category']?.toString(),
    );
  }
}

/// Data pengajuan cuti/izin yang menaungi tanggal absen ini (kalau ada).
class AttendanceHistoryLeaveModel {
  final String? id;
  final String? requestNumber;
  final AttendanceHistoryLeaveTypeModel? leaveType;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? reason;

  const AttendanceHistoryLeaveModel({
    this.id,
    this.requestNumber,
    this.leaveType,
    this.startDate,
    this.endDate,
    this.status,
    this.reason,
  });

  factory AttendanceHistoryLeaveModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryLeaveModel(
      id: json['id']?.toString(),
      requestNumber: json['request_number']?.toString(),
      leaveType: json['leave_type'] is Map
          ? AttendanceHistoryLeaveTypeModel.fromJson(
              Map<String, dynamic>.from(json['leave_type'] as Map))
          : null,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      status: json['status']?.toString(),
      reason: json['reason']?.toString(),
    );
  }

  bool get isCuti => leaveType?.category == 'cuti';
  bool get isIzin => leaveType?.category == 'izin';
}

/// Info hari libur nasional/perusahaan dari field `holiday` (kalau
/// `is_holiday` true). Backend belum mengirim contoh lengkap, jadi cuma
/// `name` yang di-parse — field lain aman diabaikan.
class AttendanceHistoryHolidayModel {
  final String? name;

  const AttendanceHistoryHolidayModel({this.name});

  factory AttendanceHistoryHolidayModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryHolidayModel(
      name: (json['name'] ?? json['nama'])?.toString(),
    );
  }
}

class AttendanceHistoryModel {
  final String id;
  final String
      attendanceDate; // sudah terformat dari backend, mis. "06 Agustus 2026"
  final bool isWeekend;
  final bool isHoliday;
  final bool isWorkingDay;
  final AttendanceHistoryHolidayModel? holiday;
  final String? scheduledCheckIn;
  final String? scheduledCheckOut;
  final String? checkInTime; // "HH:mm" atau "-" kalau belum absen
  final String? checkOutTime;
  final String? status; // enum: present, late, permission, leave, sick, absent
  final int lateMinutes;
  final String? notes;
  final double? checkInDistanceMeter;
  final double? checkOutDistanceMeter;
  final AttendanceHistoryLeaveModel? leave;

  const AttendanceHistoryModel({
    required this.id,
    required this.attendanceDate,
    this.isWeekend = false,
    this.isHoliday = false,
    this.isWorkingDay = true,
    this.holiday,
    this.scheduledCheckIn,
    this.scheduledCheckOut,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.lateMinutes = 0,
    this.notes,
    this.checkInDistanceMeter,
    this.checkOutDistanceMeter,
    this.leave,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      id: json['id']?.toString() ?? '',
      attendanceDate: json['attendance_date']?.toString() ?? '-',
      isWeekend: json['is_weekend'] == true,
      isHoliday: json['is_holiday'] == true,
      // Default true supaya kompatibel kalau backend lama belum kirim field ini.
      isWorkingDay: json['is_working_day'] is bool
          ? json['is_working_day'] as bool
          : true,
      holiday: json['holiday'] is Map
          ? AttendanceHistoryHolidayModel.fromJson(
              Map<String, dynamic>.from(json['holiday'] as Map))
          : null,
      scheduledCheckIn: json['scheduled_check_in'],
      scheduledCheckOut: json['scheduled_check_out'],
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      status: json['status'],
      lateMinutes: json['late_minutes'] ?? 0,
      notes: json['notes'],
      checkInDistanceMeter: _toDouble(json['check_in_distance_meter']),
      checkOutDistanceMeter: _toDouble(json['check_out_distance_meter']),
      leave: json['leave'] is Map
          ? AttendanceHistoryLeaveModel.fromJson(
              Map<String, dynamic>.from(json['leave'] as Map))
          : null,
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

  bool get hasLeave => leave != null;

  /// Dipakai UI buat nentuin apakah card ditampilkan pudar/tidak aktif:
  /// bukan hari kerja (libur/weekend) atau lagi cuti/izin.
  bool get isMuted => !isWorkingDay || hasLeave;
}
