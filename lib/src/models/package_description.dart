import 'package:yaml/yaml.dart';

// TODO(Serge): Split descriptions by type
class PackageDescription {
  PackageDescription({
    this.sdk,
    this.name,
    this.url,
    this.resolvedRef,
    this.path,
    this.relative,
  });

  factory PackageDescription.fromMap(data) {
    if (data is String) {
      // flutter sdk dependency
      return PackageDescription(
        sdk: data,
      );
    } else if (data is YamlMap) {
      return PackageDescription(
        name: data['name'],
        url: data['url'],
        resolvedRef: data['resolved-ref'],
        path: data['path'],
        relative: data['relative'],
      );
    } else {
      throw UnsupportedError('Unsupported format $data');
    }
  }

  final String sdk, name, url, resolvedRef, path;
  bool relative;

  Map<String, String> toJson() => {
        'name': name,
        'url': url,
        'resolved-ref': resolvedRef,
        'path': path,
        'relative': relative.toString(),
      };
}
