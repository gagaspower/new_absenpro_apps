import 'dart:io';

import 'package:absenpro/models/leave_request_model/leave_request_model.dart';
import 'package:absenpro/services/api_service.dart';
import 'package:dio/dio.dart';

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

  Future<LeaveRequestModel> submitLeaveRequest(
    LeaveRequestPayload payload, {
    File? attachment,
  }) async {
    try {
      final Map<String, dynamic> fields = {};

      final payloadJson = payload.toJson();

      payloadJson.forEach((key, value) {
        fields[key] = value?.toString() ?? '';
      });

      if (attachment != null) {
        fields['attachments[]'] = await MultipartFile.fromFile(
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
          Map<String, dynamic>.from(
            raw['data'] as Map,
          ),
        );
      }

      final message = raw is Map ? raw['message']?.toString() : null;

      throw Exception(
        message != null && message.isNotEmpty
            ? message
            : 'Gagal mengajukan cuti/izin.',
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      String message = 'Tidak dapat terhubung ke server';

      if (responseData is Map) {
        final serverMessage = responseData['message'];

        if (serverMessage != null && serverMessage.toString().isNotEmpty) {
          message = serverMessage.toString();
        } else {
          final errors = responseData['errors'];

          if (errors is Map) {
            final attachmentErrors = errors['attachments'];

            if (attachmentErrors is List && attachmentErrors.isNotEmpty) {
              message = attachmentErrors.first.toString();
            } else {
              final attachmentItemErrors = errors['attachments.0'];

              if (attachmentItemErrors is List &&
                  attachmentItemErrors.isNotEmpty) {
                message = attachmentItemErrors.first.toString();
              }
            }
          }
        }
      }

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
                Map<String, dynamic>.from(
                  e as Map,
                ),
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
      final responseData = e.response?.data;

      String message = 'Tidak dapat terhubung ke server';

      if (responseData is Map) {
        final serverMessage = responseData['message'];

        if (serverMessage != null && serverMessage.toString().isNotEmpty) {
          message = serverMessage.toString();
        }
      }

      throw Exception(message);
    }
  }
}
