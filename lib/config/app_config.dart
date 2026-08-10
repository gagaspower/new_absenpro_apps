class AppConfig {
  static const String baseUrl =
      "https://programmes-falls-issue-euros.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
