import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpm/src/exceptions.dart';
import 'package:dpm/src/services/logger.dart';
import 'package:http/http.dart' as http;
import 'package:pubspec/pubspec.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tuple/tuple.dart';
import 'package:yamlicious/yamlicious.dart';
import 'get.dart';

final RegExp _gitPkg = RegExp(r'^([^@]+)@git://([^#]+)(#(.+))?$');
final RegExp _pathPkg = RegExp(r'^([^@]+)@path:([^$]+)$');

const String pubApiRoot = 'https://pub.dev/api/packages/';

class AddCommand extends Command {
  AddCommand() {
    argParser
      ..addFlag(
        'dev',
        help: 'Installs the package(s) into dev_dependencies.',
        defaultsTo: false,
        negatable: false,
      )
      ..addFlag(
        'dry-run',
        help: 'Resolves dependencies, and prints the '
            'pubspec, without changing any files.',
        defaultsTo: false,
        negatable: false,
      );
  }

  final http.Client _client = http.Client();
  final GetCommand _get = GetCommand();

  @override
  String get name => 'add';

  @override
  String get description => 'Adds the specified dependencies to your '
      'pubspec.yaml, then runs `dpm get`.';

  @override
  Future<void> run() async {
    if (argResults.rest.isEmpty) {
      Logger()
        ..warning('usage: dpm add [options...] [<packages>]\n')
        ..warning('Options:')
        ..warning(argParser.usage);
      return exit(1);
    } else {
      var pubspec = await PubSpec.load(Directory.current);
      final targetMap = <String, DependencyReference>{};

      for (final dependency in argResults.rest) {
        if (_gitPkg.hasMatch(dependency)) {
          final match = _gitPkg.firstMatch(dependency);
          final dep = resolveGitDep(match);
          targetMap[match.group(1)] = dep;
          if (hasPackageInstalled(pubspec, match.group(1))) {
            packageAlreadyExist(match.group(1));
            return exit(1);
          }
        } else if (_pathPkg.hasMatch(dependency)) {
          final match = _pathPkg.firstMatch(dependency);
          if (hasPackageInstalled(pubspec, match.group(1))) {
            packageAlreadyExist(match.group(1));
            return exit(1);
          }
          targetMap[match.group(1)] = PathReference(match.group(2));
        } else {
          if (hasPackageInstalled(pubspec, dependency)) {
            packageAlreadyExist(dependency);
            return exit(1);
          }
          try {
            final dep = await resolvePubDep(dependency, pubApiRoot);
            targetMap[dep.item1] = dep.item2;
          } on PackageResolveException catch (error) {
            Logger().error(error.message);
            return exit(1);
          }
        }
      }

      _client.close();

      if (!argResults['dev']) {
        final Map<String, DependencyReference> dependencies =
            Map.from(pubspec.dependencies)..addAll(targetMap);
        pubspec = pubspec.copy(dependencies: dependencies);
      } else {
        final Map<String, DependencyReference> devDependencies =
            Map.from(pubspec.devDependencies)..addAll(targetMap);
        pubspec = pubspec.copy(devDependencies: devDependencies);
      }

      if (argResults['dry-run']) {
        return Logger().info(toYamlString(pubspec.toJson()));
        // return Logger().info(YamlToString().toYamlString(pubspec.toJson()));
      } else {
        await pubspec.save(Directory.current);
        Logger().success('Now installing dependencies...');
        return _get.run();
      }
    }
  }

  bool hasPackageInstalled(PubSpec pubspec, String dependency) =>
      pubspec.dependencies.containsKey(dependency) ||
      pubspec.devDependencies.containsKey(dependency);

  void packageAlreadyExist(String dependency) =>
      Logger().warning('Package $dependency already installed');

  GitReference resolveGitDep(Match match) =>
      GitReference(match.group(2), match.group(4));

  /// Install [dependency] from [apiRoot].
  Future<Tuple2<String, DependencyReference>> resolvePubDep(
      String dependency, String apiRoot) async {
    final index = dependency.indexOf('@');
    String name;
    VersionConstraint version;

    if (index > 0 && index < dependency.length - 1) {
      final split = dependency.split('@');
      name = split[0];
      version = VersionConstraint.parse(split[1]);
    } else {
      // Try to auto-detect version...
      final response = await _client.get(Uri().resolve(apiRoot + dependency));

      if (response.statusCode == HttpStatus.notFound) {
        throw PackageResolveException(
            'Unable to resolve package within pub: "$dependency"');
      } else {
        final package = jsonDecode(response.body);
        name = dependency;
        version = VersionConstraint.parse('^' + package['latest']['version']);
      }
    }

    final DependencyReference out = (pubApiRoot == apiRoot)
        ? HostedReference(version)
        : ExternalHostedReference(name, apiRoot, version);

    return Tuple2(name, out);
  }
}
