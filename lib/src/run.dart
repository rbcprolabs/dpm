import 'dart:async';
import 'dart:io';
import 'package:dpm/src/exceptions.dart';
import 'package:dpm/src/models/publock.dart';
import 'package:dpm/src/services/publock_loader.dart';
import 'package:dpm/src/utils.dart';
import 'package:pubspec/pubspec.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

Future<void> runScript(
  PubSpec pubspec,
  String script, {
  List<String> args = const [],
  bool allowFail = false,
  Directory workingDir,
}) async {
  final scripts = pubspec.unParsedYaml['scripts'] ?? {};

  if (scripts.containsKey(script)) {
    print('run local script $script');
    final List<String> lines =
        scripts[script] is List ? scripts[script] : [scripts[script]];

    for (final line in lines) {
      final splittedScriptLine = line.split(' ');
      final program = splittedScriptLine.first;
      splittedScriptLine.removeAt(0);

      final process = await Process.start(
        program,
        splittedScriptLine,
        workingDirectory: (workingDir ?? Directory.current).absolute.path,
        runInShell: true,
      );
      await stdout.addStream(process.stdout);
      await stderr.addStream(process.stderr);
    }
  } else if (pubspec.devDependencies.containsKey(split1(script, ':')[0])) {
    final package = split1(script, ':');
    print('run dev package ${package.first}');

    final program =
        await _packageExecutable(package.first, executable: package.last);

    final process = await Process.start(
      program.first,
      (program..removeAt(0)) + args,
      workingDirectory: (workingDir ?? Directory.current).absolute.path,
      runInShell: true,
    );
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);
  } else if (!allowFail) {
    throw Errors.scriptDoesNotExis(script, pubspec.name);
  }
}

Future<List<String>> _packageExecutable(
  String package, {
  String executable,
  Publock publock,
}) async {
  final lock = publock ?? await loadPublock();
  final packageDir = lock.packages[package].location;
  final pubSpec = await PubSpec.load(packageDir);
  if (!(pubSpec.unParsedYaml['executables'] is YamlMap)) {
    return [package];
  }
  if (pubSpec.unParsedYaml['executables'][executable ?? package] == null) {
    throw Errors.simple('Could not find a executable '
        'named "$executable" in package "$package".');
  }
  return [
    'dart',
    path.join(packageDir.path, 'bin\\',
        pubSpec.unParsedYaml['executables'][executable ?? package] + '.dart')
  ];
}
