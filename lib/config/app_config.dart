class AppConfig {
  static const String baseUrl =
      "https://notebooks-retained-char-commissioners.trycloudflare.com/api/";

  /// Base URL untuk file yang disimpan di storage Laravel (foto, dsb).
  /// TODO: sesuaikan/konfirmasi ke backend — asumsi struktur umum Laravel
  /// yaitu domain yang sama tapi path "storage/" bukan "api/".
  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
