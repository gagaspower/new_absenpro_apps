class AppConfig {
  static const String baseUrl =
      "https://hanging-effective-walnut-connect.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
