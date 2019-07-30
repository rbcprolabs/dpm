import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpm/src/services/pub_context.dart';
import 'package:dpm/src/services/publock_loader.dart';
import 'package:dpm/src/run.dart';
import 'package:dpm/src/services/logger.dart';
import 'package:pubspec/pubspec.dart';

class UpgradeCommand extends Command {
  @override
  String get name => 'upgrade';

  @override
  String get description =>
      'Runs pub upgrade, and then runs dpm of any dependencies.';

  @override
  Future<void> run() async {
    final args = ['upgrade'];

    if (argResults != null) {
      args.addAll(argResults.rest);
    }

    final publock = await loadPublock();

    final process = await PubContext.fromPubLock(publock).start(args);
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);

    for (final package in publock.packages.values) {
      final pubspec = await package.readPubspec();
      final unparsed = pubspec.unParsedYaml;

      if (unparsed.containsKey('scripts') &&
          unparsed['scripts'].containsKey('post_upgrade')) {
        Logger().success('Running post_upgrade hook '
            'from package "${package.name}"...');
        await runScript(pubspec, 'post_upgrade', workingDir: package.location);
      }
    }

    await runScript(
      await PubSpec.load(Directory.current),
      'post_upgrade',
      allowFail: true,
    );
  }
}
