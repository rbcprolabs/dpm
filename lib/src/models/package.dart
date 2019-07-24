import 'dart:async';
import 'dart:io';
import 'package:dpm/src/models/package_description.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec/pubspec.dart';

class PubPackage {
  PubPackage({
    @required this.name,
    @required this.description,
    @required this.source,
    @required this.version,
  });

  factory PubPackage.fromMap(Map data) => PubPackage(
        name: data['name'],
        description: PackageDescription.fromMap(data['description']),
        source: data['source'],
        version: data['version'],
      );

  static String _pubCachePath;
  final PackageDescription description;
  final String name, source, version;

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

  // TODO(Serge): provide support for [path] dependencies
  Directory get location {
    if (source == 'hosted') {
      return Directory(path.join(
          pubCachePath, 'hosted', 'pub.dartlang.org', '$name-$version'));
    } else if (source == 'git') {
      return Directory(
          path.join(pubCachePath, 'git', '$name-${description.resolvedRef}'));
    } else {
      throw UnsupportedError(
          'Unsupported source for package $name in pubspec.lock: $source');
    }
  }

  Future<PubSpec> readPubspec() => PubSpec.load(location);

  Map<String, Object> toJson() => {
        'name': name,
        'description': description.toJson(),
        'source': source,
        'version': version
      };
}
