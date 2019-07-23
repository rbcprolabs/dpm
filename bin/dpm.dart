import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:pubspec/pubspec.dart';
import 'package:dpm/dpm.dart';

void main(List<String> args) async {
  final runner = CommandRunner(
      'dpm', 'Run commands upon installing Dart packages, and more.')
    ..addCommand(CleanCommand())
    ..addCommand(GetCommand())
    ..addCommand(IgnoreCommand())
    ..addCommand(InitCommand())
    ..addCommand(AddCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(LinkCommand())
    ..addCommand(ResetCommand())
    ..addCommand(UpgradeCommand());

  try {
    await runner.run(args);
  } catch (exception) {
    if (exception is UsageException) {
      final pubspec = await PubSpec.load(Directory.current);

      for (final arg in args) {
        try {
          await runScript(pubspec, arg);
        } on ScriptDoesNotExistException catch (exception) {
          stderr.writeln(exception.message);
          return exit(1);
        } catch (_exception, stackTrace) {
          stderr..writeln('ERR: $_exception')..writeln(stackTrace);
          return exit(1);
        }
      }
    } else {
      stderr.writeln(exception);
      return exit(1);
    }
  }
}
