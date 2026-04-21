/// Switch between emulator, WiFi, and mobile hotspot at run/build time.
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
class AppConfig {
  static const bool _useWifi =
      bool.fromEnvironment('USE_WIFI', defaultValue: false);
  static const bool _useHotspot =
      bool.fromEnvironment('USE_HOTSPOT', defaultValue: false);

  /// Host IP:
  ///   10.0.2.2        — Android emulator
  ///   192.168.8.100   — Home WiFi / physical device
  ///   192.168.119.142 — Mobile hotspot
  static const String host = _useHotspot
      ? '192.168.119.142'
      : _useWifi
          ? '192.168.8.101'
          : '10.0.2.2';

  static const String laravelBase = 'http://$host:8000';
  static const String laravelApi  = 'http://$host:8000/api';
  static const String flaskBase   = 'http://$host:5000';
}
