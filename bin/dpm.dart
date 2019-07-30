import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpm/src/services/logger.dart';
import 'package:pubspec/pubspec.dart';
import 'package:dpm/dpm.dart';

void main(List<String> args) async {
  final runner = CommandRunner(
      'dpm', 'Run commands upon installing Dart packages, and more.')
    ..addCommand(GetCommand())
    ..addCommand(InitCommand())
    ..addCommand(AddCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(UpgradeCommand());

  try {
    await runner.run(args);
  } catch (exception) {
    if (exception is UsageException) {
      final pubspec = await PubSpec.load(Directory.current);
      final preparedArgs = List<String>.from(args);
      final script = preparedArgs.removeAt(0);

      try {
        await runScript(
          pubspec,
          script,
          args: preparedArgs,
        );
      } on ScriptDoesNotExistException catch (exception) {
        Logger().error(exception.message);
        return exit(1);
      } catch (_exception, stackTrace) {
        Logger().error('ERR: $_exception \n $stackTrace');
        return exit(1);
      }
    } else {
      Logger().error(exception.toString());
      return exit(1);
    }
  }
}
