import 'package:absenpro/models/periode/periode_model.dart';
import 'package:absenpro/services/api_service.dart';
import 'package:dio/dio.dart';

class PeriodeService {
  final ApiService _apiService = ApiService();

  /// Ambil daftar periode (bulan-tahun) untuk dipakai di dropdown/filter
  /// beberapa menu (misal: Histori Absensi, Laporan, dll).
  /// Endpoint: GET reference/periode
  /// Response: array langsung (bukan dibungkus {status, data}), contoh:
  /// [ { "value": "1 - 2026", "label": "Januari 2026" }, ... ]
  Future<List<PeriodeModel>> getPeriode() async {
    try {
      final response = await _apiService.get('reference/periode');

      final body = response.data;
      if (body is List) {
        return body
            .map((e) => PeriodeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Response periode tidak valid');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }
}
