class FaceProfileModel {
  final String id;
  final String employeeId;
  final String referencePhotoPath;

  FaceProfileModel({
    required this.id,
    required this.employeeId,
    required this.referencePhotoPath,
  });

  factory FaceProfileModel.fromJson(Map<String, dynamic> json) {
    return FaceProfileModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      referencePhotoPath: json['reference_photo_path'] ?? '',
      // NOTE: field "face_embedding" sengaja tidak di-parse di sini —
      // datanya array angka yang sangat panjang dan tidak dibutuhkan
      // untuk kebutuhan tampilan (hanya dipakai di sisi backend untuk
      // pencocokan wajah).
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'reference_photo_path': referencePhotoPath,
    };
  }
}
