// Google Maps config. Keep web key in dart-define; native keys are injected
// through Android manifest placeholders and iOS Info.plist.
class GoogleMapsConfig {
  static const String apiKey =
      String.fromEnvironment('GOOGLE_MAPS_WEB_API_KEY', defaultValue: '');

  static const double defaultZoom = 13.0;
  static const double barZoom = 16.0;

  // Default coordinates (Paris)
  static const double defaultLatitude = 48.8566;
  static const double defaultLongitude = 2.3522;
}
