import 'package:absenpro/helpers/time_helper.dart';

class WorkScheduleModel {
  final String source; // 'shift' | 'branch_schedule'
  final String? shiftId;
  final String? shiftName;
  final String? assignmentId;
  final String? branchScheduleId;
  final String? branchScheduleDayId;
  final String? startTime;
  final String? endTime;
  final String? checkInStart;
  final String? checkInEnd;
  final String? checkOutStart;
  final String? checkOutEnd;
  final int lateToleranceMinutes;

  WorkScheduleModel({
    required this.source,
    this.shiftId,
    this.shiftName,
    this.assignmentId,
    this.branchScheduleId,
    this.branchScheduleDayId,
    this.startTime,
    this.endTime,
    this.checkInStart,
    this.checkInEnd,
    this.checkOutStart,
    this.checkOutEnd,
    this.lateToleranceMinutes = 0,
  });

  factory WorkScheduleModel.fromJson(Map<String, dynamic> json) {
    return WorkScheduleModel(
      source: json['source']?.toString() ?? 'branch_schedule',
      shiftId: json['shift_id']?.toString(),
      shiftName: json['shift_name']?.toString(),
      assignmentId: json['assignment_id']?.toString(),
      branchScheduleId: json['branch_schedule_id']?.toString(),
      branchScheduleDayId: json['branch_schedule_day_id']?.toString(),
      startTime: TimeHelper.formatTime(json['start_time']),
      endTime: TimeHelper.formatTime(json['end_time']),
      checkInStart: TimeHelper.formatTime(json['check_in_start']),
      checkInEnd: TimeHelper.formatTime(json['check_in_end']),
      checkOutStart: TimeHelper.formatTime(json['check_out_start']),
      checkOutEnd: TimeHelper.formatTime(json['check_out_end']),
      lateToleranceMinutes: json['late_tolerance_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'shift_id': shiftId,
      'shift_name': shiftName,
      'assignment_id': assignmentId,
      'branch_schedule_id': branchScheduleId,
      'branch_schedule_day_id': branchScheduleDayId,
      'start_time': startTime,
      'end_time': endTime,
      'check_in_start': checkInStart,
      'check_in_end': checkInEnd,
      'check_out_start': checkOutStart,
      'check_out_end': checkOutEnd,
      'late_tolerance_minutes': lateToleranceMinutes,
    };
  }

  bool get isFromShift => source == 'shift';
  bool get isFromBranchSchedule => source == 'branch_schedule';

  /// Nama tampilan: nama shift kalau source "shift", fallback "Jadwal
  /// Cabang" kalau source "branch_schedule" (memang gak punya nama sendiri).
  String get displayName => isFromShift ? (shiftName ?? '-') : 'Jadwal Cabang';

  /// ID acuan unik jadwal ini, beda tergantung source.
  String? get referenceId => isFromShift ? shiftId : branchScheduleDayId;

  /// Contoh tampilan ringkas: "08:00 - 17:00", dipakai di kartu jadwal Home.
  String get jamKerja => TimeHelper.formatTimeRange(startTime, endTime);
}
