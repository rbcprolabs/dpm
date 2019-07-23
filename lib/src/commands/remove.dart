import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpm/src/commands/get.dart';
import 'package:dpm/src/services/logger.dart';
import 'package:pubspec/pubspec.dart';

class RemoveCommand extends Command {
  RemoveCommand() {
    argParser.addFlag(
      'dry-run',
      help: 'Resolves dependencies, and prints the '
          'pubspec, without changing any files.',
      defaultsTo: false,
      negatable: false,
    );
  }

  final GetCommand _get = GetCommand();

  @override
  String get name => 'remove';

  @override
  String get description => 'Remove the specified dependencies '
      'to your pubspec.yaml';

  @override
  Future<void> run() async {
    if (argResults.rest.isEmpty) {
      Logger()
        ..warning('usage: dpm remove [options...] [<packages>]\n')
        ..warning('Options:')
        ..warning(argParser.usage);
      return exit(1);
    } else {
      var pubspec = await PubSpec.load(Directory.current);
      final totalTargetCount = argResults.rest.length;
      final targetDependencies = argResults.rest.cast();

      bool dependencyFilter(dependency, data) {
        if (targetDependencies.contains(dependency)) {
          Logger().success('Successfully deleted $dependency');
          targetDependencies.remove(dependency);
          return true;
        } else {
          return false;
        }
      }

      final Map<String, DependencyReference> dependencies =
          Map.from(pubspec.dependencies)..removeWhere(dependencyFilter);
      final Map<String, DependencyReference> devDependencies =
          Map.from(pubspec.devDependencies)..removeWhere(dependencyFilter);
      pubspec = pubspec.copy(
        dependencies: dependencies,
        devDependencies: devDependencies,
      );

      if (targetDependencies.isNotEmpty) {
        Logger().error(
            'Packages is not installed: ${targetDependencies.join(', ')}');
      }

      if (argResults['dry-run']) {
        return Logger().info(YamlToString().toYamlString(pubspec.toJson()));
      } else if (totalTargetCount != targetDependencies.length) {
        await pubspec.save(Directory.current);
        return _get.run();
      }
    }
  }
}
