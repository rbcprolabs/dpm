import 'package:console/console.dart';

class Logger {
  factory Logger() => const Logger._internal();
  const Logger._internal();

  void info(String message) => print(message);
  void success(String message) =>
      TextPen().green().text(message).normal().print();
  void warning(String message) => TextPen().yellow().text(message).print();
  void error(String message) => TextPen().red().text(message).print();
}
