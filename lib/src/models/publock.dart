import 'package:dpm/src/models/publock_sdk.dart';
import 'package:yaml/yaml.dart';

import 'package.dart';

class Publock {
  Publock({
    List<PubPackage> packages = const [],
    List<PubLockSdk> sdks = const [],
  }) {
    this..packages.addAll(packages)..sdks.addAll(sdks);
  }

  factory Publock.fromMap(YamlMap data) {
    final packages = <PubPackage>[], sdks = <PubLockSdk>[];

    data['packages'].forEach((name, data) {
      packages.add(PubPackage.fromMap({'name': name}..addAll(data)));
    });

    data['sdks'].forEach((name, version) {
      sdks.add(PubLockSdk(name, version));
    });

    return Publock(
      packages: packages,
      sdks: sdks,
    );
  }

  final List<PubPackage> packages = [];
  final List<PubLockSdk> sdks = [];
}
