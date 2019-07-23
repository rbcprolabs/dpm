import 'dart:async';
import 'dart:io';
import 'package:dpm/src/models/publock.dart';
import 'package:yaml/yaml.dart';

final File lockFile =
    File.fromUri(Directory.current.uri.resolve('./pubspec.lock'));
final File pubspecFile =
    File.fromUri(Directory.current.uri.resolve('./pubspec.yaml'));

Future<Publock> loadPublock() async =>
    Publock.fromMap(loadYaml(await lockFile.readAsString()));
