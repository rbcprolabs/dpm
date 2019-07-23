import 'package:colorize/colorize.dart';

class Logger {
  factory Logger() => const Logger._internal();
  const Logger._internal();

  void info(String message) => print(Colorize(message)..white());
  void success(String message) => print(Colorize(message)..green());
  void warning(String message) => print(Colorize(message)..yellow());
  void error(String message) => print(Colorize(message)..red());
}
