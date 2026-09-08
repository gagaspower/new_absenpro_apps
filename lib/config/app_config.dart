class AppConfig {
  static const String baseUrl =
      "https://gray-warrant-thus-patch.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
