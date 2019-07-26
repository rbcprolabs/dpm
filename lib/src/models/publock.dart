import 'package:yaml/yaml.dart';

import 'package.dart';

class Publock {
  Publock({
    this.packages = const {},
    this.sdks = const {},
  });

  factory Publock.fromMap(YamlMap data) {
    final packages = <String, PubPackage>{};
    final sdks = <String, String>{};

    (data['packages'] as YamlMap).forEach((name, data) {
      packages[name] = PubPackage.fromMap({'name': name, ...data});
    });

    (data['sdks'] as YamlMap).forEach((name, version) {
      sdks[name] = version;
    });

    return Publock(
      packages: packages,
      sdks: sdks,
    );
  }

  final Map<String, PubPackage> packages;
  final Map<String, String> sdks;
}
