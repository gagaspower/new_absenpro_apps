class PeriodeModel {
  final String periodeValue;
  final String periodeLabel;

  PeriodeModel({required this.periodeValue, required this.periodeLabel});

  factory PeriodeModel.fromJson(Map<String, dynamic> json) {
    return PeriodeModel(
      periodeValue: json['value']?.toString() ?? '',
      periodeLabel: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': periodeValue, 'label': periodeLabel};
  }
}
