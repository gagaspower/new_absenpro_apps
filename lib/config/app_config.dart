class AppConfig {
  static const String baseUrl =
      "https://somewhere-subdivision-hawk-irrigation.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
