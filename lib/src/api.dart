import 'dart:convert';

import 'package:dpm/src/exceptions.dart';
import 'package:http/http.dart' as http;

const pubUrlBase = 'https://pub.dev';
const searchUrl = '$pubUrlBase/api/search';
const viewUrl = '$pubUrlBase/api/packages';

Future<SearchResult> searchPackages(String query) async {
  final searchJson = jsonDecode(await http.read('$searchUrl?q=$query')) as Map;
  final packagesJson = searchJson['packages'] as List<dynamic>;
  final packageInfos = await Future.wait(packagesJson
      .where((json) => !json['package'].toString().startsWith('dart:'))
      .map((json) => fetchPackageInfo(json['package'])));

  return SearchResult(packages: packageInfos);
}

Future<PackageInfo> fetchPackageInfo(
  String packageName, {
  bool fullParse = false,
}) async {
  final response = await http.get('$viewUrl/$packageName');

  // Dumb error handling
  if (response.statusCode == 404) {
    throw Errors.packageNotFound(packageName);
  } else if (response.statusCode < 200 || response.statusCode > 299) {
    throw http.ClientException('response.statusCode: ${response.statusCode}');
  }

  final packageJson = jsonDecode(response.body);
  return PackageInfo.fromMap(packageJson, parseAllVersions: fullParse);
}

class SearchResult {
  SearchResult({this.packages});
  final List<PackageInfo> packages;
}

class PackageInfo {
  PackageInfo({this.name, this.versions});

  factory PackageInfo.fromMap(
    Map<String, dynamic> packageJson, {
    bool parseAllVersions = false,
  }) {
    final Iterable<dynamic> pubspecsJson = parseAllVersions
        ? packageJson['versions'].map((versionJson) => versionJson['pubspec'])
        : [packageJson['latest']['pubspec']];

    final package = PackageInfo(
      name: packageJson['name'],
      versions: pubspecsJson.map((json) => PackageInfoVersion.fromMap(json)),
    );

    return package;
  }

  final String name;
  final List<PackageInfoVersion> versions;

  String get version => latest.version;
  List<String> get authors => latest.authors;
  String get author => latest.author;
  String get description => latest.description;
  String get url => '$pubUrlBase/packages/$name';
  PackageInfoVersion get latest => versions.last;
}

class PackageInfoVersion {
  PackageInfoVersion({
    this.version,
    this.author,
    this.authors,
    this.description,
  });
  factory PackageInfoVersion.fromMap(Map<String, dynamic> json) =>
      PackageInfoVersion(
          version: json['version'],
          authors: List.from(json['authors']),
          author: json['author'],
          description: json['description']);

  final String version;
  final String author;
  final List<String> authors;
  final String description;
}
