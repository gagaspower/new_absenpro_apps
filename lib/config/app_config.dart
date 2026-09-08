class AppConfig {
  static const String baseUrl =
      "https://frontpage-celebrate-became-sic.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
