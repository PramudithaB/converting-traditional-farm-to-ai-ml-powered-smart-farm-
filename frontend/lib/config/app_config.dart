/// Switch between emulator and physical device (WiFi) at run/build time.
///
/// Emulator (default):
///   flutter run
///   flutter run -d emulator-5554
///
/// Physical phone (WiFi):
///   flutter run --dart-define=USE_WIFI=true
///   flutter build apk --release --dart-define=USE_WIFI=true
class AppConfig {
  static const bool _useWifi =
      bool.fromEnvironment('USE_WIFI', defaultValue: false);

  /// Host IP: 10.0.2.2 for emulator, 192.168.8.100 for WiFi/phone
  static const String host = _useWifi ? '192.168.8.100' : '10.0.2.2';

  static const String laravelBase = 'http://$host:8000';
  static const String laravelApi  = 'http://$host:8000/api';
  static const String flaskBase   = 'http://$host:5000';
}
