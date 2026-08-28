class AppConfig {
  static const String baseUrl =
      "https://linking-highway-boot-trip.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
