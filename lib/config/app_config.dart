class AppConfig {
  static const String baseUrl =
      "https://cage-talent-comedy-conference.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
