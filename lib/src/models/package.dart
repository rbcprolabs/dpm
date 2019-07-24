import 'dart:async';
import 'dart:io';
import 'package:dpm/src/models/package_description.dart';
import 'package:dpm/src/services/settings.dart';
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

  final String pubCachePath = Settings.pubCachePath;
  final PackageDescription description;
  final String name, source, version;

  Directory get location {
    if (source == 'sdk' && description.sdk == 'flutter') {
      final flutterSdkLocation = Settings().flutterSdkLocation;
      final packagePath =
          Directory(path.join(flutterSdkLocation, 'packages', name));
      if (packagePath.existsSync()) {
        return packagePath;
      }

      final cachePath =
          Directory(path.join(flutterSdkLocation, 'bin', 'cache', 'pkg', name));
      if (cachePath.existsSync()) {
        return cachePath;
      }
      return null;
    } else if (source == 'hosted') {
      return Directory(path.join(
          pubCachePath, 'hosted', 'pub.dartlang.org', '$name-$version'));
    } else if (source == 'git') {
      return Directory(
          path.join(pubCachePath, 'git', '$name-${description.resolvedRef}'));
    } else if (source == 'path') {
      return Directory(
        description.relative
            ? path.join(
                Directory.current.path,
                description.path,
              )
            : description.path,
      );
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
