import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:console/console.dart';
import 'package:dpm/src/services/logger.dart';
import 'package:register/register.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec/pubspec.dart';
import 'package:dpm/src/services/publock_loader.dart';
import 'get.dart';

class InitCommand extends Command {
  InitCommand() {
    argParser
      ..addFlag(
        'y',
        help: 'Allow all default values',
        defaultsTo: false,
        negatable: false,
      );
  }

  final GetCommand _get = GetCommand();

  @override
  String get name => 'init';

  @override
  String get description => 'Generates a `pubspec.yaml` file in the current '
      'directory, after a series of prompts.';

  @override
  Future<void> run() async {
    if (pubspecFile.existsSync()) {
      Logger().error('`pubspec.yaml` already exists in '
          '${Directory.current.absolute.uri}.');
      exit(1);
    }

    Logger()
      ..info('This utility will walk you through creating a pubspec.yaml file.')
      ..info(' It only covers the most common items, and tries to guess '
          'sensible defaults.\n')
      ..info('Use `dpm install <pkg>` afterwards to install a package and ')
      ..info('save it as a dependency in the pubspec.yaml file.');

    final pubspec = {};

    await promptField(pubspec, 'name', defaultValue: defaultName);
    await promptField(pubspec, 'version', defaultValue: '0.0.1');
    await promptField(pubspec, 'description');
    await promptField(pubspec, 'author', defaultValue: Platform.localHostname);

    String gitUrl;

    try {
      final result = await Process.run('git', ['remote', 'get-url', 'origin']);

      if (result.exitCode == 0) {
        final stdout = await result.stdout.trim();

        if (stdout.isNotEmpty) {
          gitUrl = stdout;
        }
      }
    } catch (_) {}

    await promptField(pubspec, 'homepage', defaultValue: gitUrl);

    Logger().info('About to write to ${pubspecFile.absolute.path}:');

    final result = await readInput('Is this ok? (yes) ');

    if (result.toLowerCase().startsWith('y') || result.trim().isEmpty) {
      final ps = PubSpec.fromJson(pubspec);
      await ps.save(Directory.current);
    }

    await _get.run();
  }

  String get defaultName =>
      idFromString(path.basename(Directory.current.path).replaceAll('-', '_'))
          .snake;

  Future<void> promptField(
    Map pubspec,
    String field, {
    String defaultValue,
  }) async {
    final value = !argResults['y']
        ? await readInput(
            defaultValue != null ? '$field ($defaultValue): ' : '$field: ')
        : null;

    if (value.isNotEmpty) {
      pubspec[field] = value;
    } else if (defaultValue != null) {
      pubspec[field] = defaultValue;
    }
  }
}
