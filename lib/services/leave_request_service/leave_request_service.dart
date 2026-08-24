import 'dart:io';

import 'package:absenpro/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:absenpro/models/leave_request_model/leave_request_model.dart';

class LeaveRequestHistoryPage {
  final int total;
  final List<LeaveRequestModel> rows;

  LeaveRequestHistoryPage({
    required this.total,
    required this.rows,
  });
}

class LeaveRequestService {
  final ApiService _apiService = ApiService();

  /// Kirim pengajuan cuti/izin.
  /// `attachment` opsional dan dikirim sebagai multipart.
  Future<LeaveRequestModel> submitLeaveRequest(
    LeaveRequestPayload payload, {
    File? attachment,
  }) async {
    try {
      final Map<String, dynamic> fields = payload.toJson().map(
            (key, value) => MapEntry(
              key,
              value?.toString() ?? '',
            ),
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
        return LeaveRequestModel.fromJson(
          raw['data'] as Map<String, dynamic>,
        );
      }

      final message = raw is Map ? raw['message'] : null;

      throw Exception(
        message ?? 'Gagal mengajukan cuti/izin.',
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';

      throw Exception(message);
    }
  }

  Future<LeaveRequestHistoryPage> getHistory({
    String? status,
    String? periode,
    String? leaveTypeCategory,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        'reference/permohonan/cuti',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (status != null && status.isNotEmpty) 'status': status,
          if (periode != null && periode.isNotEmpty) 'periode': periode,
          if (leaveTypeCategory != null && leaveTypeCategory.isNotEmpty)
            'leaveTypeCategory': leaveTypeCategory,
        },
      );

      final body = response.data;

      if (body is Map) {
        final totalRaw = body['total'];

        final total = totalRaw is int
            ? totalRaw
            : int.tryParse(
                  totalRaw?.toString() ?? '',
                ) ??
                0;

        final rows = (body['rows'] as List<dynamic>? ?? [])
            .map(
              (e) => LeaveRequestModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        return LeaveRequestHistoryPage(
          total: total,
          rows: rows,
        );
      }

      throw Exception(
        'Response histori permohonan tidak valid',
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';

      throw Exception(message);
    }
  }
}
