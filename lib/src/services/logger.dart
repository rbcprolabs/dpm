import 'package:console/console.dart';

class Logger {
  factory Logger() => const Logger._internal();
  const Logger._internal();

  void info(String message) => print(TextPen().text(message).white());
  void success(String message) => print(TextPen().text(message).green());
  void warning(String message) => print(TextPen().text(message).yellow());
  void error(String message) => print(TextPen().text(message).red());
}
