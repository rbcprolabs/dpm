import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpm/src/services/publock_loader.dart';
import 'package:dpm/src/services/logger.dart';

final RegExp _file = RegExp(r'^file://');
final String dartPath = Platform.executable;

class LinkCommand extends Command {
  @override
  String get name => 'link';

  @override
  String get description => 'Links installed packages to executables.';

  Future<void> createBashFile(
      Directory bin, String name, String scriptFile) async {
    final file = File.fromUri(bin.uri.resolve('$name'));
    await file
        .writeAsString('#!/usr/bin/env bash\n"$dartPath" "$scriptFile" @*');
    await Process.run('chmod', ['+x', file.path]);
  }

  Future<void> createBatFile(
      Directory bin, String name, String scriptFile) async {
    final file = File.fromUri(bin.uri.resolve('$name.bat'));
    await file.writeAsString('@echo off\n"$dartPath" "$scriptFile" %*');
  }

  @override
  Future<void> run() async {
    final lock = await loadPublock();
    final Directory bin =
        Directory.fromUri(Directory.current.uri.resolve('./.dpm_bin'));
    final packageRoot = Directory.fromUri(bin.uri.resolve('./package-root'));

    if (!await packageRoot.exists()) {
      await packageRoot.create(recursive: true);
    }

    for (final pkg in lock.packages) {
      // Create symlink
      final pubspec = await pkg.readPubspec();
      final link = Link.fromUri(packageRoot.uri.resolve('./${pubspec.name}'));

      if (await link.exists()) {
        await link.delete();
      }

      final uri = pkg.location.absolute.uri
          .resolve('./lib')
          .toString()
          .replaceAll(_file, '');
      await link.create(uri);
    }

    for (final pkg in lock.packages) {
      final pubspec = await pkg.readPubspec();
      final Map executables = pubspec.unParsedYaml['executables'];

      if (executables != null) {
        for (final name in executables.keys) {
          final scriptName =
              executables[name].isNotEmpty ? executables[name] : name;
          final scriptFile =
              File.fromUri(pkg.location.uri.resolve('./bin/$scriptName.dart'));
          final path = scriptFile.absolute.path;

          // Generate snapshot
          final snapshot =
              File.fromUri(pkg.location.uri.resolve('$name.snapshot.dart'));
          final result = await Process.run(Platform.executable, [
            '--snapshot=${snapshot.path}',
            '--package-root=${packageRoot.path}',
            path
          ]);

          if (result.stderr.isNotEmpty) {
            stderr.writeln(result.stderr);
            throw Exception("Could not create snapshot for package '$name'.");
          }

          // Create script files
          await createBashFile(bin, name, snapshot.absolute.path);
          await createBatFile(bin, name, snapshot.absolute.path);
          Logger().success('Successfully linked executables.');
        }
      }
    }
  }
}
