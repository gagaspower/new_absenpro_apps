class AppConfig {
  static const String baseUrl =
      "https://regime-accountability-coral-rolls.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
