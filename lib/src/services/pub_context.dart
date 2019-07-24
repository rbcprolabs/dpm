import 'dart:io';

import 'package:dpm/dpm.dart';
import 'package:pubspec/pubspec.dart';

class PubContext {
  PubContext.fromPubSpec(PubSpec pubspec)
      : isFlutter = pubspec.dependencies.containsKey('flutter');

  PubContext.fromPubLock(Publock publock)
      : isFlutter = publock.sdks.singleWhere(
                (sdk) => sdk.name.contains('flutter'),
                orElse: () => null) !=
            null;

  final bool isFlutter;

  Future<Process> start(List<String> arguments) => Process.start(
        !isFlutter ? 'pub' : 'flutter packages',
        arguments,
        runInShell: true,
      );
}
