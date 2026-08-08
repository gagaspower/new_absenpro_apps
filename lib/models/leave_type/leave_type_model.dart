class LeaveTypeModel {
  final String id;
  final String name;
  final String code;
  final String category;
  final String unit;
  final bool isPaid;
  final bool deductQuota;
  final int requireAttachment;
  final int? maxDaysPerYear;
  final int? minDaysNotice;

  LeaveTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.unit,
    required this.isPaid,
    required this.deductQuota,
    required this.requireAttachment,
    this.maxDaysPerYear,
    this.minDaysNotice,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      isPaid: json['is_paid'] ?? false,
      deductQuota: json['deduct_quota'] ?? false,
      requireAttachment: json['requires_attachment'] ?? false,
      maxDaysPerYear: json['max_days_per_year'],
      minDaysNotice: json['min_days_notice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'category': category,
      'unit': unit,
      'is_paid': isPaid,
      'deduct_quota': deductQuota,
      'requires_attachment': requireAttachment,
      'max_days_per_year': maxDaysPerYear,
      'min_days_notice': minDaysNotice
    };
  }
}
