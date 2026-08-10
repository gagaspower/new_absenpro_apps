import 'dart:io';

import 'package:absenpro/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:absenpro/models/leave_request_model/leave_request_model.dart';

class LeaveRequestService {
  final ApiService _apiService = ApiService();

  /// Kirim pengajuan cuti/izin. `attachment` opsional, dikirim multipart
  /// kalau user pilih dokumen (`ApiService.post` diasumsikan meneruskan
  /// `data` apa adanya ke Dio, sama seperti `.get()` yang sudah dipakai
  /// di LeaveTypeService — sesuaikan kalau signature ApiService berbeda).
  Future<LeaveRequestModel> submitLeaveRequest(
    LeaveRequestPayload payload, {
    File? attachment,
  }) async {
    try {
      // FormData.fromMap cuma terima String/MultipartFile — num/null di
      // payload.toJson() harus di-stringify dulu, kalau tidak Dio lempar
      // error tipe juga.
      final Map<String, dynamic> fields = payload.toJson().map(
            (key, value) => MapEntry(key, value?.toString() ?? ''),
          );

      if (attachment != null) {
        fields['attachment[]'] = await MultipartFile.fromFile(
          attachment.path,
          filename: attachment.path.split(Platform.pathSeparator).last,
        );
      }

      final formData = FormData.fromMap(fields);

      final response = await _apiService.post(
        'reference/permohonan/cuti',
        formData,
      );

      final raw = response.data;
      if (raw is Map && raw['success'] == true && raw['data'] is Map) {
        return LeaveRequestModel.fromJson(raw['data'] as Map<String, dynamic>);
      }

      final message = raw is Map ? raw['message'] : null;
      throw Exception(message ?? 'Gagal mengajukan cuti/izin.');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }
}
