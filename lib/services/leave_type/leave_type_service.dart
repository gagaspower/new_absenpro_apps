import 'package:absenpro/services/api_service.dart';
import 'package:absenpro/models/leave_type/leave_type_model.dart';
import 'package:dio/dio.dart';

class LeaveTypeService {
  final ApiService _apiService = ApiService();

  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    try {
      final response = await _apiService.get('reference/jenis-cuti');
      print(response.data);

      final body = response.data.data;
      if (body is List) {
        return body
            .map((e) => LeaveTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Response jenis cuti tidak valid');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Terjadi kesalahan, coba lagi')
          : 'Tidak dapat terhubung ke server';
      throw Exception(message);
    }
  }
}
