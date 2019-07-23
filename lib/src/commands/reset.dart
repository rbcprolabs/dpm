import 'package:args/command_runner.dart';
import 'clean.dart';
import 'get.dart';

class ResetCommand extends Command {
  @override
  String get name => 'reset';

  @override
  String get description => 'Runs `clean`, followed by `get`.';

  @override
  Future<void> run() async {
    await CleanCommand().run();
    await GetCommand().run();
  }
}
