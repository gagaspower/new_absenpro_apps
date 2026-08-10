class AppConfig {
  static const String baseUrl =
      "https://centuries-lodge-quiet-beverage.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
