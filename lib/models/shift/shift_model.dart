import 'package:absenpro/helpers/time_helper.dart';

class ShiftModel {
  final String id;
  final String name;
  final String? startTime;
  final String? endTime;
  final String? checkInStart;
  final String? checkInEnd;
  final String? checkOutStart;
  final String? checkOutEnd;
  final int lateToleranceMinutes;

  ShiftModel({
    required this.id,
    required this.name,
    this.startTime,
    this.endTime,
    this.checkInStart,
    this.checkInEnd,
    this.checkOutStart,
    this.checkOutEnd,
    this.lateToleranceMinutes = 0,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
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
      'id': id,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'check_in_start': checkInStart,
      'check_in_end': checkInEnd,
      'check_out_start': checkOutStart,
      'check_out_end': checkOutEnd,
      'late_tolerance_minutes': lateToleranceMinutes,
    };
  }

  /// Contoh tampilan ringkas: "08:00 - 17:00", dipakai di kartu jadwal Home.
  String get jamKerja => TimeHelper.formatTimeRange(startTime, endTime);
}
