import 'package:meta/meta.dart';

class PackageDescription {
  PackageDescription({
    @required this.name,
    @required this.url,
    @required this.resolvedRef,
  });

  factory PackageDescription.fromMap(Map data) => PackageDescription(
        name: data['name'],
        url: data['url'],
        resolvedRef: data['resolved-ref'],
      );

  final String name, url, resolvedRef;

  Map<String, String> toJson() => {
        'name': name,
        'url': url,
        'resolved-ref': resolvedRef,
      };
}
