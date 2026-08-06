import 'package:absenpro/models/attendance_history/attendance_history_model.dart';
import 'package:absenpro/services/api_service.dart';
import 'package:dio/dio.dart';

/// Wrapper hasil paginasi dari backend: total data & isi baris untuk
/// halaman (offset/limit) yang diminta.
class AttendanceHistoryPage {
  final int total;
  final List<AttendanceHistoryModel> rows;

  AttendanceHistoryPage({required this.total, required this.rows});
}

class AttendanceHistoryService {
  final ApiService _apiService = ApiService();

  /// Ambil histori absensi dengan paginasi offset/limit.
  /// Endpoint: GET reference/absen/history
  /// Query: limit, offset, periode (format "M - YYYY", opsional —
  /// kalau tidak dikirim backend pakai bulan/tahun berjalan).
  Future<AttendanceHistoryPage> getHistory({
    String? periode,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        'reference/absen/history',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (periode != null && periode.isNotEmpty) 'periode': periode,
        },
      );

      final body = response.data;
      if (body is Map) {
        final totalRaw = body['total'];
        final total = totalRaw is int
            ? totalRaw
            : int.tryParse(totalRaw?.toString() ?? '') ?? 0;

        final rows = (body['rows'] as List<dynamic>? ?? [])
            .map((e) =>
                AttendanceHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return AttendanceHistoryPage(total: total, rows: rows);
      }

      throw Exception('Response histori absen tidak valid');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }
}
