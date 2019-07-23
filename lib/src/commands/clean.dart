import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpm/src/services/logger.dart';

class CleanCommand extends Command {
  @override
  String get name => 'clean';

  @override
  String get description => 'Removes the .dpm_bin directory, if it exists.';

  @override
  Future<void> run() async {
    final dpmBin =
        Directory.fromUri(Directory.current.uri.resolve('./.dpm_bin'));

    if (await dpmBin.exists()) {
      await dpmBin.delete(recursive: true);
      Logger().success('.dpm_bin directory succeflull cleaned');
    } else {
      Logger().info('.dpm_bin directory empty');
    }
  }
}
