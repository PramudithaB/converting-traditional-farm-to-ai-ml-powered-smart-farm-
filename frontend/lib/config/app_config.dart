/// Switch between emulator, WiFi, hotspot, and production at run/build time.
///
/// Emulator (default):
///   flutter run
///   flutter run -d emulator-5554
///
/// Physical phone (home WiFi):
///   flutter run --dart-define=USE_WIFI=true
///   flutter build apk --release --dart-define=USE_WIFI=true
///
/// Mobile hotspot:
///   flutter run --dart-define=USE_HOTSPOT=true
///   flutter build apk --release --dart-define=USE_HOTSPOT=true
///
/// Production (DigitalOcean):
///   flutter build apk --release --dart-define=USE_PRODUCTION=true
class AppConfig {
  static const bool _useWifi =
      bool.fromEnvironment('USE_WIFI', defaultValue: false);
  static const bool _useHotspot =
      bool.fromEnvironment('USE_HOTSPOT', defaultValue: false);
  static const bool _useProduction =
      bool.fromEnvironment('USE_PRODUCTION', defaultValue: false);

  static const String laravelBase = _useProduction
      ? 'https://aimlsmartfarm.com'
      : _useHotspot
          ? 'http://192.168.119.142:8000'
          : _useWifi
              ? 'http://192.168.8.101:8000'
              : 'http://10.0.2.2:8000';

  static const String laravelApi = _useProduction
      ? 'https://aimlsmartfarm.com/api'
      : _useHotspot
          ? 'http://192.168.119.142:8000/api'
          : _useWifi
              ? 'http://192.168.8.101:8000/api'
              : 'http://10.0.2.2:8000/api';

  static const String flaskBase = _useProduction
      ? 'https://api.aimlsmartfarm.com'
      : _useHotspot
          ? 'http://192.168.119.142:5000'
          : _useWifi
              ? 'http://192.168.8.101:5000'
              : 'http://10.0.2.2:5000';
}
