import 'dart:io';
import 'package:path/path.dart' as path;

class Settings {
  factory Settings() => _instance;

  Settings._();

  static final Settings _instance = Settings._();

  static String _pubCachePath;

  final _flutterSdkLocation =
      File(path.join(pubCachePath, '.flutter_sdk_location'));

  String get flutterSdkLocation {
    if (Platform.environment.containsKey(['FLUTTER_ROOT'])) {
      return Platform.environment['FLUTTER_ROOT'];
    } else if (!_flutterSdkLocation.existsSync()) {
      return '';
    } else {
      return _flutterSdkLocation.readAsStringSync();
    }
  }

  set flutterSdkLocation(String location) {
    if (!_flutterSdkLocation.existsSync()) {
      _flutterSdkLocation
        ..createSync()
        ..writeAsString(location);
    } else {
      _flutterSdkLocation.writeAsString(location);
    }
  }

  static String get pubCachePath {
    if (_pubCachePath != null) {
      return _pubCachePath;
    }

    if (Platform.isWindows) {
      final appdata = Platform.environment['APPDATA'];
      return _pubCachePath = path.join(appdata, 'Pub', 'Cache');
    }

    final homeDir = Platform.environment['HOME'];
    return _pubCachePath = path.join(homeDir, '.pub-cache');
  }
}
