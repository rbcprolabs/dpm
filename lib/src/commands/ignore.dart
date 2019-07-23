import 'dart:async';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpm/src/services/logger.dart';

class IgnoreCommand extends Command {
  IgnoreCommand() {
    argParser
      ..addOption(
        'filename',
        help: 'The name of the ignore file to write to.',
        defaultsTo: '.gitignore',
      );
  }

  static const String _contents = '.dpm_bin/';

  @override
  String get name => 'ignore';

  @override
  String get description => 'Adds .dpm_bin/ to your VCS ignore file.';

  @override
  Future<void> run() async {
    final ignoreFile =
        File.fromUri(Directory.current.uri.resolve(argResults['filename']));

    if (!ignoreFile.existsSync()) {
      await ignoreFile.writeAsString(_contents);
      Logger().success('Success create ignore file');
      return;
    }

    final contents = await ignoreFile.readAsString();

    if (!contents.contains(_contents)) {
      final sink = ignoreFile.openWrite(mode: FileMode.append)
        ..writeln(_contents);
      await sink.close();
      Logger().success('Success appended to ignore file');
    }
  }
}
