import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpm/src/run.dart';
import 'package:dpm/src/services/logger.dart';
import 'package:dpm/src/services/pub_context.dart';
import 'package:pubspec/pubspec.dart';
import 'package:dpm/src/services/publock_loader.dart';
// import 'link.dart';

class GetCommand extends Command {
  @override
  String get name => 'get';

  @override
  String get description =>
      'Runs pub get, and then runs dpm of any dependencies.';
  // final LinkCommand _link = LinkCommand();

  @override
  Future<void> run() async {
    final args = [
      'get',
      if (argResults != null) ...argResults.rest,
    ];

    final publock = await loadPublock();

    await PubContext.fromPubLock(publock).run(args);
    // Logger().info('Now linking dependencies...');
    // await _link.run();

    for (final package in publock.packages) {
      final pubspec = await package.readPubspec();
      final unparsed = pubspec.unParsedYaml;

      if (unparsed.containsKey('scripts') &&
          unparsed['scripts'].containsKey('post_get')) {
        Logger().success('Running get hook from package "${package.name}"...');
        await runScript(pubspec, 'post_get', workingDir: package.location);
      }
    }

    await runScript(
      await PubSpec.load(Directory.current),
      'post_get',
      allowFail: true,
    );
  }
}
