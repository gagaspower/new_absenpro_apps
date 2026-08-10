class AppConfig {
  static const String baseUrl =
      "https://others-instructors-discipline-marketplace.trycloudflare.com/api/";

  static String get storageBaseUrl => baseUrl.replaceFirst('api/', 'storage/');
}
