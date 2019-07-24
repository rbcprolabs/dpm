import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dpm/src/exceptions.dart';
import 'package:pubspec/pubspec.dart';
import 'package:tuple/tuple.dart';

Future<void> runScript(
  PubSpec pubspec,
  String script, {
  bool allowFail = false,
  Directory workingDir,
}) async {
  final scripts = pubspec.unParsedYaml['scripts'] ?? {};

  if (scripts.containsKey(script)) {
    final lines = scripts[script] is List ? scripts[script] : [scripts[script]];

    for (final line in lines) {
      final result = await runLine(line, workingDir ?? Directory.current);
      final String sout = result.item2.trim(), serr = result.item3.trim();

      if (sout.isNotEmpty) {
        print(sout);
      }

      if (serr.isNotEmpty) {
        stderr.writeln(serr);
      }

      if (result.item1 != 0) {
        throw Exception(
            'Script "$script" failed with exit code ${result.item1}.');
      }
    }
  } else if (!allowFail) {
    throw ScriptDoesNotExistException('Could not find a script '
        'named "$script" in project "${pubspec.name ?? '<untitled>'}".');
  }
}

Future<Tuple3<int, String, String>> runLine(
  String line,
  Directory workingDir,
) async {
  var path = Platform.environment['PATH'];
  final dpmBin = Directory.fromUri(Directory.current.uri.resolve('./.dpm_bin'));

  if (await dpmBin.exists()) {
    path = Platform.isWindows
        ? '${dpmBin.absolute.uri};$path'
        : '"${dpmBin.absolute.uri}":$path';
  }

  final cli = await Process.start(
    Platform.isWindows ? 'cmd' : 'bash',
    [],
    environment: {'PATH': path},
    workingDirectory: workingDir.absolute.path,
  );
  cli.stdin
    ..writeln(line)
    ..writeln('exit 0')
    // ignore: unawaited_futures
    ..flush();

  return Tuple3(
    await cli.exitCode,
    await cli.stdout.transform(Utf8Decoder()).join(),
    await cli.stderr.transform(Utf8Decoder()).join(),
  );
}
