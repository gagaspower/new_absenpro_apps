class AppConfig {
  static const String baseUrl =
      "https://fine-warcraft-rural-concerts.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
