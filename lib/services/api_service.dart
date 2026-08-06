import 'package:absenpro/config/app_config.dart';
import 'package:absenpro/services/navigation_service.dart';
import 'package:absenpro/services/storage_service.dart';
import 'package:dio/dio.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          /// 🔥 DEBUG REQUEST
          // print("➡️ REQUEST:");
          // print("URL: ${options.baseUrl}${options.path}");
          // print("QUERY: ${options.queryParameters}");
          // print("HEADERS: ${options.headers}");

          return handler.next(options);
        },
        onResponse: (response, handler) {
          /// 🔥 DEBUG RESPONSE
          // print("✅ RESPONSE:");
          // print("STATUS: ${response.statusCode}");
          // print("DATA: ${response.data}");

          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // print("❌ ERROR:");
          // print("MESSAGE: ${e.message}");

          if (e.response != null) {
            // print("STATUS: ${e.response?.statusCode}");
            // print("DATA: ${e.response?.data}");

            /// 🔥 HANDLE TOKEN EXPIRED / REVOKE
            if (e.response?.statusCode == 401) {
              print("🔐 TOKEN EXPIRED / UNAUTHORIZED");

              /// 🔥 CLEAR STORAGE
              await StorageService.clear();

              /// 🔥 REDIRECT KE LOGIN
              /// Pakai navigatorKey global + named route supaya bisa
              /// navigasi dari sini (di luar widget tree / tanpa BuildContext),
              /// dan hindari nyangkut di halaman yang butuh sesi (Dashboard, dst).
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  /// ============================
  /// GET
  /// ============================
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// ============================
  /// POST
  /// ============================
  /// [options] opsional — dipakai misal untuk override Content-Type jadi
  /// multipart/form-data saat kirim FormData (upload file).
  Future<Response> post(String endpoint, dynamic data,
      {Options? options}) async {
    try {
      return await dio.post(endpoint, data: data, options: options);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// ============================
  /// PUT
  /// ============================
  Future<Response> put(String endpoint, dynamic data) async {
    try {
      return await dio.put(endpoint, data: data);
    } on DioException catch (e) {
      _handleError(e);
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  /// ============================
  /// DELETE
  /// ============================
  Future<Response> delete(String endpoint) async {
    try {
      return await dio.delete(endpoint);
    } on DioException catch (e) {
      _handleError(e);
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  /// ============================
  /// ERROR HANDLER
  /// ============================
  void _handleError(DioException e) {
    print("❌ DIO ERROR DETAIL:");
    print("TYPE: ${e.type}");
    print("MESSAGE: ${e.message}");

    if (e.response != null) {
      print("STATUS CODE: ${e.response?.statusCode}");
      print("RESPONSE: ${e.response?.data}");
    }
  }
}
