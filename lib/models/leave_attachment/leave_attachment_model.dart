class LeaveAttachmentModel {
  final String id;
  final String leaveRequestId;
  final String fileName;
  final String filePath;
  final String? fileType;
  final String uploadedBy;
  final String? createdAt;
  final String? updatedAt;

  LeaveAttachmentModel({
    required this.id,
    required this.leaveRequestId,
    required this.fileName,
    required this.filePath,
    this.fileType,
    required this.uploadedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveAttachmentModel.fromJson(Map<String, dynamic> json) {
    return LeaveAttachmentModel(
      id: json['id']?.toString() ?? '',
      leaveRequestId: json['leave_request_id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      filePath: json['file_path']?.toString() ?? '',
      fileType: json['file_type']?.toString(),
      uploadedBy: json['uploaded_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_request_id': leaveRequestId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
